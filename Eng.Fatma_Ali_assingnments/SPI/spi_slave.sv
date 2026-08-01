import spi_types::*;

module spi_slave (
    // input from the master 
    input logic sclk,rst_n,
    input logic sdi,csb,
    
    // input from REGMAP
    input logic [7:0] rd_data,
    
    // output to Master 
    output logic sdo,

    // output to REGMAP
    output logic [14:0] addr,
    output logic [7:0] wr_data,
    output logic wr_en
);
    logic [4:0] counter ;
    spi_header_str header;
    logic [7:0] wr_data_shift_reg; 
    logic [7:0] rd_data_shift_reg; 

    always_ff @(posedge sclk or posedge csb or negedge rst_n) begin
        if (!rst_n || csb) begin
            addr <= 0;
            wr_data <= 0;
            wr_en <= 0;
            counter <= 0;
            wr_data_shift_reg <= 0;
        end 
        else begin
            wr_en <= 0; // Default off
            
            if (counter != 23) begin
                counter <= counter + 1;
            end

            if (counter == 0) begin
                header.rw <= rw_e'(sdi);
            end
            else if (counter < 16) begin
                header.addr <= {header.addr[13:0], sdi};
            end
            
            // Address is ready at 15
            if (counter == 15) begin
                addr <= {header.addr[13:0], sdi};
            end
            
            // Data phase (clocks 16 to 23)
            if (counter >= 16 && counter < 24) begin 
                if (header.rw == WRITE) begin
                    wr_data_shift_reg <= {wr_data_shift_reg[6:0], sdi}; 
                end
            end

            // If we just finished a write, increment addr now so it's ready for next byte
            if (counter == 16 && wr_en) begin
                addr <= addr + 1;
            end

            // On the EXACT final clock of a byte (counter == 23)
            if (counter == 23) begin
                if (header.rw == WRITE) begin
                    // Concatenation to get the final live bit from SDI
                    wr_data <= {wr_data_shift_reg[6:0], sdi};
                    wr_en <= 1;
                end
                else begin
                    // For READ, increment addr early so combinational rd_data is ready for cycle 16
                    addr <= addr + 1;
                end
                
                // Burst mode 
                counter <= 16;
            end
        end
    end

    // NEGEDGE BLOCK: Handle Read Data Shifting
    always_ff @(negedge sclk or posedge csb or negedge rst_n) begin
        if (!rst_n || csb) begin
            rd_data_shift_reg <= 0;
        end 
        else begin
            if (header.rw == READ) begin
                if (counter == 16) begin
                    rd_data_shift_reg <= rd_data;
                end
                else if (counter > 16) begin 
                    // Shift out MSB first
                    rd_data_shift_reg <= {rd_data_shift_reg[6:0], 1'b0}; 
                end
            end
        end
    end

    // CONTINUOUS ASSIGNMENT: Drive SDO only during READ data phase
    assign sdo = (!csb && header.rw == READ && counter >= 16) ? rd_data_shift_reg[7] : 1'bz;

endmodule 