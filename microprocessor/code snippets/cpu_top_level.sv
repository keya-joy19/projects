`timescale 1ns/10ps 

module cpu (clk, reset);
	
	input logic clk, reset;
	// parameters
	parameter p = 0.05;
	logic clk_neg;
	not #p no1  (clk_neg, clk);
	
	// Rd.EXMEM = Rm

	// flags
	logic        negative, zero, overflow, carry_out, reg_zero;

	// controls
	logic        RegWrite, MemWrite, MemRead, branch, Reg2Loc, Mem2Reg, ALUSrc, set_flags;
	logic        uncond, CBZ, BR, BLT, use_se_adder, BL; 
	logic        PCWrite, IFIDWrite, control_mux, reset_ifid, reset_pc;
	logic        IF_Flush, use_blt, Flush, n_use_blt;

    not #p no2  (n_use_blt, use_blt);
	//and #p fl (Flush, IF_Flush, n_use_blt); // 0 when IF_Flush is 0 or n_use_blt is 0
	// IF
	logic [63:0] instr_address, next_address, incr_address; // PC output, input, output+4
	logic [31:0] instruction;   // feeds into registers, Control, mux1
	
	// ID
	logic [63:0] pc_ID, out_pc_helper, pc_4_id;
	logic [31:0] instr_ID;
	logic [63:0] Read1, Read2, input_zero, ReadBR;  // output from registers
	logic [63:0] WriteData;     // input for reg
	logic [4:0]  ReadRegister2, WriteRegister; // input for reg
	logic [63:0] sign_ex;       // sign-extended instruction
	logic [4:0] Rm_id, Rn_id, Rd_id;
				assign Rm_id = instr_ID[20:16];
				assign Rn_id = instr_ID[9:5];
				assign Rd_id = instr_ID[4:0];
	logic [2:0]  alu_control;   // chooses add/sub/etc for ALU
	logic [1:0]  ALUOp;         // output control to alucontrol
	logic [1:0] immSel;       // for control and sign extend

	logic [5:0] Ex_id, Ex_id_bm; 
				assign Ex_id_bm = { set_flags, immSel[1], immSel[0], ALUSrc, ALUOp[1], ALUOp[0] }; // bm = before mux
	logic [6:0] Mem_id, Mem_id_bm;
				assign Mem_id_bm = { BLT, BR, CBZ, uncond, branch, MemWrite, MemRead}; 
	logic [2:0] Wb_id, Wb_id_bm; 
				//assign Wb_id_bm = 2'b11;
				assign Wb_id_bm = {BL, RegWrite, Mem2Reg};  // MOVED BL to Wb
	logic [1:0] ForwardCBZ, ForwardBR;

	// EX
	logic [4:0] Rm_ex, Rn_ex, Rd_ex;
	logic [5:0] Ex;
	logic [63:0] Read1_ex, Read2_ex, imm_ex, ReadC_ex, load_use;
	logic [1:0] ForwardA, ForwardB, ForwardC;
	logic [63:0] alu_result, alu_B, alu_A, pc_4_ex;
	logic [6:0] Mem_ex; 
	logic [2:0] Wb_ex; 

	// MEM
	logic [4:0] Rd_mem;
	logic [63:0] datamem_read, alu_mem, pc_4_mem, Read2_mem, ReadC_mem;
	logic [6:0] Mem;
	logic [2:0] Wb_mem;

	// WB
	logic [4:0] Rd_wb;
	logic [63:0] datamem_wb, alu_wb, pc_4_wb;
	logic [2:0] Wb;


	// INSTRUCTION FETCH (pc, instructmem)
		pc pcounter(.in(next_address), .out(instr_address), .out_4(incr_address), .clk(clk), .reset(reset)); // CHANGE TO reset_pc for hazard module
		instructmem inst(.clk(clk), .instruction(instruction), .address(instr_address));
		// pc input mux
			logic sel1;
			or #p or1(sel1, BR, use_se_adder); 

			genvar k;
				generate
				for (k = 0; k < 64; k = k + 1) begin : grapefruit
					mux_3_2 mux32(.in_11(ReadBR[k]), .in_10(out_pc_helper[k]), .in_0(incr_address[k]), .out(next_address[k]), .sel1(sel1), .sel0(BR));
				end
			endgenerate
	
	// INSTRUCTION DECODE (regfile, control, sign extend, hazard detection, alu control, cbz check, pc helper)
		regfile rf(.clk(clk_neg), .reset(reset), .ReadData1(Read1), .ReadData2(Read2), .WriteRegister(WriteRegister), .ReadRegister1(Rn_id),  .WriteData(WriteData), .ReadRegister2(ReadRegister2), .RegWrite(Wb[1]));	 
		control c1(.opcode(instr_ID[31:21]), .MemRead(MemRead), .MemWrite(MemWrite), .RegWrite(RegWrite), .Branch(branch), .MemtoReg(Mem2Reg), .Reg2Loc(Reg2Loc), .immSel(immSel), .ALUSrc(ALUSrc), .ALUOp(ALUOp), 
						.set_flags(set_flags), .uncond(uncond), .CBZ(CBZ), .BR(BR), .BLT(BLT), .BL(BL), .IF_Flush(IF_Flush), .reg_zero(reg_zero), .use_blt(use_blt));
		SignExtender se(.instruction(instr_ID), .immSel(immSel), .imm(sign_ex));
		aluControl aluc(.opcode(instr_ID[31:21]), .ALUOp(ALUOp), .Operation(alu_control));

		alu_input_mux muxCBZ (.out(input_zero), .in_00(Read2), .in_10(alu_result), .in_01(load_use), .sel(ForwardCBZ)); //ForwardCBZ
		alu_input_mux muxBR  (.out(ReadBR), .in_00(Read2), .in_10(alu_result), .in_01(load_use), .sel(ForwardBR)); //ForwardBR

		zero_check zr (.zero(reg_zero), .r(input_zero));
		pc_helper help2 (.in(pc_ID), .sign_ex(sign_ex), .out(out_pc_helper));
		logic [2:0] alu_c_temp, alu_control_ex; 
		


	// EXECUTE Ex[]
		logic [63:0] srcB;
		genvar g;
			generate
				for (g = 0; g < 64; g = g + 1) begin : cantaloupe
					mux2_1 mu(.a(Read2_ex[g]), .b(imm_ex[g]), .sel(Ex[2]), .y(srcB[g])); //Ex[2] = ALUSrc
				end
			endgenerate

		alu_input_mux muxSTORE (.out(ReadC_ex), .in_00(Read2_ex), .in_10(load_use), .in_01(alu_wb), .sel(ForwardC)); //ForwardC
			

		alu_input_mux muxA (.out(alu_A), .in_00(Read1_ex), .in_10(alu_mem), .in_01(WriteData), .sel(ForwardA)); //ForwardA
		alu_input_mux muxB (.out(alu_B), .in_00(srcB), .in_10(alu_mem), .in_01(WriteData), .sel(ForwardB)); // ForwardB

		alu al(.A(alu_A), .B(alu_B), .cntrl(alu_control_ex), .result(alu_result), .set_flags(Ex[5]), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out), .clk(clk_neg));

	// MEMORY
		datamem d(.clk(clk_neg), .write_data(ReadC_mem), .address(alu_mem), .write_enable(Mem[1]), .read_enable(Mem[0]), .xfer_size(4'b1000), .read_data(datamem_read));
	
	// WRITEBACK
		// mux for WriteRegister input
			mux2_1 m9(.a(Rd_wb[4]), .b(1'b1), .sel(Wb[2]), .y(WriteRegister[4])); // BL at write back
			mux2_1 m8(.a(Rd_wb[3]), .b(1'b1), .sel(Wb[2]), .y(WriteRegister[3]));
			mux2_1 m7(.a(Rd_wb[2]), .b(1'b1), .sel(Wb[2]), .y(WriteRegister[2]));
			mux2_1 m6(.a(Rd_wb[1]), .b(1'b1), .sel(Wb[2]), .y(WriteRegister[1]));
			mux2_1 m5(.a(Rd_wb[0]), .b(1'b0), .sel(Wb[2]), .y(WriteRegister[0]));

		// mux for Register WriteData input
			logic nBL;
			not #p nbl (nBL, Wb[2]); // BL at write back
			genvar j;
			generate
				for (j = 0; j < 64; j = j + 1) begin : blueberry
					mux_3_2 datm (.in_11(datamem_wb[j]), .in_10(alu_wb[j]), .in_0(pc_4_wb[j]), .out(WriteData[j]), .sel1(nBL), .sel0(Wb[0])); //Mem2Reg want sel to b 00 
				end 
			endgenerate	
	
	// Pipeline modules 

	forwarding_unit fu (.Rn(Rn_ex), .Rm(Rm_ex), .Rd_EXMEM(Rd_mem), .Rd_MEMWB(Rd_wb), .WB_MEM(Wb_mem[1]), .WB(Wb[1]), .ForwardA(ForwardA), .ForwardB(ForwardB), .ALUSrc_ex(Ex[2]),
	                    .ForwardC(ForwardC), .MemWrite_ex(Mem_ex[1]), .RegWrite_mem(Wb_mem[1]), .RegWrite_wb(Wb[1]), .Rd_ex(Rd_ex), .Rd_mem(Rd_mem), .Rd_wb(Rd_wb),
						.ForwardCBZ(ForwardCBZ), .RegWrite_ex(Wb_ex[1]), .Rd_id(Rd_id), .CBZ_id(Mem_id[4]), 
						.ForwardBR(ForwardBR), .BR_id(Mem_id[5])); 

	//hazard_unit hu (.PCWrite(PCWrite), .IFIDWrite(IFIDWrite), .IDEXMemRead(Mem_ex[0]), .Rn(Rn_id), .Rm(Rm_id), .Rd(Rd_ex), .control_mux(control_mux));

	IFID ifid (.clk(clk), .reset(reset), .pc(instr_address), .instruction(instruction), .pc_out(pc_ID), .instruction_out(instr_ID), .pc_4(incr_address), .pc_4_out(pc_4_id), .IF_Flush(Flush)); // CHANGE TO reset_ifid

	IDEX idex (.clk(clk), .reset(reset), .ReadData1(Read1), .ReadData2(Read2), .imm(sign_ex), .Rm(Rm_id), .Rn(Rn_id), .Rd(Rd_id), 
	           .imm_out(imm_ex), .ReadData1_out(Read1_ex), .ReadData2_out(Read2_ex), .Rm_out(Rm_ex), .Rn_out(Rn_ex), .Rd_out(Rd_ex),
			   .WB(Wb_id), .M(Mem_id), .EX(Ex_id), .WB_out(Wb_ex), .M_out(Mem_ex), .EX_out(Ex), .pc_4(pc_4_id), .pc_4_out(pc_4_ex));

	EXMEM exmem (.clk(clk), .reset(reset), .ALU(alu_result), .ALU_out(alu_mem), .Write_data(ReadC_ex), .Write_data_out(ReadC_mem), .Rd(Rd_ex), .Rd_out(Rd_mem),  
	           .WB(Wb_ex), .WB_out(Wb_mem), .M(Mem_ex), .M_out(Mem), .pc_4(pc_4_ex), .pc_4_out(pc_4_mem));

	MEMWB memwb (.clk(clk), .reset(reset), .ALU(alu_mem), .ALU_out(alu_wb), .ReadData(datamem_read), .ReadData_out(datamem_wb), .Rd(Rd_mem), .Rd_out(Rd_wb), 
	             .WB(Wb_mem), .WB_out(Wb), .pc_4(pc_4_mem), .pc_4_out(pc_4_wb));
    
	
	  // misc need a mux to decide btwn alu mem and datamem_read, if mem[MemRead] =1, pick datamem_read
		genvar h;
		generate
			for (h = 0; h < 64; h = h + 1) begin : soursop
				mux2_1 lu (.a(alu_mem[h]), .b(datamem_read[h]), .sel(Mem[0]), .y(load_use[h])); // sel = MemRead (if its a load instruction)
			end
		endgenerate
	
		// neg edge clock for register, alu (set flags only), datamem, instructmem
		
		// resetsWb
		logic n_Flush;
		not #p n7  (n_Flush, Flush);
		or  #p or2 (reset_ifid, reset, IFIDWrite, n_Flush); // reset, hazard reset, or flush reset (must b 1)
		or  #p or3 (reset_pc,   reset, PCWrite);

		// PC selection
		logic use_cbz, blt_check; //, use_blt;
		and #p cbz (use_cbz, Mem_id[4], reg_zero);        // CBZ from ID and reg_zero (if reg hasn't updated yet, forward??)
		xor #p blt (blt_check, negative, overflow);      
		and #p ugh (use_blt, Mem_id[6], blt_check);       // B.LT from EX
		or  #p u (use_se_adder, Mem_id[3], use_cbz, use_blt); // B/BL from ID: use sign extension adder if CBZ or BLT require branching or B/BL is the command
		nor #p flu (Flush, use_cbz, use_blt); // if either is true Flush should be 0

		// mux for Register ReadRegister2 input
		mux2_1 m4(.a(instr_ID[20]), .b(instr_ID[4]), .sel(Reg2Loc), .y(ReadRegister2[4]));
		mux2_1 m3(.a(instr_ID[19]), .b(instr_ID[3]), .sel(Reg2Loc), .y(ReadRegister2[3]));
		mux2_1 m2(.a(instr_ID[18]), .b(instr_ID[2]), .sel(Reg2Loc), .y(ReadRegister2[2]));
		mux2_1 m1(.a(instr_ID[17]), .b(instr_ID[1]), .sel(Reg2Loc), .y(ReadRegister2[1]));
		mux2_1 m0(.a(instr_ID[16]), .b(instr_ID[0]), .sel(Reg2Loc), .y(ReadRegister2[0]));

		// mux for IDEX control input based on hazard detection
		assign control_mux = 1'b1; // HAZARD
		mux2_1 ma0(.a(1'b0), .b(Ex_id_bm[0]), .sel(control_mux), .y(Ex_id[0]));
		mux2_1 ma1(.a(1'b0), .b(Ex_id_bm[1]), .sel(control_mux), .y(Ex_id[1]));
		mux2_1 ma2(.a(1'b0), .b(Ex_id_bm[2]), .sel(control_mux), .y(Ex_id[2]));
		mux2_1 ma3(.a(1'b0), .b(Ex_id_bm[3]), .sel(control_mux), .y(Ex_id[3]));
		mux2_1 ma4(.a(1'b0), .b(Ex_id_bm[4]), .sel(control_mux), .y(Ex_id[4]));
		mux2_1 ma5(.a(1'b0), .b(Ex_id_bm[5]), .sel(control_mux), .y(Ex_id[5]));

		mux2_1 mb0(.a(1'b0), .b(Mem_id_bm[0]), .sel(control_mux), .y(Mem_id[0]));
		mux2_1 mb1(.a(1'b0), .b(Mem_id_bm[1]), .sel(control_mux), .y(Mem_id[1]));
		mux2_1 mb2(.a(1'b0), .b(Mem_id_bm[2]), .sel(control_mux), .y(Mem_id[2]));
		mux2_1 mb3(.a(1'b0), .b(Mem_id_bm[3]), .sel(control_mux), .y(Mem_id[3]));
		mux2_1 mb4(.a(1'b0), .b(Mem_id_bm[4]), .sel(control_mux), .y(Mem_id[4]));
		mux2_1 mb5(.a(1'b0), .b(Mem_id_bm[5]), .sel(control_mux), .y(Mem_id[5]));
		mux2_1 mb6(.a(1'b0), .b(Mem_id_bm[6]), .sel(control_mux), .y(Mem_id[6]));
		
		mux2_1 mc7(.a(1'b0), .b(Wb_id_bm[2]), .sel(control_mux), .y(Wb_id[2])); // previously BL in mem
		mux2_1 mc0(.a(1'b0), .b(Wb_id_bm[0]), .sel(control_mux), .y(Wb_id[0]));
		mux2_1 mc1(.a(1'b0), .b(Wb_id_bm[1]), .sel(control_mux), .y(Wb_id[1]));

		mux2_1 md0(.a(1'b0), .b(alu_control[0]), .sel(control_mux), .y(alu_c_temp[0]));
		mux2_1 md1(.a(1'b0), .b(alu_control[1]), .sel(control_mux), .y(alu_c_temp[1]));
		mux2_1 md2(.a(1'b0), .b(alu_control[2]), .sel(control_mux), .y(alu_c_temp[2]));

		D_FF d1 (.q(alu_control_ex[0]), .d(alu_c_temp[0]), .clk(clk), .reset(reset));
		D_FF d2 (.q(alu_control_ex[1]), .d(alu_c_temp[1]), .clk(clk), .reset(reset));
		D_FF d3 (.q(alu_control_ex[2]), .d(alu_c_temp[2]), .clk(clk), .reset(reset));

		

endmodule
