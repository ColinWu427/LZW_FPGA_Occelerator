module single_port_sync_ram
  # (parameter ADDR_WIDTH = 11,
     parameter DATA_WIDTH = 64,
     parameter DEPTH = 2048
    )

  ( input 		   clk,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data_in,
    input 		   cs,
    input		   we,
    output 		   valid,
    output [DATA_WIDTH-1:0]  data_out,
    output [ADDR_WIDTH-1:0] map_out,
    output [ADDR_WIDTH-1:0] counter_out
  );

  reg [DATA_WIDTH-1:0] mem [DEPTH][0:1];
  reg valid_regs [DEPTH];
  reg [DATA_WIDTH-1:0] tmp_data;
  reg tmp_valid;
  reg [ADDR_WIDTH-1:0] tmp_map;
  reg [ADDR_WIDTH-1:0] counter;

// Initialize memory
// -> Populate addresses 0-255 with the ASCII characters
// -> Invalidate all other addresses
  initial begin
    int i;
    for (i = 0; i < DEPTH; i = i + 1) begin
	if (i > 255) begin
	 mem[i][0] <= 0;
	 mem[i][1] <= 0;
	 valid_regs[i] <= 0;
	end
	else begin
	  mem[i][0] <= {56'h00_00_00_00_00_00_00, i};
	  valid_regs[i]<= 1;
	  mem[i][1] <= 0;
	end
    end

    tmp_data <= 0;
    tmp_valid <= 0;
    tmp_map <= 256;
    counter <= 256;
  end

  always @ (posedge clk) begin
// only allow writes if they're in registers not being used
    if (cs & we & (valid_regs[addr] == 0)) begin
// Store our input to memory and set the valid bit
	mem[addr][0] <= data_in;
	valid_regs[addr] <= 1;
// Set out map at this address to whatever our counter is at, then increment counter
	mem[addr][1] <= counter;
	tmp_map <= counter;
	tmp_data <= data_in;
	tmp_valid <= valid_regs[addr];
	counter = counter + 1;
    end
    else if (cs & !we) begin
	tmp_data <= mem[addr][0];
	tmp_valid <= valid_regs[addr];
	tmp_map <= mem[addr][1];
    end
  end

  assign data_out = cs & !we ? tmp_data : 'hz;
  assign valid = cs & !we ? tmp_valid : 1'b0;
  assign map_out = cs & !we ? tmp_map : 'hz;
  assign counter_out = counter;
endmodule
