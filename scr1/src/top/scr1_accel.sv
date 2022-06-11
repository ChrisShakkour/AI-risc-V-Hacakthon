/// Copyright by Syntacore LLC © 2016-2020. See LICENSE for details
/// @file       <scr1_accel.sv>
/// @brief      Memory Mapped Accelerator
///

`include "scr1_memif.svh"
`include "scr1_arch_description.svh"

module scr1_accel
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
    input logic 					     clk,
    input logic 					     rst_n,


    // Core data interface
    output logic 					     dmem_req_ack,
    input logic 					     dmem_req,
    input 						     type_scr1_mem_cmd_e dmem_cmd,
    input 						     type_scr1_mem_width_e dmem_width,
    input logic [`SCR1_DMEM_AWIDTH-1:0] 		     dmem_addr,
    input logic [`SCR1_DMEM_DWIDTH-1:0] 		     dmem_wdata,
    output logic [`SCR1_DMEM_DWIDTH-1:0] 		     dmem_rdata,
    output 						     type_scr1_mem_resp_e dmem_resp,

    //accel_regs config
    output logic [N_NEURONS-1:0][W_BIAS-1:0] 		     bias_regs,
    output logic [N_NEURONS-1:0][N_PIXELS-1:0][W_WEIGHT-1:0] weight_regs,
    output logic [9:0] [W_PIXEL-1:0] 			     pixel_regs,
    output logic 					     pixel_ready,
    output logic 					     new_layer, 
    //input logic 					     layer_done,
    input logic [N_NEURONS-1:0][W_RESULT-1:0] 		     neurons_result_regs  			     
);

   
//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
logic                               dmem_req_en;
logic                               dmem_rd;
logic                               dmem_wr;
logic [`SCR1_DMEM_DWIDTH-1:0]       dmem_writedata;
logic [`SCR1_DMEM_DWIDTH-1:0]       dmem_rdata_local;
logic [1:0]                         dmem_rdata_shift_reg;
//-------------------------------------------------------------------------------
// Core interface
//-------------------------------------------------------------------------------
assign dmem_req_en = (dmem_resp == SCR1_MEM_RESP_RDY_OK) ^ dmem_req;


always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        dmem_resp <= SCR1_MEM_RESP_NOTRDY;
    end else if (dmem_req_en) begin
        dmem_resp <= dmem_req ? SCR1_MEM_RESP_RDY_OK : SCR1_MEM_RESP_NOTRDY;
    end
end

assign dmem_req_ack = 1'b1;
//-------------------------------------------------------------------------------
// Memory data composing
//-------------------------------------------------------------------------------
assign dmem_rd  = dmem_req & (dmem_cmd == SCR1_MEM_CMD_RD);
assign dmem_wr  = dmem_req & (dmem_cmd == SCR1_MEM_CMD_WR);

always_comb begin
    dmem_writedata = dmem_wdata;
    case ( dmem_width )
        SCR1_MEM_WIDTH_BYTE : begin
            dmem_writedata  = {(`SCR1_DMEM_DWIDTH /  8){dmem_wdata[7:0]}};
        end
        SCR1_MEM_WIDTH_HWORD : begin
            dmem_writedata  = {(`SCR1_DMEM_DWIDTH / 16){dmem_wdata[15:0]}};
        end
        default : begin
        end
    endcase
end

 
	 reg go_bit;
	 wire go_bit_in;
	 reg done_bit;
	 wire done_bit_in;
	 reg [15:0] counter;
/*
	 reg [31:0] data_A;
	 reg [31:0] data_B;
	 wire [31:0] data_C;
	 reg [31:0] result;
 	 reg [7:0] in1, in2;
	 wire[7:0] out;
*/

   
   // #################################
   // ### REG READ LOGIC
   // #################################
   always_comb begin
      dmem_rdata_local ='0;
      //if(dmem_addr[11:2] == 0) dmem_rdata_local = bias_regs[]; // new layer trig
      //if(dmem_addr[11:2] == 1) dmem_rdata_local = bias_regs[]; 
      //if(dmem_addr[11:2] == 2) dmem_rdata_local = bias_regs[]; // layer_done
      //if(dmem_addr[11:2] == 3) dmem_rdata_local = bias_regs[]; //
      
      //bias cases 10
      for (int i=0; i<N_NEURONS; i++)
	 if(dmem_addr[11:2] == (i+10)) dmem_rdata_local = bias_regs[i]; 
      //weight cases 490
      for (int i=0; i<N_NEURONS; i++)
	for(int j=0; j<N_PIXELS; j++)
	  if(dmem_addr[11:2] == (((i*N_PIXELS)+j)+20)) dmem_rdata_local = weight_regs[i][j]; 
      //pixel cases 10  
      for (int i=0; i<10; i++)
	 if(dmem_addr[11:2] == (i+510)) dmem_rdata_local = pixel_regs[i]; 
      //result cases 10
      for (int i=0; i<N_NEURONS; i++)
	 if(dmem_addr[11:2] == (i+520)) dmem_rdata_local = neurons_result_regs[i]; 
   end

   /*
   always @(dmem_addr[11:2], bias_regs, weight_regs, pixel_regs,
	    neurons_result_regs, done_bit, go_bit, counter) begin
      case(dmem_addr[11:2])
	3'b000: dmem_rdata_local = {done_bit, 30'b0, go_bit};
	3'b001: dmem_rdata_local = {16'b0, counter}; 
	 3'b010: dmem_rdata_local = data_A;
	 3'b011: dmem_rdata_local = data_B;
	 3'b100: dmem_rdata_local = data_C;
	//bias cases 10
	for (int i=0; i<N_NEURONS; i++) begin
	   (i+10): dmem_rdata_local = bias_regs[i]; 
	end
	//weight cases 490
	for (int i=0; i<(N_NEURONS*N_PIXELS); i++) begin
	   (i+20): dmem_rdata_local = weight_regs[i]; 
	end
	//pixel cases 10  
	for (int i=0; i<10; i++) begin
	   (i+510): dmem_rdata_local = pixel_regs[i]; 
	end
	//result cases 10
	for (int i=0; i<N_NEURONS; i++) begin
	   (i+520): dmem_rdata_local = neurons_result_regs[i]; 
	end
	default: dmem_rdata_local = 32'b0;
      endcase
   end
*/
   
   // GO bit logic
   assign go_bit_in = (dmem_wr & (dmem_addr[11:2] == 10'h000));	
   always @(posedge clk or negedge rst_n)
     if(~rst_n) go_bit <= 1'b0;
     else       go_bit <= go_bit_in ? 1'b1 : 1'b0;


   always_comb
     new_layer = (dmem_wr && dmem_addr[11:2]==0);

   
// ######################################################
// ### REG WRITE LOGIC
// ######################################################     
   always @(posedge clk or negedge rst_n)
     if(~rst_n) begin
	for (int i=0; i<N_NEURONS; i++)
	  bias_regs[i] <= '0;
	for (int i=0; i<N_NEURONS; i++)
	  for(int j=0; j<N_PIXELS; j++)
	    weight_regs[i][j] <= '0;
	for (int i=0; i<10; i++)	  
	  pixel_regs[i] <= '0;
     end
     else if (dmem_wr) begin
	/*
	case(dmem_addr[11:2])
	  10'd10: bias_regs[0] <= dmem_writedata;
	  10'd11: bias_regs[1] <= dmem_writedata;
	  10'd12: bias_regs[2] <= dmem_writedata;
	  10'd13: bias_regs[3] <= dmem_writedata;
	  10'd14: bias_regs[4] <= dmem_writedata;
	  10'd15: bias_regs[5] <= dmem_writedata;
	  10'd16: bias_regs[6] <= dmem_writedata;
	  10'd17: bias_regs[7] <= dmem_writedata;
	  10'd18: bias_regs[8] <= dmem_writedata;
	  10'd19: bias_regs[9] <= dmem_writedata;
	  default:;
	endcase
	//bias_regs[9:0] <= (dmem_addr[11:2] inside[19:10])dmem_writedata;
	 */
	for (int i=0; i<N_NEURONS; i++)
	  if(dmem_addr[11:2] == i+10) bias_regs[i] <= dmem_writedata;
	//weight cases 490
	for (int i=0; i<N_NEURONS; i++)
	  for(int j=0; j<N_PIXELS; j++)
	    if(dmem_addr[11:2] == ((i*N_PIXELS)+j)+20) weight_regs[i][j] <= dmem_writedata;
 	//pixel cases 10  
	for (int i=0; i<10; i++)
	  if(dmem_addr[11:2] == i+510) pixel_regs[i] <= dmem_writedata; 	   
	//	   data_A <= (dmem_addr[4:2] == 3'b010) ? dmem_writedata : data_A;
	//	   data_B <= (dmem_addr[4:2] == 3'b011) ? dmem_writedata : data_B;
     end


   always @(posedge clk or negedge rst_n)
     if(~rst_n) pixel_ready <='0;
     else if((dmem_addr[11:2] < 520) && (dmem_addr[11:2] > 509) && dmem_wr) pixel_ready <='1;
     else pixel_ready <= '0;
	

   // counter logic
   always @(posedge clk or negedge rst_n)
     if(~rst_n) counter <= 16'b0;
     else counter <= go_bit_in? 16'h00 : done_bit_in ? counter : counter +16'h01;
   
   
   always @(posedge clk or negedge rst_n)
     if(~rst_n) done_bit <= 1'b0;
     else done_bit <= go_bit_in ? 1'b0 : done_bit_in;
   

   always_ff @(posedge clk) begin
      if (dmem_rd) begin
         dmem_rdata_shift_reg <= dmem_addr[1:0];
      end
   end

   assign dmem_rdata = dmem_rdata_local >> ( 8 * dmem_rdata_shift_reg );

endmodule : scr1_accel
