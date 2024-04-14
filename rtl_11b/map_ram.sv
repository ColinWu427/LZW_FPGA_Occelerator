module map_ram
  # (parameter ADDR_WIDTH = 11,
     parameter DEPTH = 2048
    )

  ( input 		   clk,
    input [ADDR_WIDTH-1:0] addr,
    input 		   cs,
    input		   we,
    output [ADDR_WIDTH-1:0] map_out,
    output [ADDR_WIDTH-1:0] counter_out
  );

  reg [ADDR_WIDTH-1:0] mem [DEPTH];
  reg [ADDR_WIDTH-1:0] tmp_map;
  reg [ADDR_WIDTH-1:0] counter;

// Initialize memory
// -> Populate addresses 0-255 with the ASCII characters
// -> Invalidate all other addresses
  initial begin
    int i;
    for (i = 0; i < DEPTH; i = i + 1) begin
	mem[i] <= 0;
    end

    tmp_map <= 256;
    counter <= 256;
  end

  always @ (posedge clk) begin
// only allow writes if they're in registers not being used
    if (cs & we & (valid_regs[addr] == 0)) begin
// Set out map at this address to whatever our counter is at, then increment counter
	mem[addr] <= counter;
	tmp_map <= counter;
	counter = counter + 1;
    end
    else if (cs & !we) begin
	tmp_map <= mem[addr];
    end
  end

  assign map_out = cs & !we ? tmp_map : 'hz;
  assign counter_out = counter;
endmodule