`timescale 1ns / 1ns

module tb_lzw;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in time units
  parameter RESET_TIME = 20; // Reset duration in time units
  
  // Inputs
  logic clk = 0;
  logic reset_i = 1;
  logic [13:0][7:0] text;
  
  // Outputs
  logic [13:0][11:0] compressed_o;
  
  // Instantiate the LZW module
  lzw dut (
    .clk(clk),
    .reset_i(reset_i),
    .compressed_o(compressed_o)
  );

  // Clock generation
  always #((CLK_PERIOD)/2) clk = ~clk; // Toggle the clock every half period

  // Reset generation
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
    // Wait for a few cycles
    #10;
    
    // Release reset after a specified duration
    reset_i = 1;
    #RESET_TIME;
    reset_i = 0;
    
    // Provide some delay before driving the input text
    #100;
    
    
    // Add some delay for simulation stability
    #1000;
    
    // End simulation
    $finish;
  end

endmodule