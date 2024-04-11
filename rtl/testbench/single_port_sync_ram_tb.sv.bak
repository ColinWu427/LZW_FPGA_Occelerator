module single_port_sync_ram_tb();

  // Define parameters
  parameter ADDR_WIDTH = 12;
  parameter DATA_WIDTH = 64;
  parameter DEPTH = 4096;

  // Declare signals
  reg clk;
  reg [ADDR_WIDTH-1:0] addr;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  reg cs, we;
  wire valid;

  // Instantiate the module under test
  single_port_sync_ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .clk(clk),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out),
    .cs(cs),
    .we(we),
    .valid(valid)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin
    // Initialize signals
    clk = 0;
    addr = 0;
    cs = 0;
    we = 0;

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
    addr = 12'h257;
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