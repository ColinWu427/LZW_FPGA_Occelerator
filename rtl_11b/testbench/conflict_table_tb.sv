module conflict_table_tb;

  // Parameters
  parameter DEPTH = 8;
  parameter DATA_WIDTH = 64;
  parameter HASH_WIDTH = 12;

  // Signals
  reg clk, rst, cs, we, ct_full;
  reg [DATA_WIDTH-1:0] data;
  reg [HASH_WIDTH-1:0] hash_in;
  wire match;
  wire [HASH_WIDTH-1:0] hash_out;

  // Instantiate the conflict_table module
  conflict_table #(DEPTH, DATA_WIDTH, HASH_WIDTH) uut (
    .clk(clk),
    .rst(rst),
    .cs(cs),
    .we(we),
    .match(match),
    .data(data),
    .hash_in(hash_in),
    .hash_out(hash_out),
    .ct_full(ct_full)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial values
  initial begin
    $dumpfile("conflict_table_tb.vcd");
    $dumpvars(0, conflict_table_tb);
    clk = 0;
    rst = 0;
    cs = 0;
    we = 0;
    data = 64'h0000000000000000;
    hash_in = 12'h000;
  // Testing
    #15 rst = 1; cs = 1; we = 1;
    data = 64'h1122334455667788;
    hash_in = 12'h123;
    #10 data = 64'h8877665544332211; hash_in = 12'h321;
    #10 data = 64'h2222222222222222; hash_in = 12'h222;
    #10 data = 64'h3333333333333333; hash_in = 12'h333;
    #10 data = 64'h4444444444444444; hash_in = 12'h444;
    #10 data = 64'h5555555555555555; hash_in = 12'h555;
    #10 data = 64'h6666666666666666; hash_in = 12'h666;
    #10 data = 64'h7777777777777777; hash_in = 12'h777;
    #10 cs = 1;
    #10 we = 0;
    #10 data = 64'h6666666666666666; hash_in = 12'h666;
    #10 data = 64'h5555555555555555; hash_in = 12'h555;
    #10 data = 64'h4444444444444444; hash_in = 12'h444;
    #10 data = 64'h3333333333333333; hash_in = 12'h333;
    #10 data = 64'h2222222222222222; hash_in = 12'h222;
    #10 data = 64'h8877665544332211; hash_in = 12'h321;
    #10 data = 64'h1122334455667788; hash_in = 12'h123;
    #20
    $stop;
    
  end

  // Monitor
  always @(posedge clk) begin
    $display("Time %0t: Match = %b", $time, match);
  end

endmodule