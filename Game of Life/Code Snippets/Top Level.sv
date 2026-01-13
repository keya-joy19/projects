// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (KEY, SW, LEDR, GPIO_1, CLOCK_50);
    
	  output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;
	 
// Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	  logic [31:0] clk;
	  logic SYSTEM_CLOCK;
	 
	  clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
	 
	  assign SYSTEM_CLOCK = clk[14]; // 1526 Hz clock signal	 
	 
// Set up LED board driver
	  logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	  logic RST;                   // reset - toggle this on startup
	 
	  assign RST = SW[0];
	 
// Standard LED Driver instantiation 
	  LEDDriver Driver (.CLK(SYSTEM_CLOCK), .RST, .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
	 
	
	  assign life_clock = CLOCK_50;
	 
	// flip flops and modification
  	reg R1; always @(posedge CLOCK_50) R1 <= ~KEY[2]; // left
	  reg L1; always @(posedge CLOCK_50) L1 <= ~KEY[3]; // right
	  reg U1; always @(posedge CLOCK_50) U1 <= ~KEY[1]; // up
	  reg D1; always @(posedge CLOCK_50) D1 <= ~KEY[0];
	  reg P1; always @(posedge CLOCK_50) P1 <= SW[8];
	
	  reg R_mod, L_mod, U_mod, D_mod, P_mod;
	
	
	  modifier mod(.up(U1), .down(D1), .right(R1), .left(L1), .u_m(U_mod), 
	               .d_m(D_mod), .r_m(R_mod), .l_m(L_mod), .plant(P1), .p_m(P_mod), .clk(life_clock));
	
	
	// Game of Life
	  game_of_life2 game(.reset(SW[0]), .juice(SW[9]), .plant(P_mod), .start(SW[7]), .clk(life_clock), 
	                   .up(U_mod), .down(D_mod), .left(L_mod), .right(R_mod), 
						         .r(RedPixels), .g(GrnPixels), .LEDR(LEDR));
	 
endmodule


// testbench for ModelSim
module DE1_SoC_testbench();

  logic CLOCK_50;
	logic [35:0] GPIO_1;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [9:0] LEDR;

  DE1_SoC dut (KEY, SW, LEDR, GPIO_1, CLOCK_50);
 
		// Set up a simulated clock.
		parameter CLOCK_PERIOD=100;
		initial begin
			CLOCK_50 <= 0;
			forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
		end
		// Set up the inputs to the design. Each line is a clock cycle.
		initial begin
														                                                                                @(posedge CLOCK_50);
			SW[0] <= 1; SW[9] <= 0; SW[8] <= 0; SW[7] <= 0; KEY[3] <= 0; KEY[2] <= 0; KEY[1] <= 0; KEY[0] <= 0;   @(posedge CLOCK_50);	
			SW[0] <= 0;                                                                                repeat (4) @(posedge CLOCK_50);									
			KEY[2] <= 1; SW[9] <= 0;                                                                   repeat (4) @(posedge CLOCK_50);																													
			KEY[2] <= 0; KEY[3] <= 1;                                                                  repeat (2) @(posedge CLOCK_50);    
			KEY[3] <= 0;                                                                               repeat (4) @(posedge CLOCK_50);
			KEY[2] <= 0; KEY[3] <= 1;                                                                  repeat (2) @(posedge CLOCK_50);    
			KEY[3] <= 0;                                                                               repeat (4) @(posedge CLOCK_50);
			KEY[2] <= 0; KEY[3] <= 1;                                                                  repeat (2) @(posedge CLOCK_50);    
			KEY[3] <= 0;                                                                               repeat (4) @(posedge CLOCK_50);
			SW[8] <= 1;                                                                                           @(posedge CLOCK_50);
			SW[8] <= 0;                                                                                repeat (4) @(posedge CLOCK_50);	
			KEY[0] <= 1;    KEY[1] <= 1 ;                                                                         @(posedge CLOCK_50);																													
			KEY[0] <= 0;    KEY[1] <= 0;                                                               repeat (2) @(posedge CLOCK_50);    
			KEY[0] <= 1;                                                                               repeat (4) @(posedge CLOCK_50);
			KEY[0] <= 0;                                                                                          @(posedge CLOCK_50);
			SW[8] <= 1;                                                                                repeat (4) @(posedge CLOCK_50);
			KEY[0] <= 1;                                                                               repeat (4) @(posedge CLOCK_50);
			KEY[0] <= 0;                                                                                          @(posedge CLOCK_50);
			SW[8] <= 1;                                                                                repeat (4) @(posedge CLOCK_50);
			
			
			SW[7] <= 1;                                                                                repeat (6) @(posedge CLOCK_50);
			SW[7] <= 0;                                                                               repeat (10) @(posedge CLOCK_50);
			SW[0] <= 1;                                                                                repeat (4) @(posedge CLOCK_50);
														
				$stop; 
			end
endmodule
