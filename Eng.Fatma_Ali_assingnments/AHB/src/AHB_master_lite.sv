import AHB_pkg::*;

module AHB_MASTER_LITE #(
    parameter DATA_WIDTH = 32 ,
    parameter ADDR_WIDTH = 32 
) (
    // Global signals  
    input   logic                               hclk , hresetn,

    // inputs from previous block  
    input   logic                               valid,write,end_burst,//////////////////////////////////
    input   size_e                              size,
    input   burst_e                             burst, 
    input   logic           [DATA_WIDTH-1:0]    w_data, 
    input   logic           [ADDR_WIDTH-1:0]    addr_in, 
    
    // inputs from SLAVE
    input   logic                               hready , hresp, 
    input   logic           [DATA_WIDTH-1:0]    hrdata,
    
    //outputs AHB to slave 
    output  logic           [DATA_WIDTH-1:0]    hwdata,
    output  logic           [ADDR_WIDTH-1:0]    haddr,
    output  trans_types_e                       htrans,
    output  size_e                              hsize,
    output  burst_e                             hburst, 
    output  logic                               hwrite,
    output  logic                               hmastlock,
    output  logic           [3:0]               hprot,
    
    //outputs AHB to previous block 
    output  logic           [DATA_WIDTH-1:0]    r_data,
    output  logic                               ready

);
    logic               [DATA_WIDTH-1:0]    data_reg        ;  
    trans_types_e                           ns , cs         ;
    logic                                   rst_sync        ;
    logic               [7:0]               remaining_beats ; 
    logic               [7:0]               burst_len       ;
    logic                                   ctrl_update_en  ;

    // internal REG for latching outputs when HREADY = 0 
    logic               [ADDR_WIDTH-1:0]    next_haddr;
    trans_types_e                           next_htrans;
    size_e                                  next_hsize;
    burst_e                                 next_hburst;
    logic                                   next_hwrite;
    logic                                   next_hmastlock;
    logic               [3:0]               next_hprot;
    
    always_comb begin
        case (burst)
            SINGLE:  burst_len = 8'd1;
            INCR:    burst_len = 8'd0; 
            WRAP4:   burst_len = 8'd4;  // not supported, forced to IDLE in output
            INCR4:   burst_len = 8'd4;
            WRAP8:   burst_len = 8'd8;  // not supported, forced to IDLE in output
            INCR8:   burst_len = 8'd8;
            WRAP16:  burst_len = 8'd16; // not supported, forced to IDLE in output
            INCR16:  burst_len = 8'd16;
            default: burst_len = 8'd1;
        endcase
    end
    
    always_comb begin
        ctrl_update_en = 1'b0;

        // Normal 
        if (hready)
            ctrl_update_en = 1'b1;

        // Exception #1 : IDLE -> NONSEQ while HREADY = 0
        else if (cs == IDLE && valid)
            ctrl_update_en = 1'b1;

        // Exception #2 : BUSY -> SEQ while HREADY = 0
        else if (cs == BUSY && valid)
            ctrl_update_en = 1'b1;

        // Exception #3 : First cycle of ERROR response
        else if (!hready && hresp)
            ctrl_update_en = 1'b1;
    end

    // counter_states_e                        burst_status    ;
    
    // reset sync

   

    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn)
            data_reg <= 0;
        else if (hready && valid && write)   // valid & write still high in Cycle N
            data_reg <= w_data;
    end

    // FF2 — moves data_reg onto hwdata during the data phase
    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn)
            hwdata <= 0;
        else if (hready && hwrite)           // hwrite is REGISTERED from Cycle N, still 1 in Cycle N+1
            hwdata <= data_reg;
    end
    // AHB control signals register
    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            haddr     <= '0;
            htrans    <= IDLE;
            hwrite    <= 1'b0;
            hsize     <= WORD;
            hburst    <= SINGLE;
            hprot     <= 4'b0011;
            hmastlock <= 1'b0;
        end
        else if (ctrl_update_en) begin
            haddr     <= next_haddr;
            htrans    <= next_htrans;
            hwrite    <= next_hwrite;
            hsize     <= next_hsize;
            hburst    <= next_hburst;
            hprot     <= next_hprot;
            hmastlock <= next_hmastlock;
        end
    end


    // burst_counter 
    always_ff @(posedge hclk or negedge hresetn ) begin 
        if (!hresetn) begin
            remaining_beats <= 0;
        end
        else if (hready == 1'b1) begin 
            // if (cs == NONSEQ && (burst != SINGLE || burst != INCR)) begin
            if (cs == NONSEQ && (burst != SINGLE && burst != INCR)) begin
                // load with one already done 
                remaining_beats <= burst_len - 1; 
            end
            else if (cs == SEQ && remaining_beats != 0 && burst != INCR) begin
                // decrement
                remaining_beats <= remaining_beats - 1; 
            end
        end 
        else // not ready so latch
            remaining_beats <= remaining_beats;  
    end 
   

    // State Register
    always_ff @(posedge hclk or negedge hresetn ) begin
        if(!hresetn)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // next state logic 
    always_comb begin 
        ns = cs;
        case (cs)
            IDLE : begin   
                if(valid == 1'b1)
                    ns = NONSEQ;
                else 
                    ns = IDLE;
            end
            NONSEQ : begin
                if(hready == 1'b1)begin
                    if(hresp == 1'b1)
                        ns = IDLE;
                    else if(valid == 1'b1)begin
                        if(burst == SINGLE)     // new consecutive transaction 

                            ns = NONSEQ;
                        else    // we have a brust so continue to seq 
                            ns = SEQ; 
                    end
                    else begin // valid == 0
                        if (burst == SINGLE) // no transaction to proceed
                            ns = IDLE;
                        else // we are in burst but data inst valid yet
                            ns =  BUSY;
                    end
                end else begin
                    ns = NONSEQ;
                end
            end
            SEQ: begin
                if(hready == 1'b1)begin
                    if(hresp == 1'b1)
                        ns = IDLE;
                    else if(valid == 1'b1)begin
                        if (burst == INCR && end_burst == 1'b1)
                            ns = NONSEQ; // Terminate INCR and start new transfer
                        else if (remaining_beats == 1 && burst != INCR) // fixed length burst finished ( burst != INCR to protect from overflow)
                            ns = NONSEQ; 
                        else // we are in burst so continue in the same state 
                            ns = SEQ; 
                    end
                    else begin // valid == 0
                        if (burst == INCR && end_burst == 1'b1)
                            ns = IDLE; // Terminate INCR and go idle
                        else if (remaining_beats == 1 && burst != INCR) // fixed length burst finished 
                            ns = IDLE;
                        else // in middle of burst and the data isnt ready yet 
                            ns =  BUSY;
                    end
                end else begin
                    ns = SEQ;
                end
            end
            BUSY: begin
                // EXCEPTION: Undefined length INCR bursts can terminate even when HREADY is low!
                if (burst == INCR && end_burst == 1'b1) begin
                    if (valid == 1'b1)
                        ns = NONSEQ; // Terminate INCR and start new transfer
                    else
                        ns = IDLE;   // Terminate INCR and go idle
                end
                else if(hready == 1'b1)begin
                    if(hresp == 1'b1)
                        ns = IDLE;
                    else if(valid == 1'b1)begin
                        ns = SEQ; // Resume fixed-length burst
                    end
                    else begin  // valid == 0
                        ns = BUSY; // Keep waiting, burst is not finished yet
                    end  
                end else begin
                    ns = BUSY;
                end
            end

            default: ns = IDLE;
        endcase
    end

    // decode transfer size to bytes for address increment
    logic [ADDR_WIDTH-1:0] size_bytes;
    always_comb begin
        case (hsize) // use registered hsize so it stays stable throughout burst
            BYTE:       size_bytes = 1;
            HALFWORD:   size_bytes = 2;
            WORD:       size_bytes = 4;
            DOUBLEWORD: size_bytes = 8;
            WORD_4:     size_bytes = 16;
            WORD_8:     size_bytes = 32;
            BITS_512:   size_bytes = 64;
            BITS_1024:  size_bytes = 128;
            default:    size_bytes = 4;
        endcase
    end

    // output logic
    always_comb begin
        // constant outputs "not supported"
        next_hmastlock = 1'b0;
        next_hprot     = 4'b0011;

        // control signals - remain constant throughout burst 
        next_hwrite = write;
        next_hsize  = size;
        next_hburst = burst;

        next_htrans = ns;

        // WRAP bursts not supported - force IDLE
        if (burst == WRAP4 || burst == WRAP8 || burst == WRAP16)
            next_htrans = IDLE;

        // address generation
        case (ns)
            IDLE:   next_haddr = haddr;
            NONSEQ: next_haddr = addr_in;           
            SEQ: begin
                    next_haddr = haddr + size_bytes; 
            end
             BUSY:    next_haddr = haddr;   
             
             //next_haddr = haddr + size_bytes; //must reflect next beat's address

            default: next_haddr = haddr;
        endcase

        // signals back to previous block
        ready  = ctrl_update_en; 
        r_data = hrdata;         
    end



endmodule
