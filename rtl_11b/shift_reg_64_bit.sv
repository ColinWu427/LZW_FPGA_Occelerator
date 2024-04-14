module shift_reg_64_bit

  ( input clk,
    input [7:0] data_in,
    input shift,
    output [63:0] data_out,
    output reg_full
  );

  reg [63:0] shift_reg;
  reg [3:0] num_bytes;

  initial begin
    shift_reg <= 0;
    num_bytes <= 0;
  end

  always @ (posedge clk) begin
    if (shift) begin
	shift_reg[63:56] <= data_in;
	shift_reg[55:48] <= shift_reg[63:56];
	shift_reg[47:40] <= shift_reg[55:48];
	shift_reg[39:32] <= shift_reg[47:40];
	shift_reg[31:24] <= shift_reg[39:32];
	shift_reg[23:16] <= shift_reg[31:24];
	shift_reg[15:8] <= shift_reg[23:16];
	shift_reg[7:0] <= shift_reg[15:8];
	if (num_bytes < 7)
	  num_bytes = num_bytes + 1;
    end
  end
    
  assign reg_full = (num_bytes >= 7) ? 1'b1 : 1'b0;
  assign data_out = shift_reg;
endmodule 