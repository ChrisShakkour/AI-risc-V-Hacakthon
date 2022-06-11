



module NeuralCore
  #(
    parameter integer N_NEURONS=10,
    parameter integer N_PIXELS=49,
    parameter integer W_BIAS=32,
    parameter integer W_WEIGHT=32,
    parameter integer W_PIXEL=32,
    parameter integer W_RESULT=32 
    )
   (
    // Control signals
    input logic 					    clk,
    input logic 					    rstn,

    //accel_regs config
    input logic [N_NEURONS-1:0][W_BIAS-1:0] 		    bias_regs ,
    input logic [N_NEURONS-1:0][N_PIXELS-1:0][W_WEIGHT-1:0] weight_regs,
    input logic [9:0][W_PIXEL-1:0] 			    pixel_regs,
    input logic 					    pixel_ready,
    input logic 					    new_layer,
    //input logic 					    new_pixel, 
    output logic [N_NEURONS-1:0][W_RESULT-1:0] 		    neurons_result_regs
    //  output logic 					    pixel_done,
    //output logic 					    layer_done
    );

   logic 				       clear;
   logic 				       active;
   logic 				       set_bias;   
   logic [N_NEURONS-1:0][W_WEIGHT-1:0] 	       weight_vect;
   
   
   assign active = pixel_ready;   
   assign clear = 0;
   assign set_bias = new_layer;
   
   logic 				       counter;
   always_ff @(posedge clk or negedge rstn)
     if(~rstn)       counter <= '0;
     else if(active) counter <= (counter >= 13) ? '0 : counter+1;
   

   /*
   always_ff @(posedge clk or negedge rstn)
     if(~rstn) layer_done <='0;
     else if((counter==0) & active) layer_done <= 1'b0;
     else if(counter>=49) layer_done <= 1'b1;
    */

   logic [3:0][7:0] 			       single_pixel;
   assign single_pixel = {{pixel_regs[0][31:24]},
			  {pixel_regs[0][23:16]},
			  {pixel_regs[0][15:8]}, 
			  {pixel_regs[0][7:0]}};

   logic [N_NEURONS-1:0][3:0][32:0] 	       partial_sums;
   
   genvar 				       n;
   genvar 				       p;				       
   generate
      for(n=0; n<N_NEURONS; n=n+1) begin : Neuron_genblk
	 for(p=0; p<4; p=p+1) begin : pixel_cut
	    Neuron     
	       Neuron_inst
	       (
		// INPUTS
		.clk       (clk),
		.rstn      (rstn),
		.active    (active),
		.clear     (clear),
		.set_bias  (set_bias),
		.bias      (bias_regs[n]), 
		.weight    (weight_vect[n]),
		.pixel     (single_pixel[p]),
		// OUTPUTS
		.sigma     (partial_sums[n][p])   
		);

	 end
	    always_comb begin
	       weight_vect[n] = weight_regs[n][counter];   
	    end
	    always_comb begin
	       neurons_result_regs[n] = partial_sums[n][0] +
					partial_sums[n][1] +
					partial_sums[n][2] +
					partial_sums[n][3]; 
 	    end
      end
   endgenerate
   
endmodule

   
   
