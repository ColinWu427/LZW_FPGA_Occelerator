module conflict_table
# ( parameter DEPTH = 16,
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
    input [HASH_WIDTH-1:0] map_in,
    output [HASH_WIDTH-1:0] hash_out,
    output [HASH_WIDTH-1:0] map_out,
    output ct_full
  );

  reg [HASH_WIDTH-1:0] tmp_hash;
  reg [HASH_WIDTH-1:0] tmp_map;
  reg [DATA_WIDTH-1:0] mem_data [DEPTH];
  reg [HASH_WIDTH-1:0] mem_hash [DEPTH];
  reg [HASH_WIDTH-1:0] mem_map [DEPTH];
  wire [DEPTH-1:0] match_wires;
  reg [$clog2(DEPTH):0] counter;
  wire [DEPTH-1:0] encoder_in;
  wire [$clog2(DEPTH)-1:0] encoder_out;
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
  if (DEPTH == 16) begin
    assign  match_wires[15] = ((data == mem_data[15]) && (data != 0)) ? 1'b1 : 1'b0;
    assign  match_wires[14] = ((data == mem_data[14]) && (data != 0)) ? 1'b1 : 1'b0;
    assign  match_wires[13] = ((data == mem_data[13]) && (data != 0)) ? 1'b1 : 1'b0;
    assign  match_wires[12] = ((data == mem_data[12]) && (data != 0)) ? 1'b1 : 1'b0;
    assign  match_wires[11] = ((data == mem_data[11]) && (data != 0)) ? 1'b1 : 1'b0;
    assign  match_wires[10] = ((data == mem_data[10]) && (data != 0)) ? 1'b1 : 1'b0;
    assign  match_wires[9] = ((data == mem_data[9]) && (data != 0)) ? 1'b1 : 1'b0;
    assign  match_wires[8] = ((data == mem_data[8]) && (data != 0)) ? 1'b1 : 1'b0;
  end
  assign  match_wires[7] = ((data == mem_data[7]) && (data != 0)) ? 1'b1 : 1'b0;
  assign  match_wires[6] = ((data == mem_data[6]) && (data != 0)) ? 1'b1 : 1'b0;
  assign  match_wires[5] = ((data == mem_data[5]) && (data != 0)) ? 1'b1 : 1'b0;
  assign  match_wires[4] = ((data == mem_data[4]) && (data != 0)) ? 1'b1 : 1'b0;
  assign  match_wires[3] = ((data == mem_data[3]) && (data != 0)) ? 1'b1 : 1'b0;
  assign  match_wires[2] = ((data == mem_data[2]) && (data != 0)) ? 1'b1 : 1'b0;
  assign  match_wires[1] = ((data == mem_data[1]) && (data != 0)) ? 1'b1 : 1'b0;
  assign  match_wires[0] = ((data == mem_data[0]) && (data != 0)) ? 1'b1 : 1'b0;

// Encoder logic
  if (DEPTH == 16) begin
    assign encoder_out[3] = encoder_in[8] | encoder_in[9] | encoder_in[10] | encoder_in[11] | encoder_in[12] | encoder_in[13] | encoder_in[14] | encoder_in[15];
    assign encoder_out[2] = encoder_in[4] | encoder_in[5] | encoder_in[6] | encoder_in[7] | encoder_in[12] | encoder_in[13] | encoder_in[14] | encoder_in[15];
    assign encoder_out[1] = encoder_in[2] | encoder_in[3] | encoder_in[6] | encoder_in[7] | encoder_in[10] | encoder_in[11] | encoder_in[14] | encoder_in[15];
    assign encoder_out[0] = encoder_in[1] | encoder_in[3] | encoder_in[5] | encoder_in[7] | encoder_in[9] | encoder_in[11] | encoder_in[13] | encoder_in[15];
  end
  if (DEPTH == 8) begin
    assign encoder_out[2] = encoder_in[4] | encoder_in[5] | encoder_in[6] | encoder_in[7];
    assign encoder_out[1] = encoder_in[2] | encoder_in[3] | encoder_in[6] | encoder_in[7];
    assign encoder_out[0] = encoder_in[1] | encoder_in[3] | encoder_in[5] | encoder_in[7];
  end

  initial begin
    counter <= 0;
    tmp_hash <= 0;
    tmp_map <= 0;
    if (DEPTH == 16) begin
      mem_data[15] <= 0;
      mem_data[14] <= 0;
      mem_data[13] <= 0;
      mem_data[12] <= 0;
      mem_data[11] <= 0;
      mem_data[10] <= 0;
      mem_data[9] <= 0;
      mem_data[8] <= 0;
    end
    mem_data[7] <= 0;
    mem_data[6] <= 0;
    mem_data[5] <= 0;
    mem_data[4] <= 0;
    mem_data[3] <= 0;
    mem_data[2] <= 0;
    mem_data[1] <= 0;
    mem_data[0] <= 0;
  end

  always @ (posedge clk) begin
    if (!rst) begin // Active LOW reset
	counter <= 0;
	/*mem_data[7] <= 0;
	mem_data[6] <= 0;
	mem_data[5] <= 0;
	mem_data[4] <= 0;
	mem_data[3] <= 0;
	mem_data[2] <= 0;
	mem_data[1] <= 0;
	mem_data[0] <= 0;*/
    end
// Writing entry into conflict table
    else if (cs & we & rst) begin
	mem_data[counter] <= data;
	mem_hash[counter] <= hash_in;
	mem_map[counter] <= map_in;
	if (counter != DEPTH) begin
	  counter <= counter + 1;
	end
    end
// Getting entry from conflict table
/*    else if (cs & !we & rst) begin
	tmp_hash <= mem_hash[encoder_out];
	tmp_map <= mem_map[encoder_out];
    end*/
  end
	
  always @ (match or encoder_out) begin
    tmp_hash = mem_hash[encoder_out];
    tmp_map = mem_map[encoder_out];
  end
  	
// Assert match when any of the data cells match the input
  assign match = (|(match_wires) & cs);
// The match regs feed into the encoder
  assign encoder_in = match_wires;
// Hash output
  assign hash_out = cs & !we ? tmp_hash : 'hz;
// Map output
  assign map_out = cs & !we ? tmp_map : 'hz;
// If the counter is at 8, the conflict table is full
  assign ct_full = (counter == DEPTH) ? 1 : 0;

endmodule 