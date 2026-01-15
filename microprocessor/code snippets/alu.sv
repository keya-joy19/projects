`timescale 1ns/10ps 

module alu (A, B, cntrl, result, negative, zero, overflow, carry_out, set_flags, clk);

	input  logic		[63:0]	A, B;
	input  logic		[2:0]   cntrl;
	input  logic                set_flags, clk;
	output logic		[63:0]	result;
	output logic			    negative, zero, overflow, carry_out;
	
	logic [63:0] c_out;
	logic [1:0] sub;
	logic [63:0] b;
	logic negative_temp, carry_out_temp, overflow_temp, zero_temp;
	logic [3:0] muxout;
	
	parameter p = 0.05; // gate delay
	
	not #p n1(sub[1], cntrl[2]);
	and #p a1(sub[0], sub[1], cntrl[1], cntrl[0]);
	
	// subtraction: flip B if cntrl is sub (011)
	//sub B B+
	//0   0 0
	//0   1 1
	//1   0 1
	//1   1 0	
	genvar k;
	generate
		for (k = 0; k < 64; k = k + 1) begin : kiwi
			xor #p x1(b[k], sub, B[k]);
		end
	endgenerate
	
	Bit first (.A(A[0]), .B(b[0]), .C(sub[0]), .cntrl(cntrl), .c(c_out[0]), .r(result[0])); // add 1 for 2's complement 
	
	genvar i;
	generate
		for (i = 1; i < 64; i = i + 1) begin : peach
			Bit bits (.A(A[i]), .B(b[i]), .C(c_out[i-1]), .cntrl(cntrl), .c(c_out[i]), .r(result[i]));
		end
	endgenerate
	

	assign negative_temp = result[63]; // 64th bit is 1
	assign carry_out_temp = c_out[63]; // last carry
	xor #p overf(overflow_temp, c_out[62], c_out[63]); // last two carries are not equal
	zero_check z(.r(result), .zero(zero_temp)); // zero check!

	// enabled D_FFs to change flags only if flags are set
	D_FF v0(negative, muxout[0], 1'b0, clk);
	mux2_1 mn (.a(negative), .b(negative_temp), .sel(set_flags), .y(muxout[0]));

	D_FF v1(overflow, muxout[1], 1'b0, clk);
	mux2_1 mn1 (.a(overflow), .b(overflow_temp), .sel(set_flags), .y(muxout[1]));

	D_FF v2(carry_out, muxout[2], 1'b0, clk);
	mux2_1 mn2 (.a(carry_out), .b(carry_out_temp), .sel(set_flags), .y(muxout[2]));

	D_FF v3(zero, muxout[3], 1'b0, clk);
	mux2_1 mn3 (.a(zero), .b(zero_temp), .sel(set_flags), .y(muxout[3]));
		

endmodule


// Gates for ALU operations; I used boolean algebra to simplify the logic needed to fit the 
//                           operations based on the control values, shown below
module Bit (A, B, C, cntrl, r, c);
	// cntrl	    Operation					Notes:
	// 000:			result = B					value of overflow and carry_out unimportant
	// 010:			result = A + B
	// 011:			result = A - B
	// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
	// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
	// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

	input  logic		         A, B, C;
	input  logic		[2:0]		cntrl;
	output logic		        	r, c; // result, carry of this bit
	logic [11:0] out;
	
	parameter p = 0.05;

	not #p c1(out[4], cntrl[1]); 
	not #p c2(out[5], cntrl[2]);
	
	xor #p x0(out[0], A, B);
	xor #p x1(out[1], cntrl[0], cntrl[1]);
	and #p a0(out[2], out[0], out[1], cntrl[2]); // A xor B, C1 xor C0, C2
	and #p a1(out[3], A, B, cntrl[2], out[4]); // A B nC1 C2
	and #p a2(out[6], out[4], out[5], B); // nC2 nC1 B
	xor #p x2(out[10], C, out[0]);
	and #p a5(out[11], out[5], cntrl[1], out[10]); // nC2 C1 and (A X (B X C))
	
	or  #p R (r, out[2], out[3], out[6], out[11]); // result
	
	and #p a3(out[7], C, out[0]); // C and (A xor B)
	and #p a4(out[8], A, B); // A and B
	or  #p o0(out[9], out[7], out[8]); // AC or BC or AB
	and #p ca (c, cntrl[1], out[5], out[9]); // carry (nC2, C1, AC+BC+AB)
	
endmodule
