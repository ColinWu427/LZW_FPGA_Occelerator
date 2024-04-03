module lfsr_64_bit
  ( input clk,
    input cs,
    input rst,
    input [63:0] data_in,
    input [2:0] num_char,
    output [11:0] data_out,
    output state_out
  );

  reg [63:0] shift_reg;
  reg state;
  reg feedback;
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

// Mux to create adjustable LFSR based on number of characters in string (1-8 chars, where 1:000 and 8:111)
  always @ (posedge clk) begin
    case(num_char)
	3'd0:	feedback = ~(shift_reg[7] ^ shift_reg[5] ^ shift_reg[4] ^ shift_reg[3]);
	3'd1: 	feedback = ~(shift_reg[15] ^ shift_reg[13] ^ shift_reg[12] ^ shift_reg[10]);
	3'd2:	feedback = ~(shift_reg[23] ^ shift_reg[22] ^ shift_reg[20] ^ shift_reg[19]);
	3'd3:	feedback = ~(shift_reg[31] ^ shift_reg[29] ^ shift_reg[25] ^ shift_reg[24]);
	3'd4:	feedback = ~(shift_reg[39] ^ shift_reg[36] ^ shift_reg[35] ^ shift_reg[34]);
	3'd5:	feedback = ~(shift_reg[47] ^ shift_reg[43] ^ shift_reg[40] ^ shift_reg[38]);
	3'd6:	feedback = ~(shift_reg[55] ^ shift_reg[53] ^ shift_reg[51] ^ shift_reg[48]);
	3'd7:	feedback = ~(shift_reg[63] ^ shift_reg[62] ^ shift_reg[60] ^ shift_reg[59]);
	default: feedback = ~(shift_reg[63] ^ shift_reg[62] ^ shift_reg[60] ^ shift_reg[59]);
    endcase
  end
endmodule
