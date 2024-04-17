module file_rom
  # (parameter ADDR_WIDTH = 7,
     parameter DATA_WIDTH = 8,
     parameter DEPTH = 128
    )

  ( input 		   clk,
    input 		   cs,
    output 		   valid,
    output [DATA_WIDTH-1:0]  data_out,
    output eof
  );

  reg [DATA_WIDTH-1:0] mem [DEPTH];
  reg valid_regs [DEPTH];
  reg [ADDR_WIDTH-1:0] entry_counter;
  reg [DATA_WIDTH-1:0] tmp_data;
  reg tmp_valid, tmp_eof;

// Initialize memory
// -> ABBABBBABBA
// -> 65 66 66 65 66 66 66 65 66 66 65
  initial begin
    //entry_counter <= 12'b111111111111;
    entry_counter <= 0;
    tmp_data <= 0;
    tmp_valid <= 0;
    tmp_eof <= 0;

mem[0] <= 084;
mem[1] <= 079;
mem[2] <= 066;
mem[3] <= 069;
mem[4] <= 079;
mem[5] <= 082;
mem[6] <= 078;
mem[7] <= 079;
mem[8] <= 084;
mem[9] <= 084;
mem[10] <= 079;
mem[11] <= 066;
mem[12] <= 069;
mem[13] <= 079;
mem[14] <= 082;
mem[15] <= 084;
mem[16] <= 079;
mem[17] <= 066;
mem[18] <= 069;
mem[19] <= 079;
mem[20] <= 082;
mem[21] <= 078;
mem[22] <= 079;
mem[23] <= 084;

valid_regs[0] <= 1;
valid_regs[1] <= 1;
valid_regs[2] <= 1;
valid_regs[3] <= 1;
valid_regs[4] <= 1;
valid_regs[5] <= 1;
valid_regs[6] <= 1;
valid_regs[7] <= 1;
valid_regs[8] <= 1;
valid_regs[9] <= 1;
valid_regs[10] <= 1;
valid_regs[11] <= 1;
valid_regs[12] <= 1;
valid_regs[13] <= 1;
valid_regs[14] <= 1;
valid_regs[15] <= 1;
valid_regs[16] <= 1;
valid_regs[17] <= 1;
valid_regs[18] <= 1;
valid_regs[19] <= 1;
valid_regs[20] <= 1;
valid_regs[21] <= 1;
valid_regs[22] <= 1;
valid_regs[23] <= 1;
valid_regs[24] <= 0;

/*
mem[0] <= 073;
mem[1] <= 115;
mem[2] <= 032;
mem[3] <= 116;
mem[4] <= 104;
mem[5] <= 105;
mem[6] <= 115;
mem[7] <= 032;
mem[8] <= 101;
mem[9] <= 110;
mem[10] <= 099;
mem[11] <= 111;
mem[12] <= 100;
mem[13] <= 105;
mem[14] <= 110;
mem[15] <= 103;
mem[16] <= 063;
mem[17] <= 032;
mem[18] <= 073;
mem[19] <= 115;
mem[20] <= 032;
mem[21] <= 116;
mem[22] <= 104;
mem[23] <= 105;
mem[24] <= 115;
mem[25] <= 032;
mem[26] <= 099;
mem[27] <= 111;
mem[28] <= 109;
mem[29] <= 112;
mem[30] <= 114;
mem[31] <= 101;
mem[32] <= 115;
mem[33] <= 115;
mem[34] <= 105;
mem[35] <= 111;
mem[36] <= 110;
mem[37] <= 063;
mem[38] <= 032;
mem[39] <= 073;
mem[40] <= 115;
mem[41] <= 032;
mem[42] <= 116;
mem[43] <= 104;
mem[44] <= 105;
mem[45] <= 115;
mem[46] <= 032;
mem[47] <= 108;
mem[48] <= 111;
mem[49] <= 115;
mem[50] <= 115;
mem[51] <= 063;
mem[52] <= 013;
mem[53] <= 010;
valid_regs[0] <= 1;
valid_regs[1] <= 1;
valid_regs[2] <= 1;
valid_regs[3] <= 1;
valid_regs[4] <= 1;
valid_regs[5] <= 1;
valid_regs[6] <= 1;
valid_regs[7] <= 1;
valid_regs[8] <= 1;
valid_regs[9] <= 1;
valid_regs[10] <= 1;
valid_regs[11] <= 1;
valid_regs[12] <= 1;
valid_regs[13] <= 1;
valid_regs[14] <= 1;
valid_regs[15] <= 1;
valid_regs[16] <= 1;
valid_regs[17] <= 1;
valid_regs[18] <= 1;
valid_regs[19] <= 1;
valid_regs[20] <= 1;
valid_regs[21] <= 1;
valid_regs[22] <= 1;
valid_regs[23] <= 1;
valid_regs[24] <= 1;
valid_regs[25] <= 1;
valid_regs[26] <= 1;
valid_regs[27] <= 1;
valid_regs[28] <= 1;
valid_regs[29] <= 1;
valid_regs[30] <= 1;
valid_regs[31] <= 1;
valid_regs[32] <= 1;
valid_regs[33] <= 1;
valid_regs[34] <= 1;
valid_regs[35] <= 1;
valid_regs[36] <= 1;
valid_regs[37] <= 1;
valid_regs[38] <= 1;
valid_regs[39] <= 1;
valid_regs[40] <= 1;
valid_regs[41] <= 1;
valid_regs[42] <= 1;
valid_regs[43] <= 1;
valid_regs[44] <= 1;
valid_regs[45] <= 1;
valid_regs[46] <= 1;
valid_regs[47] <= 1;
valid_regs[48] <= 1;
valid_regs[49] <= 1;
valid_regs[50] <= 1;
valid_regs[51] <= 1;
valid_regs[52] <= 1;
valid_regs[53] <= 1;
valid_regs[54] <= 0;
*/
   /*
    mem[0] <= 65;
    mem[1] <= 66;
    mem[2] <= 66;
    mem[3] <= 65;
    mem[4] <= 66;
    mem[5] <= 66;
    mem[6] <= 66;
    mem[7] <= 65;
    mem[8] <= 66;
    mem[9] <= 66;
    mem[10] <= 65;
    valid_regs[0] <= 1;
    valid_regs[1] <= 1;
    valid_regs[2] <= 1;
    valid_regs[3] <= 1;
    valid_regs[4] <= 1;
    valid_regs[5] <= 1;
    valid_regs[6] <= 1;
    valid_regs[7] <= 1;
    valid_regs[8] <= 1;
    valid_regs[9] <= 1;
    valid_regs[10] <= 1;
    valid_regs[11] <= 0;
*/
  end

  always @ (posedge clk) begin
// If entry counter reaches the last entry in the file, assert eof
    if (valid_regs[entry_counter] == 0) begin
	tmp_data <= 0;
	tmp_valid <= 0;
	tmp_eof <= 1;
    end
    else if ((cs == 1) & (valid_regs[entry_counter] == 1)) begin
	tmp_data <= mem[entry_counter];
	tmp_valid <= valid_regs[entry_counter];
	entry_counter <= entry_counter + 1;
    end
//    else
	//entry_counter <= entry_counter + 1;
  end

/*  assign data_out = tmp_data;
  assign valid = tmp_valid;*/
  assign data_out = valid_regs[entry_counter] ? mem[entry_counter] : 0;
  assign valid = valid_regs[entry_counter];
  assign eof = tmp_eof;
endmodule 