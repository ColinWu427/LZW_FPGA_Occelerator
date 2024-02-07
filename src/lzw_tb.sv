module tb_lzw;

    parameter WIDTH = 8;
    //=============== Generate the clock =================
    localparam CLK_PERIOD = 20; //Set clock period: 20 ns
    //localparam OFFSET = 0.125 * CLK_PERIOD; //not needed for pre-synthesis simulation
    localparam DUTY_CYCLE = 0.5;
    //define clock
    logic clk_i;
    
    initial begin
	forever //run the clock forever
	begin		
		#(CLK_PERIOD*DUTY_CYCLE) clk_i = 1'b1; //wait 10 ns then set clock high
		#(CLK_PERIOD*DUTY_CYCLE) clk_i = 1'b0; //wait 10 ns then set clock low
	end
	end

    //======== Define wires going into GCD module ========
    logic clk_i;
    logic reset_i;
  
    // Outputs
    logic [13:0][11:0] compressed_o;

    //========= Instantiate a gcd module ==============
    lzw lzw0 (.*);

    initial begin
        //These two lines just allow visibility of signals in the simulation
        $vcdpluson; //Starts recording, in the VPD file, the transition times and values for the nets and registers
        $vcdplusmemon; //Records value changes and times for memories and multidimensional arrays

        $display("\n--------------Beginning Simulation!--------------\n");
        reset_i = 1;
        #100
        reset_i = 0;
        #1000
        $display("\n-------------Finished Simulation!----------------\n");
        $finish;
    end

    /*

    //========= Record Outputs ===========
    initial begin
    forever begin //run this block forever, starting at the beginning of the simulation
        @(posedge clk_i) begin
        if (valid_o == 1'b1) begin //if valid_o is high, record the value of the GCD.
            $display("Result:\t%d\n", gcd_o);
            @(negedge valid_o); //wait till it goes low to keep looking for new results
        end
        end
    end
    end

    //Task to set the initial state of the signals. Task is called up above
    task initialize_signals();
    begin
        $display("--------------Initializing Signals---------------\n");
        reset_i  = 1'b1;
        valid_i = 1'b0;
        a_i    = '0;
        b_i    = '0;
    end
    endtask

    //Example task which tests the GCD module for one test case
    task gcd_60_84();
    begin
        $display("GCD of 60 and 84");
        reset_i<=1'b0; //enable the GCD module
        @(posedge clk_i);
        a_i<=60; //pulse inputs and pulse valid bit
        b_i<=84;
        valid_i<=1'b1;
        @(posedge clk_i);
        valid_i<=1'b0; 
        a_i<=0;
        b_i<=0;
        @(posedge clk_i); //this task ends as soon as the inputs have been pulsed. Doesn't wait for results.
    end
    endtask

    task gcd_84_60();
    begin
        $display("GCD of 60 and 84");
        reset_i<=1'b0; //enable the GCD module
        @(posedge clk_i);
        a_i<=84; //pulse inputs and pulse valid bit
        b_i<=60;
        valid_i<=1'b1;
        @(posedge clk_i);
        valid_i<=1'b0; 
        a_i<=0;
        b_i<=0;
        @(posedge clk_i); //this task ends as soon as the inputs have been pulsed. Doesn't wait for results.
    end
    endtask

    //Test with the largest 8-bit prime number
task gcd_251_3();
    begin
        @(posedge clk_i);
        reset_i<=1'b0;
        @(posedge clk_i);
        valid_i<=1'b1;
        a_i<=251;
        b_i<=3;
        @(posedge clk_i);
        valid_i<=1'b0;
        a_i<=0;
        b_i<=0;
        @(posedge valid_o);
        
    end
endtask

//Test with largest adjacent fibonacci numbers
task gcd_233_144();
    begin
        @(posedge clk_i);
        reset_i<=1'b0;
        @(posedge clk_i);
        valid_i<=1'b1;
        a_i<=233;
        b_i<=144;
        @(posedge clk_i);
        valid_i<=1'b0;
        a_i<=0;
        b_i<=0;
        @(posedge valid_o);
        
    end
endtask
*/

endmodule 
