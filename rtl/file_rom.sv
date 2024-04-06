module file_rom
  # (parameter ADDR_WIDTH = 12,
     parameter DATA_WIDTH = 64,
     parameter DEPTH = 4096
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

// Initialize memory
// -> ABBABBBABBA
// -> 65 66 66 65 66 66 66 65 66 66 65
  initial begin
    entry_counter <= 0;
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
  end

  reg [DATA_WIDTH-1:0] tmp_data;
  reg tmp_valid;

  always @ (posedge clk) begin
    if (cs)
	tmp_data <= mem[entry_counter];
	tmp_valid <= valid_regs[entry_counter];
	entry_counter <= entry_counter + 1;
    end

  assign data_out = cs ? tmp_data : 'hz;
  assign valid = cs ? tmp_valid : 1'b0;
  assign eof = cs & tmp_valid ? 1'b0 : 1'b1;
endmodule