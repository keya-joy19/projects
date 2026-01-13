// This module _
module setter (clk, reset, set, plt, up, down, left, right, red, grn, go, start, zero);
	input logic clk, reset, set, plt, start;
	input logic up, down, left, right;
	output logic [15:0][15:0] red;
	output logic [15:0][15:0] grn;
	output logic go, zero; // go is when init starts, zero is when init is done (cycle zero)
	
	logic [2:0] row, col;
	logic [15:0][15:0] tempG, tempR;
	
	enum { plant, direct, init, off, cycle_zero } ps, ns;                                                // add load demo here, separate stage, in flipflop do if (ps=demo) set certain things to 1.
	
	always_comb begin
		case (ps) 
			plant:      if (start)            ns = init; 
							    else                  ns = direct;
							 
			direct: 	  if (start)            ns = init;
							    else if(plt)         ns = plant;
							    else                 ns = direct;
							 
			init:	      if (~start)  begin    ns = cycle_zero; end     
			            else         begin    ns = init; end
			
			cycle_zero: ns = cycle_zero;
			
			off:        if (set)              ns = direct; 
			             else                 ns = off;
	
			default:    ns = off;
		endcase
	end
	
	assign go = (ps == init);
	assign zero = (ps == cycle_zero);
	
	always_ff @(posedge clk) begin
		if (reset | ns == off) begin
			ps <= off;
			tempR <= '0; 
			tempG <= '0;
			row <= 3'b000;
			col <= 3'b000;
		
		end else begin
			ps <= ns;
			
			if (ps == direct) begin
			
				if(down)  if(row == 7) row <= 0; else row <= row + 1;
				if(up)    if(row == 0) row <= 7; else row <= row - 1;
				if(left)  if(col == 7) col <= 0; else col <= col + 1;
				if(right) if(col == 0) col <= 7; else col <= col - 1;
			end
			
			tempG[row][col] <= (ps == plant | tempG[row][col] == 1'b1);
			tempR <= '0;
		  tempR[row][col] <= (ps == direct | ps == plant);
			
		end 
		
		grn <= tempG;
		red <= tempR;
	end 
	
	
	
endmodule

// testbench for ModelSim
module setter_testbench();
logic clk, reset, set, plt, up, down, left, right, go, start, zero;
logic [15:0][15:0] red, grn;

setter s(clk, reset, set, plt, up, down, left, right, red, grn, go, start, zero);

// Set up a simulated clock.
parameter CLOCK_PERIOD=100;
initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
end
// Set up the inputs to the design. Each line is a clock cycle.
initial begin
												  @(posedge clk);
	reset <= 1; set <= 0; plt <= 0; start <= 0; up <= 0; down <= 0; left <= 0; right <= 0;                       @(posedge clk);	
  reset <= 0;             repeat (4) @(posedge clk);		
	set   <= 1;             repeat (4) @(posedge clk);										
	right <= 1; set <= 0;              @(posedge clk);																													
	right <= 0; left <= 1;  repeat (2) @(posedge clk);    
	            left <= 0;  repeat (4) @(posedge clk);
	plt <= 1;                          @(posedge clk);
  plt <= 0;               repeat (4) @(posedge clk);	
	up <= 1;                           @(posedge clk);																													
	up <= 0;    down <= 1;  repeat (2) @(posedge clk);    
	            down <= 0;  repeat (4) @(posedge clk);
	plt <= 1;                          @(posedge clk);
  plt <= 0;               repeat (10)@(posedge clk);
	start <= 1;             repeat (6) @(posedge clk);
	start <= 0;             repeat (4) @(posedge clk);
	
								            
		$stop; 
	end
endmodule
