module single_port_sync_ram
  # (parameter ADDR_WIDTH = 12,
     parameter DATA_WIDTH = 64,
     parameter DEPTH = 4096
    )

  ( input 		   clk,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data_in,
    input 		   cs,
    input		   we,
    output 		   valid,
    output [DATA_WIDTH-1:0]  data_out
  );

  reg [DATA_WIDTH-1:0] mem [DEPTH];
  reg valid_regs [DEPTH];
  reg [DATA_WIDTH-1:0] tmp_data;
  reg tmp_valid;

// Initialize memory
// -> Populate addresses 0-255 with the ASCII characters
// -> Invalidate all other addresses
  initial begin
    int i;
    for (i = 0; i < DEPTH; i = i + 1) begin
	if (i > 255) begin
	 mem[i] <= 0;
	 valid_regs[i] <= 0;
	end
	else begin
	  mem[i] <= {56'h00_00_00_00_00_00_00, i};
	  valid_regs[i] <= 1;
	end
    end

  tmp_data <= 0;
  tmp_valid <= 0;
  end

  always @ (posedge clk) begin
// only allow writes if they're in registers not being used
    if (cs & we & (valid_regs[addr] == 0)) begin
	mem[addr] <= data_in;
	valid_regs[addr] <= 1;
	tmp_data <= data_in;
	tmp_valid <= valid_regs[addr];
    end
    else if (cs & !we) begin
	tmp_data <= mem[addr];
	tmp_valid <= valid_regs[addr];
    end
  end

  assign data_out = cs & !we ? tmp_data : 'hz;
  assign valid = cs & !we ? tmp_valid : 1'b0;
endmodule
