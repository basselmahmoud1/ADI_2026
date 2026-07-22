module AHB_interconnect #(
    parameter DATA_WIDTH    = 32 ,
    parameter ADDR_WIDTH    = 32 ,
    parameter SLAVE_NUM     = 4  ,
    parameter SLAVE_SIZE_KB = 1  
)
(
    input  logic [ADDR_WIDTH-1:0]           haddr,
    input  logic [SLAVE_NUM-1:0][31:0]      hrdata_s,
    input  logic [SLAVE_NUM-1:0]            hresp_s,
    input  logic [SLAVE_NUM-1:0]            hreadyout_s,

    output logic [DATA_WIDTH-1:0]           hrdata,
    output logic                            hready,
    output logic [SLAVE_NUM-1:0]            hsel,
    output logic                            hresp
);

    localparam slave_size_bytes              = SLAVE_SIZE_KB * 1024;
    localparam offset                        = $clog2(slave_size_bytes);
    localparam INDEX_BITS                    = $clog2(SLAVE_NUM);

    logic [INDEX_BITS-1:0]  slave_index;

    always_comb begin
        slave_index = haddr[offset +: INDEX_BITS];
    end

    always_comb begin
        hsel = '0;
        hsel[slave_index] = 1'b1;
    end

    
    always_comb begin
        hrdata = hrdata_s[slave_index];
        hready = hreadyout_s[slave_index];
        hresp  = hresp_s[slave_index];
    end

endmodule
