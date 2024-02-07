// Design
// lzw
module lzw (
    input clk,
    input reset_i,
    output [13:0][11:0] compressed_o
);
  
  typedef enum logic [1:0] {
    RESET = 2'b00,
    CALC = 2'b01,
    DONE = 2'b10,
    STATEX = 2'bxx
  } state_t;
  
  state_t state, next_state;
  
  logic [13:0][7:0] text;
  
  logic [7:0] clk_counter;
  logic [7:0] counter = 0;
  logic [7:0] CALC_counter = 0;
  logic [31:0] sps;
  logic [31:0] str;
  logic [31:0][11:0] dictionary, next_dictionary;
  logic [11:0] dictionary_size, next_dictionary_size;
  logic [11:0] symbol;
  logic [13:0][11:0] compressed; 
  
  integer i;

  always_ff @ (posedge clk or posedge reset_i) begin
    if (reset_i) begin
      clk_counter <= 0;
      state <= RESET;
      text <= '{ 
    	// "b"
    	8'b01100010,
    	// "a"
    	8'b01100001,
    	// "n"
    	8'b01101110,
    	// "a"
    	8'b01100001,
    	// "n"
    	8'b01101110,
    	// "a"
    	8'b01100001,
    	// "_"
    	8'b01011111,
    	// "b"
    	8'b01100010,
    	// "a"
    	8'b01100001,
    	// "n"
    	8'b01101110,
    	// "d"
    	8'b01100100,
    	// "a"
    	8'b01100001,
    	// "n"
    	8'b01101110,
    	// "a"
    	8'b01100001
  	  };
      dictionary_size = 256;
    end
    else begin
      clk_counter <= counter + 1;
      state <= next_state;
      text <= text;
      dictionary_size = next_dictionary_size;
      dictionary = next_dictionary;
    end
  end
  
  always_comb begin
    case (state)
      RESET: begin
        next_state = CALC;
      end
      CALC: begin
        if (CALC_counter == 14) next_state = DONE;
        symbol = text[counter];
        sps = (str << 8) + symbol;
        if(dictionary[sps] != 0) begin
          str = sps;
          next_state <= CALC;
        end
        else begin
          compressed[counter] = dictionary[str];
          counter = counter + 1;
          next_dictionary[sps] = dictionary_size;
          next_dictionary_size = dictionary_size + 1;
          str = symbol;
        end
        CALC_counter = CALC_counter + 1;
      end
      DONE: begin
        next_state = DONE;
      end
    endcase
  end
  
  assign compressed_o = compressed;
        /*
  always_ff @(posedge clk or posedge reset_i) begin
    case (state)
        RESET: begin
            compressed_o <= 12'hx; // Output 'x during RESET state
        end
        CALC: begin
            compressed_o <= 12'hx; // Output 'x during CALC state
        end
        DONE: begin
            compressed_o <= compressed; // Output compressed data when DONE
        end
        default: begin
            // Default case if needed
            compressed_o <= 12'hx; // Or assign a default value
        end
    endcase
  end
  */
endmodule