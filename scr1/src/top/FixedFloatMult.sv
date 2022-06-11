

module FixedFloatMult
  #(
    parameter integer W_INPUT_A=8,
    parameter integer W_INPUT_B=32,
    parameter integer W_OUTPUT=32
    )
   (
    input logic [W_INPUT_A-1:0] a,
    input logic [W_INPUT_B-1:0] b,
    output logic [W_OUTPUT-1:0] result
    );

   logic [W_INPUT_A+W_INPUT_B-1:0] auxilary_result;
   logic [W_INPUT_A+W_INPUT_B-1:0] auxilary_result_2;
   
   assign auxilary_result = $unsigned(a)*$unsigned(b); 
   assign auxilary_result_2 = {{8{auxilary_result[31]}}, auxilary_result[31:0]};   
   assign result = (auxilary_result_2>>8) + auxilary_result[7];   

endmodule
   
