// Design
// lzw
module lzw (
    input clk_i,
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
  
  logic [0:13][7:0] text;
  
  logic [7:0] clk_counter;
  logic [7:0] counter, next_counter;
  logic [7:0] CALC_counter, next_CALC_counter;
  logic [31:0] sps;
  logic [31:0] str, next_str;
  logic [4095:0][11:0] dictionary, next_dictionary;
  logic [11:0] dictionary_size, next_dictionary_size;
  logic [11:0] symbol;
  logic [13:0][11:0] compressed, next_compressed; 
  
  integer i;

  function logic [11:0] hash_24_to_12(logic [23:0] value);
    logic [11:0] hashed_value;
    int sum = 0;
    foreach (value[i])
        sum += value[i];
    hashed_value = sum % 4096;
    return hashed_value;
endfunction

  logic [11:0] sps_hash;

  assign sps_hash = hash_24_to_12(sps[23:0]);

  always_ff @ (posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      counter <= 0;
      CALC_counter <= 0;
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
      dictionary_size <= 256;
    end
    else begin
      clk_counter <= clk_counter + 1;
      state <= next_state;
      text <= text;
      dictionary_size <= next_dictionary_size;
      dictionary <= next_dictionary;
      CALC_counter <= next_CALC_counter;
      counter <= next_counter;
      compressed <= next_compressed;
      str <= next_str;
    end
  end
  
  always_comb begin
    case (state)
      RESET: begin
        next_state = CALC;
        next_dictionary_size = 256;
        for (i = 0; i < 256; i++) begin
          next_dictionary[i] = i;
  	    end
        next_counter = 0;
        next_CALC_counter = 0;
      end
      CALC: begin
        $display("Time: %d", counter);
        if (CALC_counter == 14) next_state = DONE;
        symbol = text[CALC_counter];
        sps = (str << 8) + symbol;
        $display("SPS: %h", sps);
        $display(dictionary[sps] != 0);
        $display("Value in dictionary[sps]:", dictionary[sps]);
        if(dictionary[sps] > 0) begin
          $display("Entered");
          next_str = sps;
          next_state = CALC;
        end
        else begin
          next_compressed[counter] = dictionary[str];
          $display("Hex dictionary output: %h, indexing on %h", dictionary[str], str);
          next_counter = counter + 1;
          $display("Stored into dictionary: %h at %h", dictionary_size, sps);
          next_dictionary[sps] = dictionary_size;
          next_dictionary_size = dictionary_size + 1;
          next_str = symbol;
        end
        next_CALC_counter = CALC_counter + 1;
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
