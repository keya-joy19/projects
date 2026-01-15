`timescale 1ns/10ps 

module hazard_unit(PCWrite, IFIDWrite, IDEXMemRead, Rn, Rm, Rd, control_mux);

	input  logic [4:0] Rn, Rm, Rd;
	input  logic       IDEXMemRead;
	output logic       PCWrite, IFIDWrite, control_mux;

	parameter p = 0.05;
	
	logic equal, eq1, eq2, Disable;
	
	// If the instruction is load (IDEXMemRead) and rn or rm = rd, then disable PC, IFID, 
	//    and the mux (mux will either send over all controls or all zeros)

	equal_reg equ1(Rn, Rd, eq1);
	equal_reg equ2(Rm, Rd, eq2);
	
	or  #p eit (equal, eq1, eq2); // rn = rd or rm = rd
	and #p dis (Disable, equal, IDEXMemRead);

	always_comb begin
		PCWrite     = 1'b0;
		IFIDWrite   = 1'b0;
		control_mux = 1'b1;
		 
		case (Disable)
			1'b0: begin
				PCWrite     = 1'b0;
				IFIDWrite   = 1'b0;
				control_mux = 1'b1;
					end
			1'b1: begin
				PCWrite     = 1'b1;
				IFIDWrite   = 1'b1;
				control_mux = 1'b0;
					end

		endcase
	end
	
endmodule
