//`timescale 1ns / 1ps

module fifo_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 8;

    // Testbench signals
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

	wire req1;
	wire req2;

    // Instantiate the FIFO memory-based module
    fifo_memory_based #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 100 MHz clock (period = 10ns)
    end

    // Random stimulus generation
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        // Apply random reset for a short period during simulation
        rst = 1;  // Assert reset
        #10 rst = 0;  // Deassert reset after 10 ns

        // Randomized write and read operations
        $display("Starting Randomized FIFO Test...");

        // Test for 100 random operations (write/read)
        repeat (110) begin
            // Randomly decide whether to write or read
            if ($random % 2 == 1 && !full) begin
                // Random write operation
                wr_en = 1;
                din = $random;  // Generate random data
                $display("Write: din = %h", din);
                #10;  // Wait for a few time steps
            end 
            else begin
                // If FIFO is full or empty, just deassert control signals
                wr_en = 0;
                rd_en = 0;
                #10;
            end
        end

        repeat(110)begin 
            if ($random % 2 == 1 && !empty) begin
                // Random read operation
                rd_en = 1;
                $display("Read: dout = %h", dout);
                #10;  // Wait for a few time steps
            end 
            else begin
                // If FIFO is full or empty, just deassert control signals
                wr_en = 0;
                rd_en = 0;
                #10;
            end
        end

            // Randomly assert and deassert reset during the test
            if ($random % 5 == 0) begin
                rst = 1;  // Assert reset
                #5;
                rst = 0;  // Deassert reset
                #5;
            end

            // Deassert write and read signals after each operation
            wr_en = 0;
            rd_en = 0;
            #10;
        end

        // End simulation after 100 operations
      initial  #5000 $finish;



    // Monitor signals (optional)
    initial begin
        $monitor("Time = %t, Full = %b, Empty = %b, wr_en = %b, rd_en = %b, din = %h, dout = %h",
                 $time, full, empty, wr_en, rd_en, din, dout);
    end

endmodule
