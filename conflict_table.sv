module conflict_table
# ( parameter DEPTH = 8,
    parameter DATA_WIDTH = 64,
    parameter HASH_WIDTH = 12 
  ) 
  ( input clk,
    input rst,
    input cs,
    input we,
    output match,
    input [DATA_WIDTH-1:0] data,
    input [HASH_WIDTH-1:0] hash_in,
    output [HASH_WIDTH-1:0] hash_out,
    output ct_full
  );

  reg [HASH_WIDTH-1:0] tmp_hash;
  reg [DATA_WIDTH-1:0] mem_data [DEPTH];
  reg [HASH_WIDTH-1:0] mem_hash [DEPTH];
  wire [DEPTH-1:0] match_wires;
  reg [HASH_WIDTH-1:0] counter;
  wire [7:0] encoder_in;
  wire [2:0] encoder_out;
/*
// Generate wires for matching
  genvar i;
  generate
    for (i = 0; i < DEPTH; i++) begin : match_gen
      wire match_wire;
      assign match_wire = (cs && !we && (data == mem_data[i]));
      assign match_regs[i] = match_wire;
    end
  endgenerate
*/

// Match wires
  assign  match_wires[7] = (data == mem_data[7]) ? 1'b1 : 1'b0;
  assign  match_wires[6] = (data == mem_data[6]) ? 1'b1 : 1'b0;
  assign  match_wires[5] = (data == mem_data[5]) ? 1'b1 : 1'b0;
  assign  match_wires[4] = (data == mem_data[4]) ? 1'b1 : 1'b0;
  assign  match_wires[3] = (data == mem_data[3]) ? 1'b1 : 1'b0;
  assign  match_wires[2] = (data == mem_data[2]) ? 1'b1 : 1'b0;
  assign  match_wires[1] = (data == mem_data[1]) ? 1'b1 : 1'b0;
  assign  match_wires[0] = (data == mem_data[0]) ? 1'b1 : 1'b0;

// Encoder logic
  assign encoder_out[2] = encoder_in[4] | encoder_in[5] | encoder_in[6] | encoder_in[7];
  assign encoder_out[1] = encoder_in[2] | encoder_in[3] | encoder_in[6] | encoder_in[7];
  assign encoder_out[0] = encoder_in[1] | encoder_in[3] | encoder_in[5] | encoder_in[7];

// Reset for counter
  always @ (posedge clk) begin
    if (!rst) begin // Active LOW reset
	counter <= 0;
	mem_data[7] <= 'h0;
	mem_data[6] <= 'h0;
	mem_data[5] <= 'h0;
	mem_data[4] <= 'h0;
	mem_data[3] <= 'h0;
	mem_data[2] <= 'h0;
	mem_data[1] <= 'h0;
	mem_data[0] <= 'h0;
    end
  end

  initial begin
    counter <= 0;
    mem_data[7] <= 'h0;
    mem_data[6] <= 'h0;
    mem_data[5] <= 'h0;
    mem_data[4] <= 'h0;
    mem_data[3] <= 'h0;
    mem_data[2] <= 'h0;
    mem_data[1] <= 'h0;
    mem_data[0] <= 'h0;
  end

// Writing entry into conflict table
  always @ (posedge clk) begin
    if (cs & we) begin
	mem_data[counter] <= data;
	mem_hash[counter] <= hash_in;
	if (counter != 3'b111)
	  counter <= counter + 1;
    end
  end

// Getting entry from conflict table
  always @ (posedge clk) begin
    if (cs & !we)
	tmp_hash <= mem_hash[encoder_out];
  end
	  	
// Assert match when any of the data cells match the input
  assign match = (|(match_wires) & cs);
// The match regs feed into the encoder
  assign encoder_in[7:0] = match_wires[7:0];
// Hash output
  assign hash_out = cs & !we ? tmp_hash : 'hz;
// If the counter is at 8, the conflict table is full
  assign ct_full = (counter == 3'b111) ? 1 : 0;

endmodule 