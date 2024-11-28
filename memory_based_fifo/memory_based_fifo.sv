module fifo_memory_based #(
    parameter DATA_WIDTH = 8,  // Data width (number of bits per word)
    parameter FIFO_DEPTH = 8,  // Depth of the FIFO (number of words)
	parameter FIFO_VALID = 7
)(
    input wire clk,              // Clock signal
    input wire rst,              // Reset signal (active high)
    input wire wr_en,            // Write enable signal
    input wire rd_en,            // Read enable signal
    input wire [DATA_WIDTH-1:0] din,  // Data input to FIFO
    output wire [DATA_WIDTH-1:0] dout, // Data output from FIFO
    output wire full,            // FIFO full flag
    output wire empty            // FIFO empty flag
);

    // Memory array to store FIFO data
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    
    // Write pointer and read pointer
    reg [4:0] wr_ptr; // Write pointer (5-bit for FIFO_DEPTH=16)
    reg [4:0] rd_ptr; // Read pointer (5-bit for FIFO_DEPTH=16)
    
    // FIFO status flags
    reg full_reg;
    reg empty_reg;
    
    // Write data to FIFO memory
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 5'd0;
            full_reg <= 1'b0;
        end else if (wr_en && !full_reg) begin
            fifo_mem[wr_ptr] <= din;  // Write data to memory
            wr_ptr <= wr_ptr + 1;     // Increment write pointer
        end
    end
    
    // Read data from FIFO memory
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 5'd0;
            empty_reg <= 1'b1;
        end else if (rd_en && !empty_reg) begin
            rd_ptr <= rd_ptr + 1;     // Increment read pointer
        end
    end
    
    // FIFO full condition (when write pointer is one behind read pointer)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            full_reg <= 1'b0;
        end else if (wr_en && !full_reg && (wr_ptr == rd_ptr - 1)) begin
            full_reg <= 1'b1;  // FIFO is full
        end else if (rd_en && full_reg) begin
            full_reg <= 1'b0;  // FIFO is not full anymore after reading
        end
    end
    
    // FIFO empty condition (when read pointer is equal to write pointer)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            empty_reg <= 1'b1;
        end else if (wr_en && empty_reg) begin
            empty_reg <= 1'b0;  // FIFO is not empty after writing
        end else if (rd_en && !empty_reg && (rd_ptr == wr_ptr)) begin
            empty_reg <= 1'b1;  // FIFO is empty after reading
        end
    end
    
    // Output data (dout)
    assign dout = fifo_mem[rd_ptr];
    
    // Output flags
    assign full = full_reg;
    assign empty = empty_reg;

endmodule
