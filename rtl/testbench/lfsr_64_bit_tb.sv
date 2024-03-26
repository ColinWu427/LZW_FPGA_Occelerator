module lfsr_64_bit_tb();

  // Inputs
  reg clk;
  reg cs;
  reg rst;
  reg [63:0] data_in;

  // Outputs
  wire [63:0] data_out;
  wire state_out;

  // Instantiate the lfsr_64_bit module
  lfsr_64_bit DUT (
    .clk(clk),
    .cs(cs),
    .rst(rst),
    .data_in(data_in),
    .data_out(data_out),
    .state_out(state_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial values
  initial begin
    clk = 0;
    cs = 0;
    rst = 0;
    data_in = 64'b0;
    
    #10 rst = 1; cs = 1; data_in = 64'b011000100110000101101110011010100110111101101001011011100110011100001010;
    #5 cs = 0; #5 cs =1;
    #20 
    #10 rst = 1; cs = 1; data_in = 64'h0000000000000000;
    #100 $stop; // Finish simulation after 100 time units
  end

endmodule