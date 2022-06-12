/*

description: 
design file: /home/christians/git/RV32I-MAF-demo/HDL/rtl_src/neural_core/Neuron.sv

*/



module Neuron_TB; 
 
   parameter integer W_WEIGHT=32;
   parameter integer W_PIXEL_DATA=8;
   parameter integer W_RESULT=32;
   parameter integer W_BIAS=32;
   
   localparam HALF_CLK=5; 
   localparam PERIOD=(2*HALF_CLK); 
   
   logic 	     clk;
   logic 	     rstn;
   logic 	     active;
   logic 	     clear;
   logic 	     set_bias;
   logic [W_BIAS-1:0] bias;
   logic [W_WEIGHT-1:0] weight;
   logic [W_PIXEL_DATA-1:0] pixel;
   logic [W_RESULT-1:0]     sigma;

   
   logic 		    clk_en;   
   always #HALF_CLK clk = (clk_en) ? ~clk : 0;
   
   
   Neuron
     DUT_Neuron
       (
	// INPUTS
	.clk      (clk),
	.rstn     (rstn),
	.active   (active),
	.clear    (clear),
	.set_bias (set_bias),
	.bias     (bias), 
	.weight   (weight),
	.pixel    (pixel),
	// OUTPUTS
	.sigma    (sigma)   
	);
      
     task init();
	clk_en=0;
	rstn=1;
	active='0;
	clear='0;
	set_bias='0;
	bias='0;
	weight='0;
	pixel='0;
     endtask // init()
   
   task reset();
      rstn=0;      
      #(4*PERIOD);      
      rstn=1;
   endtask // reset()
   
   initial begin
      init();
      #(4*PERIOD);      
      reset();
      #(4*PERIOD);
      
      #(HALF_CLK) clk_en=1;
      #(HALF_CLK);
      
      for (int n=0; n<20; n++) begin
	 clear=1;
	 #(PERIOD) clear=0;
	 bias = $random;
	 #(PERIOD) set_bias = 1;
	 #(PERIOD) set_bias = 0;
	 active=1;
	 #(PERIOD) 
	 for (int i=0; i<49; i++) begin
	    weight=$random;
	    pixel=$random;
	    #(PERIOD);
	 end
	 active=0;
	 #(4*PERIOD);
      end
      #(4*PERIOD) $finish;
   end
endmodule
