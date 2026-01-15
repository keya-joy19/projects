module EXMEM(
    output logic [2:0]  WB_out,
    output logic [6:0]  M_out,
    output logic [63:0] ALU_out,
    output logic [63:0] Write_data_out,
    output logic [4:0]  Rd_out,
    output logic [63:0] pc_4_out,

    input  logic        clk,
    input  logic        reset,
    input  logic [2:0]  WB,
    input  logic [6:0]  M,
    input  logic [63:0] ALU,
    input  logic [63:0] Write_data,
    input  logic [4:0]  Rd,
    input logic [63:0] pc_4
);

    logic [206:0] din;
    logic [206:0] dout;

    assign din = {WB, M, ALU, Write_data, Rd, pc_4};

    reg207 EXMEM_reg (
        .q(dout),
        .d(din),
        .en(1'b1),
        .rst(reset),
        .clk(clk)
    );

    assign {WB_out, M_out, ALU_out, Write_data_out, Rd_out, pc_4_out} = dout;


endmodule
