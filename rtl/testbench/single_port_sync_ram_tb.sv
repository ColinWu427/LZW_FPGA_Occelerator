module single_port_sync_ram_tb();

  // Define parameters
  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 32;
  parameter DEPTH = 16;

  // Declare signals
  reg clk;
  reg [ADDR_WIDTH-1:0] addr;
  wire [DATA_WIDTH-1:0] data;
  reg cs, we, oe;
  reg [DATA_WIDTH-1:0] tb_data;

  // Instantiate the module under test
  single_port_sync_ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .clk(clk),
    .addr(addr),
    .data(data),
    .cs(cs),
    .we(we),
    .oe(oe)
  );

  // Clock generation
  always #5 clk = ~clk;

  assign data = !oe ? tb_data : 'hz;

  // Test stimulus
  initial begin
    // Initialize signals
    clk = 0;
    addr = 0;
    tb_data = 0;
    cs = 0;
    we = 0;
    oe = 0;

    // Wait for a few cycles
    #10;

    // Write data to memory
    addr = 2;
    tb_data = 32'hABCDE123;
    cs = 1;
    we = 1;
    #10;
    cs = 0;
    we = 0;

    // Read data from memory
    addr = 2;
    cs = 1;
    we = 0;
    oe = 1;
    #10;
    cs = 0;
    oe = 0;

    // Wait for some more cycles
    #10;

    // End simulation
    $stop;
  end

endmodule