


module Neuron
  #(
    parameter integer W_WEIGHT=32,
    parameter integer W_PIXEL_DATA=8,
    parameter integer W_RESULT=32,
    parameter integer W_BIAS=32
    )
   (
    // INPUTS
    input logic 		   clk,
    input logic 		   rstn,
    input logic 		   active,
    input logic 		   clear,
    input logic 		   set_bias,
    input logic [W_BIAS-1:0] 	   bias,     
    input logic [W_WEIGHT-1:0] 	   weight,
    input logic [W_PIXEL_DATA-1:0] pixel,
    // OUTPUTS
    output logic [W_RESULT-1:0]    sigma   
    );

   logic [W_RESULT-1:0] 	   mult_result;
   logic [W_RESULT-1:0] 	   nxt_sigma;
      
   // FixedFloatMult instance
   FixedFloatMult
     FixedFloatMult_inst
       (
	.a(pixel),
	.b(weight),
	.result(mult_result)
	);
   
   always_ff @(posedge clk or negedge rstn)
     if(~rstn)         sigma <='0;
     else if(clear)    sigma <='0;
     else if(set_bias) sigma <= bias;
     else if(active)   sigma <= nxt_sigma;
   
   assign nxt_sigma = sigma + mult_result;
 
endmodule // Neuron
