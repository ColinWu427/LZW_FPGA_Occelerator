`timescale 1ns / 1ps

module testbench;

  // Parameters
  parameter RAM_WIDTH = 64;
  parameter RAM_DEPTH = 2048;
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE";
  parameter INIT_FILE = "C:/Users/ninim/Downloads/initialized_ram_modified.coe"; // Change this if using an initialization file

  // Inputs
  reg clk;
  reg we;
  reg re;
  reg rst;
  reg cs;
  reg [clogb2(RAM_DEPTH-1)-1:0] addr;
  reg [RAM_WIDTH-1:0] data_in;

  // Outputs
  wire [RAM_WIDTH-1:0] data_out;

  // Instantiate the RAM module
  shift_reg_64_bit uut (
    .clk(clk),
    .we(we),
    .re(re),
    .rst(rst),
    .cs(cs),
    .w_addr(addr),
    .r_addr(addr),
    .data_in(data_in),
    .data_out(data_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial values
  initial begin
    clk = 0;
    we = 0;
    re = 0;
    rst = 0;
    cs = 0;
    addr = 0;
    data_in = 0;
    
    // Add test stimuli here
    // For example, you can write and read data from the RAM
  end

  // Add your test cases here
     // Wait for a few cycles
    #5;

    // Write data to memory
    addr = 12'h483;
    data_in = 64'h0000000000004241;
    #20;
    cs = 1;
    we = 1;
    #10;

    addr = 12'h485;
    data_in = 64'h0000000000004242;
    #10;
    addr = 12'h285;
    data_in = 64'h0000000000004142;
    #10;

    // Read data from memory
    addr = 12'h0;
    cs = 1;
    we = 0;
    #10;
    addr = 12'h483;
    #10
    addr = 12'h485;
    #10
    addr = 12'h285;
    #10
    addr = 63;
    cs = 0;

    // Wait for some more cycles
    #10;

    // End simulation
    $stop;
  end
 
endmodule