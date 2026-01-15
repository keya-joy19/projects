`timescale 1ns/10ps 

module IFID_tb;

    // Testbench parameters
    parameter CLK_PERIOD = 10;

    // Inputs
    logic clk;
    logic reset;
    logic IF_Flush;
    logic [63:0] pc_in;
    logic [63:0] pc_4_in;
    logic [31:0] instruction_in; 
    // Outputs
    logic [63:0] pc_out;
    logic [63:0] pc_4_out;
    logic [31:0] instruction_out;

    // Instantiate the DUT
    IFID dut (
        .clk(clk),
        .reset(reset),
        .pc(pc_in),
        .pc_4(pc_4_in),
        .instruction(instruction_in),
        .IF_Flush(IF_Flush),
        .pc_out(pc_out),
        .pc_4_out(pc_4_out),
        .instruction_out(instruction_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        reset = 1;
        IF_Flush = 1;
        pc_in = 64'b0;
        pc_4_in = 64'b0;
        instruction_in = 32'b0;

        // Apply reset
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;

        // Test case 1: Normal operation (IF_Flush = 1)
        IF_Flush = 1;
        pc_in = 64'h0000000000000010;
        pc_4_in = 64'h0000000000000020;
        instruction_in = 32'h9ABCDEF0;
        @(posedge clk);         
        @(posedge clk);
        if (pc_out !== 64'h0000000000000010 || pc_4_out !== 64'h0000000000000020 || instruction_out !== 32'h9ABCDEF0) begin
            $display("ERROR: Test case 1 failed. Expected pc_out = %h, pc_4_out = %h, instruction_out = %h; Actual pc_out = %h, pc_4_out = %h, instruction_out = %h", 
                     64'h0000000000000010, 64'h0000000000000020, 32'h9ABCDEF0, pc_out, pc_4_out, instruction_out);
        end else begin
            $display("PASS: Test case 1 (Normal, IF_Flush=1)");
        end

        // Test case 2: IF_Flush = 0 (should clear outputs)
        IF_Flush = 0;
        pc_in = 64'hFFFFFFFFFFFFFFFF;
        pc_4_in = 64'hFFFFFFFFFFFFFFFF;
        instruction_in = 32'hFFFFFFFF;
        @(posedge clk);         
        @(posedge clk);
        if (pc_out !== 64'b0 || pc_4_out !== 64'b0 || instruction_out !== 32'b0) begin
            $display("ERROR: Test case 2 failed (Flush). Expected all outputs = 0; Actual pc_out = %h, pc_4_out = %h, instruction_out = %h", 
                     pc_out, pc_4_out, instruction_out);
        end else begin
            $display("PASS: Test case 2 (IF_Flush=0, outputs cleared)");
        end

        // Test case 3: IF_Flush back to 1 (should pass values again)
        IF_Flush = 1;
        pc_in = 64'h0000000000000040;
        pc_4_in = 64'h0000000000000080;
        instruction_in = 32'h87654321;
        @(posedge clk);         
        @(posedge clk);
        if (pc_out !== 64'h0000000000000040 || pc_4_out !== 64'h0000000000000080 || instruction_out !== 32'h87654321) begin
            $display("ERROR: Test case 3 failed. Expected pc_out = %h, pc_4_out = %h, instruction_out = %h; Actual pc_out = %h, pc_4_out = %h, instruction_out = %h", 
                     64'h0000000000000040, 64'h0000000000000080, 32'h87654321, pc_out, pc_4_out, instruction_out);
        end else begin
            $display("PASS: Test case 3 (Normal, IF_Flush=1)");
        end

        // Test case 4: Reset
        reset = 1;
        @(posedge clk);         
        @(posedge clk);
        reset = 0;
        if (pc_out !== 64'b0 || pc_4_out !== 64'b0 || instruction_out !== 32'b0) begin
            $display("ERROR: Test case 4 failed (Reset). Expected all outputs = 0; Actual pc_out = %h, pc_4_out = %h, instruction_out = %h", 
                     pc_out, pc_4_out, instruction_out);
        end else begin
            $display("PASS: Test case 4 (Reset)");
        end

        $stop;
    end

endmodule
