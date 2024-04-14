module core
# ( parameter DEPTH = 8,
    parameter DATA_WIDTH = 64,
    parameter HASH_WIDTH = 12 
  )
  ( input clk,
    input rst,
    output reg [HASH_WIDTH-1:0] out
  );

  parameter LOAD = 0, FETCH = 1, RAM_SEARCH = 2, HASH_COLL = 3, COMPLETE = 4, STR_INC = 5, STR_DEC = 6, ENC_FAIL = 7;

  reg [2:0] state;
// Number of characters in current string
  reg [2:0] num_char;
// Number of shift register cycles needed
  reg [2:0] sr_cycles;
// End of file tracker to show when the end of a file has been reached
  wire eof;
// Current string being encoded
  reg [63:0] str;
// Output mux selector
  reg output_sel;
// Cycle counter for LFSR (may need to be longer if more cycles are needed)
  reg cycle_count;
// Variable to mark when we have a valid hash from the LFSR
  reg hash_valid;
// Register to store the most recent successful encode of str
  reg [11:0] prev_encode;
// Register to store the most recent successful map of str
  reg [11:0] prev_map;
// Register to delay ram 2 cycles while waiting for hash during RAM_SEARCH
  reg [1:0] ram_hash_cycles;
// Register to delay ram 1 cycles while waiting for ram_valid during HASH_COLL
  reg ram_valid_cycles;

// File ROM		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  reg [11:0] rom_addr;
  wire [63:0] rom_data_out;
  reg rom_cs, rom_valid;

  file_rom #(DEPTH, DATA_WIDTH, HASH_WIDTH) ROM (
    .clk(clk),
    .data_out(rom_data_out),
    .cs(rom_cs),
    .valid(rom_valid),
    .eof(eof)
  );

// Shift Reg		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Registers to hold the next 8 bytes for manipulation
  wire [63:0] next_8bytes;
  wire [7:0] sr_data_in;
  reg shift;
  wire sr_full;

  shift_reg_64_bit SHIFT_REG (
    .clk(clk),
    .data_in(sr_data_in),
    .shift(shift),
    .data_out(next_8bytes),
    .reg_full(sr_full)
  );

// Assign the input to our shift register to the ROM output
  assign sr_data_in = rom_data_out;

// Conflict Table 	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  reg ct_cs, ct_we, ct_rst, ct_full;
  wire [DATA_WIDTH-1:0] ct_data;
  reg [HASH_WIDTH-1:0] ct_hash_in;
  reg [HASH_WIDTH-1:0] ct_map_in;
  wire match;
  wire [HASH_WIDTH-1:0] ct_hash_out;
  wire [HASH_WIDTH-1:0] ct_map_out;

 conflict_table #(DEPTH, DATA_WIDTH, HASH_WIDTH) CT (
    .clk(clk),
    .rst(ct_rst),
    .cs(ct_cs),
    .we(ct_we),
    .match(match),
    .data(ct_data),
    .hash_in(ct_hash_in),
    .hash_out(ct_hash_out),
    .map_in(ct_map_in),
    .map_out(ct_map_out),
    .ct_full(ct_full)
  );

// Assign the conflict table data input to be our string
  assign ct_data = str;

// LFSR 		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  reg lfsr_cs, lfsr_rst; 
  reg [63:0] lfsr_data_in;
  wire [11:0] lfsr_data_out;
  wire lfsr_state;

  lfsr_64_bit LFSR (
    .clk(clk),
    .cs(lfsr_cs),
    .rst(lfsr_rst),
    .data_in(lfsr_data_in),
    .data_out(lfsr_data_out),
    .state_out(lfsr_state),
    .num_char(num_char)
  );

  assign lfsr_data_in = str;

// RAM			++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  reg [11:0] ram_addr;
  wire [63:0] ram_data_in;
  wire [63:0] ram_data_out;
  wire [11:0] ram_map_out;
  wire [11:0] ram_counter_out;
  reg ram_cs, ram_we, ram_valid;

  single_port_sync_ram RAM (
    .clk(clk),
    .addr(ram_addr),
    .data_in(ram_data_in),
    .data_out(ram_data_out),
    .map_out(ram_map_out),
    .counter_out(ram_counter_out),
    .cs(ram_cs),
    .we(ram_we),
    .valid(ram_valid)
  );

