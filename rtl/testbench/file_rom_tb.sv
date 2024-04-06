module file_rom_tb;

  // Inputs
  reg clk = 0;
  reg cs = 1;

  // Outputs
  wire valid;
  wire [63:0] data_out;
  wire eof;

  // Instantiate the file_rom module
  file_rom dut (
    .clk(clk),
    .cs(cs),
    .valid(valid),
    .data_out(data_out),
    .eof(eof)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    // Activate chip select
    cs = 1;

    // Wait a few cycles
    #100;

    // Wait for end-of-file
    repeat (100) begin
      #10;
      if (eof) begin
        $display("End of File reached.");
        $stop;
      end
    end
  end

endmodule