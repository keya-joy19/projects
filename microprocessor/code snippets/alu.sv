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
	
	parameter p = 0.05;
	
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

// old testbench from when I used a clock
module alu_testbench();

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out, set_flags, clk;
	
	alu dut(A, B, cntrl, result, negative, zero, overflow, carry_out, set_flags, clk);
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=1000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
															       @(posedge clk);
		 A <= 64'h7; B <= 64'h1; set_flags <= 0;   repeat (2) @(posedge clk);	
		 cntrl <= 000;             repeat (4) @(posedge clk);	
		 cntrl <= 010;             repeat (4) @(posedge clk);	
		 cntrl <= 011;             repeat (4) @(posedge clk);	
		 cntrl <= 100;             repeat (4) @(posedge clk);
		 cntrl <= 101;             repeat (4) @(posedge clk);	 
		 cntrl <= 110;             repeat (4) @(posedge clk);	
		 A <= 64'h7FFFFFFFFFFFFFFF; B <= 64'h1;   repeat (2) @(posedge clk);	
		 cntrl <= 000;             repeat (4) @(posedge clk);	
		 cntrl <= 010;             repeat (4) @(posedge clk);	
		 cntrl <= 011;             repeat (4) @(posedge clk);	
		 A <= 64'b0; B <= 64'b0;   repeat (2) @(posedge clk);
		 cntrl <= 000;             repeat (4) @(posedge clk);	
		 cntrl <= 010; set_flags <= 1;         repeat (4) @(posedge clk);	
		 A <= 64'b1; B <= 64'b1;   repeat (2) @(posedge clk);
		 cntrl <= 011;             repeat (4) @(posedge clk);
		 set_flags <= 0;           repeat (4) @(posedge clk);
		 A <= 64'h2;               repeat (4) @(posedge clk);
		
		 
                                                    
			$stop; 
		end
endmodule