// Assign the data input of ram to our string
  assign ram_data_in = str;
  assign ct_map_in = ram_counter_out;

// Core Loop		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  initial begin
    state <= LOAD;
    prev_encode <= 0;
    prev_map <= 0;
    ram_hash_cycles = 2;

    num_char <= 0;
    sr_cycles <= 0;

    ram_we <= 0;
    ram_cs <= 0;

    lfsr_cs <= 0;
    lfsr_rst <= 0;

    ct_cs <= 0;
    ct_we <= 0;
    ct_rst <= 0;

    rom_cs <= 0;

    shift <= 0;
end

  always @ (posedge clk) begin
// If LFSR is in state 0 (reset) take it out of reset and use cs to cycle it
// else If the top 3 bits of the LFSR output are all 0 keep cycling
// -> the value is in the range 0-255 which are not an allowable hash
// -> those addresses are reserved for single ASCII and matching will need to be handled separately
// else Once we have an allowed hash, assert hash_valid which will take us into RAM_SEARCH on the next clk cycle
    if (lfsr_state == 0) begin
	lfsr_cs <= 1;
	lfsr_rst <= 1;
	hash_valid <= 0;
    end
    else if (lfsr_data_out[11:8] != 0'b000) begin
	lfsr_cs <= 0;
	hash_valid <= 1;
    end
  end


  always @ (posedge clk) begin
    case (state)
	LOAD: begin
// Once ROM is valid, as keep shifting in bits until our shift register is full
		if (!sr_full && rom_valid) begin
		  rom_cs <= 1;
		  shift <= 1;
		end
// If we need to cycle our SR after a writeback, do so and decrement sr_cycles
		else if (sr_cycles != 0) begin
		  rom_cs <= 1;
		  shift <= 1;
		  sr_cycles <= sr_cycles - 1;
		end
// Otherwise, do not shift and go to FETCH
		else begin
		  rom_cs <= 0;
		  shift <= 0;
		  state <= FETCH;
		end
	    end
	FETCH: begin
		out <= 'hz;
		ram_we <= 0;
		ct_we <= 0;
		ct_rst <= 1;
// if there's no more file to encode change state to complete
		if (eof & (next_8bytes == 0))
		  state <= COMPLETE;
// else if the next_8bytes shift register isn't full, wait for it to be full
		else if (!sr_full)
		  state <= FETCH;
// else if we need to cycle our shift register, wait until the cycles are finished
		else if (sr_cycles != 0) begin
		  sr_cycles = sr_cycles - 1;
		end
// else if there's more file left and we have a match in the conflict table and there's not already 8 chars in str, add the next char to our string and reset the LFSR
// set the previous encode to our hash from the conflict table
		else begin
		  ct_cs <= 1;
		  if (ct_cs & match & (num_char < 7)) begin
		    state <= STR_INC;
		    prev_encode <= ct_hash_out;
		    prev_map <= ct_map_out;
		  end
// else if there's more file left and we don't have a match in the conflict table and the hash is ready, change state to RAM_SEARCH
		  else if (ct_cs & !match & hash_valid)
		    state <= RAM_SEARCH;
// If we only have a single character, we don't want to use the LFSR hash we want to use the character itself as the address
		    if (num_char != 0)
		  	ram_addr <= lfsr_data_out;
		    else
		  	ram_addr <= str[11:0];
		    ram_cs <= 1;
		end
	    end
	RAM_SEARCH: begin
// Wait until we have a valid hash from our lfsr
		if (hash_valid) begin
// Reassign our hash one time after we have a valid hash, also wait for the ram valid to update
		  if (ram_hash_cycles != 0) begin
		    if (num_char != 0)
			  ram_addr <= lfsr_data_out;
		    else
			  ram_addr <= str[11:0];
		    ram_hash_cycles <= ram_hash_cycles - 1;
		    state <= RAM_SEARCH;
		  end
// if the RAM data at our hash is valid and matches the input and there's not already 8 chars in str add the next char to our string and reset the LFSR
// -> go back to FETCH state
// -> set our previous encode to the address we just found
		  else if (ram_data_out == str & num_char < 7 & ram_valid) begin
		    state <= STR_INC;
		    prev_encode <= ram_addr;
		    prev_map <= ram_map_out;
		  end
// else if the data at our hash is not valid, write the data into RAM and set our string back to 1 character and increment the bit counter
// -> output the previous encoded value
// -> go back to FETCH state
		  else if (!ram_valid) begin
		    ram_we <= 1;
		    state <= STR_DEC;
		  end
// else if the data at our hash is valid but doesnt match our string, we have a hash collision :(
		  else if (ram_valid & ram_data_out != str)
		    state <= HASH_COLL;
		end
		else
		  state <= RAM_SEARCH;
	    end
	HASH_COLL: begin
		ram_cs <= 1;
		ram_we <= 0;
		if (ram_valid_cycles != 0) begin
		  ram_valid_cycles <= ram_valid_cycles - 1;
		end
// if the current RAM entry is valid, increment the address by 1 until we find an invalid entry for our data to take
		else if (ram_valid & ram_addr < 4094) begin
		  ram_addr <= ram_addr + 1;
		  ram_valid_cycles <= 1;
		end
// if our address is the max address in our RAM go back to 256
		else if (ram_valid & ram_addr == 4095)
		  ram_addr <= 0'b0001_0000_0000;
// else if the current RAM entry is invalid, write the data to ram at this address and write to the confict table
// -> set our string back to 1 character and increment the bit counter
// -> output the previous encoded value
		else if (!ram_valid) begin
		  ram_we <= 1;
		  state <= STR_DEC;
// if the conflict table is not full, write our new hash and str to it
		  if (!ct_full) begin
		    ct_hash_in <= ram_addr;
		    ct_we <= 1;
		  end
		  else if (ct_full) begin
		    state <= ENC_FAIL;
		  end
		end
	    end
	COMPLETE: begin
		state <= COMPLETE;
	    end
// Intermediary state for adding another character to the string without disturbing writes
	STR_INC: begin
		num_char <= num_char + 1;
		lfsr_rst <= 0;
		hash_valid <= 0;
		ram_we <= 0;
		ct_we <= 0;
		state <= FETCH;
		ram_hash_cycles <= 2;
		ram_valid_cycles <= 1;
	    end
// Intermediary state for setting the string back to a single character and shifting in a new byte without disturbing writes
	STR_DEC: begin
		num_char <= 0;
		sr_cycles <= num_char;
		//rom_cs <= 1;
		lfsr_rst <= 0;
		hash_valid <= 0;
		ram_we <= 0;
		ct_we <= 0;
		state <= LOAD;
		ram_hash_cycles <= 2;
		ram_valid_cycles <= 1;
		if (output_sel)
		  out <= prev_map;
		else
		  out <= prev_encode;
	    end
	ENC_FAIL: begin
		state <= ENC_FAIL;
		out <= 'hz;
	    end
    endcase
  end

// Notes		******************************************************************************
// System will get a valid hash BEFORE moving from FETCH to RAM_SEARCH 
// out should be high Z when not in use
// RAM write enable should be 0 going from FETCH to RAM_SEARCH
// Be careful of transitions from writing to RAM back to fetch, check timings ensure this writes the correct data to RAM

// Str+OUT MUX		++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  always @ (num_char or next_8bytes) begin
    case (num_char)
	3'd0: begin
	  str <= {56'h00_00_00_00_00_00_00, next_8bytes[7:0]};
	  output_sel <= 0;
	end
	3'd1: begin
	  str <= {48'h00_00_00_00_00_00, next_8bytes[15:0]};
	  output_sel <= 0;
	end
	3'd2: begin
	  str <= {40'h00_00_00_00_00, next_8bytes[23:0]};
	  output_sel <= 1;
	end
	3'd3: begin
	  str <= {32'h00_00_00_00, next_8bytes[31:0]};
	  output_sel <= 1;
	end
	3'd4: begin
	  str <= {24'h00_00_00, next_8bytes[39:0]};
	  output_sel <= 1;
	end
	3'd5: begin
	  str <= {16'h00_00, next_8bytes[47:0]};
	  output_sel <= 1;
	end
	3'd6: begin
	  str <= {8'h00, next_8bytes[56:0]};
	  output_sel <= 1;
	end
	3'd7: begin
	  str <= next_8bytes;
	  output_sel <= 1;
	end
    endcase
  end


endmodule
