`timescale 1ns/10ps

module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk, reset);
					 
  input logic	  [4:0]  ReadRegister1, ReadRegister2, WriteRegister;
  input logic  [63:0]	 WriteData;
	input logic 			   RegWrite, clk, reset;
  output logic [63:0]	 ReadData1, ReadData2;
	logic        [31:0]  registers;
	logic        [63:0]  regs [31:0];
	logic        [31:0]  read_values [63:0];

	dec_5_32 decoder(.write(WriteRegister), .out(registers), .enable(RegWrite));
	
	genvar j;
	generate
		for (j = 0; j < 31; j = j + 1) begin : apple
			register r(.write(WriteData), .content(regs[j]), .clk(clk), .reset(1'b0), .enable(registers[j]));
		end
		assign regs[31] = 0;
	endgenerate
	
	muxes m(.values(regs), .out(read_values));
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : orange
			mux_32_1 v1(.in(read_values[i]), .out(ReadData1[i]), .sel(ReadRegister1));
		end
	endgenerate
	
	genvar k;
	generate
		for (k = 0; k < 64; k = k + 1) begin : banana
			mux_32_1 v2(.in(read_values[k]), .out(ReadData2[k]), .sel(ReadRegister2));
		end
	endgenerate
	
endmodule
