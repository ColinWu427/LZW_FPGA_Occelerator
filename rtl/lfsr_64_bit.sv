module lfsr_64_bit
  ( input clk,
    input cs,
    input rst,
    input [63:0] data_in,
    output [11:0] data_out,
    output state_out
  );

  reg [63:0] shift_reg;
  reg state;
  wire feedback;
  assign feedback = ~(shift_reg[63] ^ shift_reg[62] ^ shift_reg[60] ^ shift_reg[59]);
  assign state_out = state;
  assign data_out[11:0] = shift_reg[11:0];

  always @ (posedge clk) begin
    if (!rst) begin // Active LOW reset
	shift_reg [63:0] <= 64'b0;
	state <= 0;
    end
    else if (cs & !state) begin
	state <= 1;
	shift_reg <= data_in;
	 end
    else if (cs & state)
	shift_reg <= {shift_reg[62:0], feedback};
    else
	shift_reg <= shift_reg;
  end

endmodule
