module tb_cam_cell;

  // Parameters
  parameter CAM_WIDTH = 8;
  parameter NUM_CELL = 1;

  // Inputs
  logic clk, rst, en;
  logic [CAM_WIDTH-1:0] search_key;

  // Outputs
  logic [CAM_WIDTH-1:0] cam_out;
  logic cam_full, match_found;

  // Instantiate the cam_cell module
  cam_cell cam_cell_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .search_key(search_key),
    .cam_out(cam_out),
    .cam_full(cam_full),
    .match_found(match_found)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Reset generation
  initial begin
    rst = 1'b0;
    #10;
    rst = 1'b1;
    #10;
  end

  // Test stimulus
  initial begin
    clk = 1'b0;
    en = 1'b1;
    search_key = 8'hFF;
    #20;
    // Add more test cases here
    // Ensure to toggle write_en and read_en appropriately to test different functionalities
    search_key = 8'hFE;
    #20;
    search_key = 8'h00;
    #20;
    rst = 1'b0;
    #10;
    rst = 1'b1;
    #10;
    search_key = 8'hFF;
    #20;
    search_key = 8'hFF;
    #20;
    $stop; // Stop simulation after test cases
  end

  // Assertions
  // Add assertions to check the correctness of outputs

endmodule