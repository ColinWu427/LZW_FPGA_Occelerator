//  Xilinx Simple Dual Port Single Clock RAM
  //  This code implements a parameterizable SDP single clock memory.
  //  If a reset or enable is not necessary, it may be tied off or removed from the code.

  parameter RAM_WIDTH = 64;                  // Specify RAM data width
  parameter RAM_DEPTH = 2048;                  // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE"; // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  parameter INIT_FILE = "C:/Users/ninim/Downloads/initialized_ram_modified.coe";        // Specify name/location of RAM initialization file if using one (leave blank if not)

  wire [clogb2(RAM_DEPTH-1)-1:0] w_addr; // Write address bus, width determined from RAM_DEPTH
  wire [clogb2(RAM_DEPTH-1)-1:0] r_addr; // Read address bus, width determined from RAM_DEPTH
  wire [RAM_WIDTH-1:0] data_in;          // RAM input data
  wire clk;                          // Clock
  wire we;                           // Write enable
  wire re;                           // Read Enable, for additional power savings, disable when not in use
  wire rst;                          // Output reset (does not affect memory contents)
  wire cs;                        // Output register enable
  wire [RAM_WIDTH-1:0] data_out;                  // RAM output data

  reg [RAM_WIDTH-1:0] mem [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] tmp_data = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, mem, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          mem[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clk) begin
    if (we)
      mem[w_addr] <= data_in;
    if (re)
      data_out <= mem[r_addr];
  end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign data_out = tmp_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clk)
        if (rst)
          doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (cs)
          doutb_reg <= tmp_data;

      assign data_out = doutb_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction