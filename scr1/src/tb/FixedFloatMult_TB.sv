/*

description: 
design file: /home/christians/git/RV32I-MAF-demo/HDL/rtl_src/neural_core/FixedFloatMult.sv

*/



module FixedFloatMult_TB; 
   
   parameter integer W_INPUT_A=8;
   parameter integer W_INPUT_B=32;
   parameter integer W_OUTPUT=32;
   localparam HALF_CLK=5; 
   localparam PERIOD=(2*HALF_CLK); 

   logic [40:0][W_INPUT_A-1:0] stored_a = 
	       {
		8'h7d,
                8'hc7,
                8'h3e,
                8'h0,
                8'h0,
                8'h0,
                8'h75,
                8'h9e,
                8'h5,
                8'h0,
                8'h0,
                8'h0,
                8'h1,
                8'hce,
                8'h50,
                8'ha5,
                8'h5c,

		8'h21,
                8'h8,
                8'h4e,
                8'h72,
                8'h7e,
                8'h26,
                8'h38,
                8'hd2,
                8'h48,
                8'hc2,
                8'h1e,
                8'h81,
                8'hf4,
                8'h5d,
                8'h6f,
                8'h90,
                8'h8e,
                8'hb4,
                8'h4a,
                8'had,
                8'h21,
                8'h6e,
                8'h21,
                8'h0,
                8'h8,
                8'h4e,
                8'h72,
                8'h7e,
                8'h26
		};
   
   logic [40:0][W_INPUT_B-1:0] stored_b = 
	       {
		32'ha66c4,
                32'h52d21,
                32'hfff7e1c5,
                32'hfffd80a2,
                32'hfffdf439,
                32'hfffe5208,
                32'h6bfda,                                                                                                          32'h4825c,
                32'h306a1,
                32'h6056a,
                32'hfffb6474,
                32'hffff5d1c,
                32'hab0f1,
                32'h3a827,
                32'h2d77,
                32'hb8235,
                32'h32f77,

		32'hfffc025f,
                32'h4de7e,
                32'h82a63,
                32'hffff848e,
                32'h7d32,
                32'hffffe115,
                32'h56a9a,
                32'h7dcc3,
                32'ha427d,
                32'hf1112,
                32'h6036a,
                32'hfff6707c,
                32'hfff5a13b,
                32'h814aa,
                32'hfff3ed5e,
                32'h1e147,
                32'h9ef6,
                32'hfffb9005,
                32'hfffa5802,
                32'hfff505fb,
                32'h8d0f0,
                32'h934d6,
                32'ha4645,
                32'hffffde49,
                32'hfffd9a24,
                32'h14497,
                32'h42001,
                32'h37292,
                32'h234f3	
		};
   
   logic [40:0][W_OUTPUT-1:0]  expected = 
	       {
		32'h5142e,
                32'h40615,
                32'hfffe08ae,
                32'h0,
                32'h0,
                32'h0,
                32'h315af,
                32'h2c875,
                32'hf21,
                32'h0,
		32'h0,
                32'h0,
                32'hab1,
                32'h2f14f,
                32'he35,
                32'h76aec,
                32'h1250f,

		32'hffff7c4e,
                32'h26f4,
                32'h27cea,
                32'hffffc907,
                32'h3d9f,
                32'hfffffb69,
                32'h12f52,
                32'h67318,
                32'h2e2b3,
                32'hb6af0,
		32'hb466,
                32'hfffb2eae,
                32'hfff61dac,
                32'h2ef82,
                32'hfffac3ec,
                32'h10eb8,
                32'h582c,
                32'hfffce144,
                32'hfffe5d71,
                32'hfff8950b,
                32'h122ef,
                32'h3f4b4,
                32'h1530f,
                32'h0,
                32'hffffecd1,
		32'h62e6,
                32'h1d640,
                32'h1b264,
                32'h53dc 		
		};
   
   logic [W_INPUT_A-1:0] a;
   logic [W_INPUT_B-1:0] b;
   logic [W_OUTPUT-1:0]  result;
   FixedFloatMult #
     (
      .W_INPUT_A(W_INPUT_A),
      .W_INPUT_B(W_INPUT_B),
      .W_OUTPUT(W_OUTPUT)
      )
   DUT_FixedFloatMult
	(
	// inputs
	.a(a),
	.b(b),
	// outputs
	.result(result)
	);
   
   task init();
      a='0;
      b='0;
   endtask // init()
   
   task reset();
   endtask // reset()
   
   initial begin
      init();
      #(4*PERIOD);

      for (int i=0; i<41; i++) begin
	 a = stored_a[i];
	 b = stored_b[i];
	 #(PERIOD);
	 if(result == expected[i]) $display("PASS: exp 0x%x, result is 0x%x", expected[i], result);
	 else $display("FAIL: exp 0x%x, result is 0x%x", expected[i], result);
	 #(2*PERIOD);
      end
      
      #(4*PERIOD) $finish;
   end
endmodule

/*
 weight=0x834, data=0x0, result=0x0
 weight=0xfffb37fa, data=0x2100, result=0xffff6237
 weight=0xfff3e868, data=0x6e00, result=0xfffacddd
 weight=0xfffc025f, data=0x2100, result=0xffff7c4e
 weight=0x4de7e, data=0x800, result=0x26f4
 weight=0x82a63, data=0x4e00, result=0x27cea
 weight=0xffff848e, data=0x7200, result=0xffffc907
 weight=0x7d32, data=0x7e00, result=0x3d9f
 weight=0xffffe115, data=0x2600, result=0xfffffb69
 weight=0x56a9a, data=0x3800, result=0x12f52
 weight=0x7dcc3, data=0xd200, result=0x67318
 weight=0xa427d, data=0x4800, result=0x2e2b3
 weight=0xf1112, data=0xc200, result=0xb6af0
 weight=0x6036a, data=0x1e00, result=0xb466
 weight=0xfff6707c, data=0x8100, result=0xfffb2eae
 weight=0xfff5a13b, data=0xf400, result=0xfff61dac
 weight=0x814aa, data=0x5d00, result=0x2ef82
 weight=0xfff3ed5e, data=0x6f00, result=0xfffac3ec
 weight=0x1e147, data=0x9000, result=0x10eb8
 weight=0x9ef6, data=0x8e00, result=0x582c
 weight=0xfffb9005, data=0xb400, result=0xfffce144
 weight=0xfffa5802, data=0x4a00, result=0xfffe5d71
 weight=0xfff505fb, data=0xad00, result=0xfff8950b
 weight=0x8d0f0, data=0x2100, result=0x122ef
 weight=0x934d6, data=0x6e00, result=0x3f4b4
 weight=0xa4645, data=0x2100, result=0x1530f
 weight=0xffffde49, data=0x0, result=0x0
 weight=0xfffd9a24, data=0x800, result=0xffffecd1
 weight=0x14497, data=0x4e00, result=0x62e6
 weight=0x42001, data=0x7200, result=0x1d640
 weight=0x37292, data=0x7e00, result=0x1b264
 weight=0x234f3, data=0x2600, result=0x53dc
*/ 


/*
 weight=0xa66c4, data=0x7d00, result=0x5142e
 weight=0x52d21, data=0xc700, result=0x40615
 weight=0xfff7e1c5, data=0x3e00, result=0xfffe08ae
 weight=0xfffd80a2, data=0x0, result=0x0
 weight=0xfffdf439, data=0x0, result=0x0
 weight=0xfffe5208, data=0x0, result=0x0
 weight=0x6bfda, data=0x7500, result=0x315af
 weight=0x4825c, data=0x9e00, result=0x2c875
 weight=0x306a1, data=0x500, result=0xf21
 weight=0x6056a, data=0x0, result=0x0
 weight=0xfffb6474, data=0x0, result=0x0
 weight=0xffff5d1c, data=0x0, result=0x0
 weight=0xab0f1, data=0x100, result=0xab1
 weight=0x3a827, data=0xce00, result=0x2f14f
 weight=0x2d77, data=0x5000, result=0xe35
 weight=0xb8235, data=0xa500, result=0x76aec
 weight=0x32f77, data=0x5c00, result=0x1250f
 */
