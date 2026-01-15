`timescale 1ns/10ps 

/*
ForwardA = 00 : first ALU from regile
ForwardA = 10 : first ALU forwarded from prev ALU res
ForwardA = 01 : first ALU forwarded from datamem or earlier ALU res
ForwardB = 00 : second ALU from regfile
ForwardB = 10 : second ALU forwarded from prev ALU res
ForwardB = 01 : second ALU forwarded from datamem or earlier ALU res
*/

module forwarding_unit(Rn, Rm, Rd_EXMEM, Rd_MEMWB, WB_MEM, WB, ForwardA, ForwardB, ForwardC, ForwardCBZ, ForwardBR, ALUSrc_ex, MemWrite_ex, RegWrite_mem, RegWrite_wb, RegWrite_ex, Rd_ex, Rd_mem, Rd_wb, Rd_id, CBZ_id, BR_id);

	input  logic [4:0] Rn, Rm, Rd_EXMEM, Rd_MEMWB;
	input  logic [4:0] Rd_id, Rd_ex, Rd_mem, Rd_wb;
	input  logic       WB_MEM, WB; // RegWrite
	input  logic       ALUSrc_ex;  // if using immediate, =1
	input logic       MemWrite_ex, RegWrite_mem, RegWrite_wb, RegWrite_ex, CBZ_id, BR_id;
	output logic [1:0] ForwardA, ForwardB, ForwardC, ForwardCBZ, ForwardBR;
	
	logic [8:0] inputs;
	logic [4:0] inputs_stur, inputs_cbz, inputs_br;
	logic dn_eq_EX, dm_eq_EX, dn_eq_MEM, dm_eq_MEM, d_EXMEM_31, d_MEMWB_31;
	logic neq1, neq2;
	logic Eq_ex_mem, Eq_ex_wb, Eq_id_ex, Eq_id_mem;
	
	parameter p = 0.05;
	
	not #p neq01 (neq1, d_EXMEM_31);
	not #p neq02 (neq2, d_MEMWB_31);
	
	equal_reg e1(Rd_EXMEM, Rn, dn_eq_EX);
	equal_reg e2(Rd_MEMWB, Rn, dn_eq_MEM);
	equal_reg e3(Rd_EXMEM, Rm, dm_eq_EX);
	equal_reg e4(Rd_MEMWB, Rm, dm_eq_MEM);
	equal_reg e5(Rd_EXMEM, 5'b11111, d_EXMEM_31);
	equal_reg e6(Rd_MEMWB, 5'b11111, d_MEMWB_31);
	equal_reg e7(Rd_ex, Rd_mem, Eq_ex_mem);
	equal_reg e8(Rd_ex, Rd_wb, Eq_ex_wb);
	equal_reg e9(Rd_id, Rd_ex, Eq_id_ex);
	equal_reg e10(Rd_id, Rd_mem, Eq_id_mem);


	// issue: Rm is only relevant for ADDs and SUBs, ADDI its not relevant
	// want to check aluSrC of Ex. if it is 1, we don't care to forward B?
	
	assign inputs = { ALUSrc_ex, WB_MEM, WB, dn_eq_EX, dm_eq_EX, dn_eq_MEM, dm_eq_MEM, neq1, neq2};
	// 8: ALUSrc from   EX (IDEX)
	// 7: RegWrite from EXMEM
	// 6: RegWrite from MEMWB
	// 5: Rd = Rn, Rd_EXMEM
	// 4: Rd = Rm, Rd_EXMEM
	// 3: Rd = Rn, Rd_MEMWB
	// 2: Rd = Rm, Rd_MEMWB
	// 1: Rd != 31 from EXMEM
	// 0: Rd != 31 from MEMWB

	assign inputs_stur = { RegWrite_wb, Eq_ex_wb, RegWrite_mem, Eq_ex_mem, MemWrite_ex };

	//0: MemWrite_ex = 1, want 2 store
	//1: Rd_mem == Rd_ex
	//2: RegWrite_mem == 1 Then forwardC=10 : forward from alu_mem
	//3: Rd_wb  == Rd_ex
	//4: RegWrite_wb  == 1 Then forwardC=01 : forward from alu_wb

	parameter [4:0] C10 = 5'b??111, C01 = 5'b11??1;

	assign inputs_cbz = { Eq_id_ex, RegWrite_ex, Eq_id_mem, RegWrite_mem, CBZ_id };
	assign inputs_br  = { Eq_id_ex, RegWrite_ex, Eq_id_mem, RegWrite_mem, BR_id  };
	parameter [4:0] CBZ10 = 5'b11??1, CBZ01 = 5'b??111;

	parameter [4:0] BR10 = 5'b11??1, BR01 = 5'b??111;


	parameter [9:0] A10 = 8'b1?1???1?, // EXMEM.regWrite, EXMEM.rd != 31, Rd.EXMEM = Rn
						 A01 = 8'b?1??1??1, // MEMWB.regWrite, MEMWB.rd != 31, Rd.MEMWB = Rn 
						 B10 = 9'b01??1??1?, // EXMEM.regWrite, EXMEM.rd != 31, Rd.EXMEM = Rm
						 B01 = 9'b0?1???1?1; // MEMWB.regWrite, MEMWB.rd != 31, Rd.MEMWB = Rm 
						   

	always_comb begin
		 ForwardA = 2'b00;
		 casez (inputs[7:0])
			  A10:     ForwardA = 2'b10;	
			  A01:     ForwardA = 2'b01;	
			  default: ForwardA = 2'b00;
		 endcase
	end
	always_comb begin
		 ForwardB = 2'b00;
		 casez (inputs)
			  B10:     ForwardB = 2'b10;
			  B01:     ForwardB = 2'b01; 
			  default: ForwardB = 2'b00;
		 endcase
	end
	always_comb begin
		 ForwardC = 2'b00;
		 casez (inputs_stur)
			  C10:     ForwardC = 2'b10;
			  C01:     ForwardC = 2'b01; 
			  default: ForwardC = 2'b00;
		 endcase
	end
	always_comb begin
		 ForwardCBZ= 2'b00;
		 casez (inputs_cbz)
			  CBZ10:     ForwardCBZ = 2'b10;
			  CBZ01:     ForwardCBZ = 2'b01; 
			  default: ForwardCBZ = 2'b00;
		 endcase
	end
	always_comb begin
		 ForwardBR= 2'b00;
		 casez (inputs_br)
			  BR10:     ForwardBR = 2'b10;
			  BR01:     ForwardBR = 2'b01; 
			  default: ForwardBR = 2'b00;
		 endcase
	end
endmodule
