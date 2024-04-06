module core_tb;

// Inputs
  reg clk = 0;
  reg rst;

// Outputs
  wire data_out;

// Instantiate the system
  core dut (
    .clk(clk),
    .rst(rst),
    .out(data_out)
  );

// Clock generation
  always #5 clk = ~clk;

  initial begin
    #200
    $stop;
  end

endmodule 