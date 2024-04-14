// Try creating just one cell first, then worry about the for loops that look through all the cells

module cam_cell #(parameter CAM_WIDTH = 8, parameter NUM_CELL = 1)
 (
  input clk, rst, en,
  input [CAM_WIDTH-1:0] search_key, 
  output logic [$clog2(NUM_CELL)-1:0] cam_out,
  output logic valid
);

  logic [CAM_WIDTH-1:0] cam_mem; //[NUM_CELL-1:0];
  logic [$clog2(NUM_CELL)-1:0] cam_id = 1; //[NUM_CELL-1:0];
  logic [NUM_CELL-1:0] match_flag;

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin 	//ACTIVE LOW RST
	valid <= '0;
	cam_mem <= 'z;
	cam_out <= 'z;
    end
    else if (match_flag && en) begin	// If we find a match output the cam_id
	cam_out <= cam_id;
    end
    else if (!match_flag && en) begin	// If we don't find a match, update the cam memory, set valid bit, and output cam_id
	cam_out <= cam_id;
	cam_mem = search_key;
	valid <= '1;
    end
  end

  always_comb begin
    if (en && rst) begin //If enabled and not being reset, match flag should be actively signaling a match
	if ((search_key == cam_mem) && valid)
	  match_flag = 1'b1;
	else
	  match_flag = 1'b0;
    end
  end  

  // If any bit in match flag is 1, assert match_found
  // If all of the cells are valid=1 (occupied), then assert cam_full (no more open cells!)

endmodule