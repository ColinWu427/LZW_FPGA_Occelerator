module lfsr_64_bit_tb();

  // Inputs
  reg clk;
  reg cs;
  reg rst;
  reg [63:0] data_in;
  reg [2:0] num_char;

  // Outputs
  wire [11:0] data_out;
  wire state_out;

  // Instantiate the lfsr_64_bit module
  lfsr_64_bit DUT (
    .clk(clk),
    .cs(cs),
    .rst(rst),
    .data_in(data_in),
    .data_out(data_out),
    .state_out(state_out),
    .num_char(num_char)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial values
  initial begin
    clk = 0;
    cs = 0;
    rst = 0;
    data_in = 64'b0;
    
    #10 rst = 1; cs = 1; num_char = 3'd7; data_in = 64'b011000100110000101101110011010100110111101101001011011100110011100001010;
    #5 cs = 0; #5 cs =1;
    #20 
    #10 rst = 1; cs = 1; data_in = 64'h0000000000000000;
    #10 rst = 0; num_char = 3'd0; data_in = 64'b0000000_00000000_00000000_00000000_00000000_00000000_00000000_11100011;
    #10 rst = 1;
    #200 rst = 0; num_char = 3'd1; data_in = 64'b0000000_00000000_00000000_00000000_00000000_00000000_00101100_11100011;
    #10 rst = 1;
    #200
 $stop; // Finish simulation after 100 time units
  end

endmodule