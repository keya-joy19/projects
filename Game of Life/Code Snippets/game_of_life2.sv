module game_of_life2 (clk, reset, juice, start, plant, up, down, left, right, g, r, LEDR);
	input logic clk, reset, juice, start, plant, up, down, left, right;
	output logic [9:0] LEDR;
	output logic [15:0][15:0] g, r;
	
	
	logic sig;
	logic run;
	logic go;
	logic cycle_zero;

	assign LEDR[0] = go;
	assign LEDR[1] = sig;
	assign LEDR[2] = run;
	
	logic [15:0][15:0] g_set, r_set, g_run;
	
	setter s(.clk(clk), .set(sig), .reset(reset), .red(r_set), .grn(g_set),
				   .left(left), .right(right), .up(up), .down(down), .plt(plant), .go(go), .start(start), .zero(cycle_zero));
			
	
	unit U00 (.clk(clk), .run(run), .N(1'b0), .E(1'b0), 		  .S(g_run[1][0]), .W(g_run[0][1]), .NE(1'b0), .NW(1'b0), .SE(1'b0), 		 .Sw(g_run[1][1]), .led(g_run[0][0]), .tick(g_set[0][0]), .go(go), .reset(reset));
	unit U01 (.clk(clk), .run(run), .N(1'b0), .E(g_run[0][0]), .S(g_run[1][1]), .W(g_run[0][2]), .NE(1'b0), .NW(1'b0), .SE(g_run[1][0]), .Sw(g_run[1][2]), .led(g_run[0][1]), .tick(g_set[0][1]), .go(go), .reset(reset));
	unit U02 (.clk(clk), .run(run), .N(1'b0), .E(g_run[0][1]), .S(g_run[1][2]), .W(g_run[0][3]), .NE(1'b0), .NW(1'b0), .SE(g_run[1][1]), .Sw(g_run[1][3]), .led(g_run[0][2]), .tick(g_set[0][2]), .go(go), .reset(reset));
	unit U03 (.clk(clk), .run(run), .N(1'b0), .E(g_run[0][2]), .S(g_run[1][3]), .W(g_run[0][4]), .NE(1'b0), .NW(1'b0), .SE(g_run[1][2]), .Sw(g_run[1][4]), .led(g_run[0][3]), .tick(g_set[0][3]), .go(go), .reset(reset));
	unit U04 (.clk(clk), .run(run), .N(1'b0), .E(g_run[0][3]), .S(g_run[1][4]), .W(g_run[0][5]), .NE(1'b0), .NW(1'b0), .SE(g_run[1][3]), .Sw(g_run[1][5]), .led(g_run[0][4]), .tick(g_set[0][4]), .go(go), .reset(reset));
	unit U05 (.clk(clk), .run(run), .N(1'b0), .E(g_run[0][4]), .S(g_run[1][5]), .W(g_run[0][6]), .NE(1'b0), .NW(1'b0), .SE(g_run[1][4]), .Sw(g_run[1][6]), .led(g_run[0][5]), .tick(g_set[0][5]), .go(go), .reset(reset));
	unit U06 (.clk(clk), .run(run), .N(1'b0), .E(g_run[0][5]), .S(g_run[1][6]), .W(g_run[0][7]), .NE(1'b0), .NW(1'b0), .SE(g_run[1][5]), .Sw(g_run[1][7]), .led(g_run[0][6]), .tick(g_set[0][6]), .go(go), .reset(reset));
	unit U07 (.clk(clk), .run(run), .N(1'b0), .E(g_run[0][6]), .S(g_run[1][7]), .W(1'b0),		   .NE(1'b0), .NW(1'b0), .SE(g_run[1][6]), .Sw(1'b0),        .led(g_run[0][7]), .tick(g_set[0][7]), .go(go), .reset(reset));
	
	unit U10 (.clk(clk), .run(run), .N(g_run[0][0]), .E(1'b0),        .S(g_run[2][0]), .W(g_run[1][1]), .NE(1'b0),        .NW(g_run[0][1]), .SE(1'b0),        .Sw(g_run[2][1]), .led(g_run[1][0]), .tick(g_set[1][0]), .go(go), .reset(reset));
	unit U11 (.clk(clk), .run(run), .N(g_run[0][1]), .E(g_run[1][0]), .S(g_run[2][1]), .W(g_run[1][2]), .NE(g_run[0][0]), .NW(g_run[0][2]), .SE(g_run[2][0]), .Sw(g_run[2][2]), .led(g_run[1][1]), .tick(g_set[1][1]), .go(go), .reset(reset));
	unit U12 (.clk(clk), .run(run), .N(g_run[0][2]), .E(g_run[1][1]), .S(g_run[2][2]), .W(g_run[1][3]), .NE(g_run[0][1]), .NW(g_run[0][3]), .SE(g_run[2][1]), .Sw(g_run[2][3]), .led(g_run[1][2]), .tick(g_set[1][2]), .go(go), .reset(reset));
	unit U13 (.clk(clk), .run(run), .N(g_run[0][3]), .E(g_run[1][2]), .S(g_run[2][3]), .W(g_run[1][4]), .NE(g_run[0][2]), .NW(g_run[0][4]), .SE(g_run[2][2]), .Sw(g_run[2][4]), .led(g_run[1][3]), .tick(g_set[1][3]), .go(go), .reset(reset));
	unit U14 (.clk(clk), .run(run), .N(g_run[0][4]), .E(g_run[1][3]), .S(g_run[2][4]), .W(g_run[1][5]), .NE(g_run[0][3]), .NW(g_run[0][5]), .SE(g_run[2][3]), .Sw(g_run[2][5]), .led(g_run[1][4]), .tick(g_set[1][4]), .go(go), .reset(reset));
	unit U15 (.clk(clk), .run(run), .N(g_run[0][5]), .E(g_run[1][4]), .S(g_run[2][5]), .W(g_run[1][6]), .NE(g_run[0][4]), .NW(g_run[0][6]), .SE(g_run[2][4]), .Sw(g_run[2][6]), .led(g_run[1][5]), .tick(g_set[1][5]), .go(go), .reset(reset));
	unit U16 (.clk(clk), .run(run), .N(g_run[0][6]), .E(g_run[1][5]), .S(g_run[2][6]), .W(g_run[1][7]), .NE(g_run[0][5]), .NW(g_run[0][7]), .SE(g_run[2][5]), .Sw(g_run[2][7]), .led(g_run[1][6]), .tick(g_set[1][6]), .go(go), .reset(reset));
	unit U17 (.clk(clk), .run(run), .N(g_run[0][7]), .E(g_run[1][6]), .S(g_run[2][7]), .W(1'b0),        .NE(g_run[0][6]), .NW(1'b0),        .SE(g_run[2][6]), .Sw(1'b0),        .led(g_run[1][7]), .tick(g_set[1][7]), .go(go), .reset(reset));
	
	unit U20 (.clk(clk), .run(run), .N(g_run[1][0]), .E(1'b0),        .S(g_run[3][0]), .W(g_run[2][1]), .NE(1'b0),        .NW(g_run[1][1]), .SE(1'b0),        .Sw(g_run[3][1]), .led(g_run[2][0]), .tick(g_set[2][0]), .go(go), .reset(reset));
	unit U21 (.clk(clk), .run(run), .N(g_run[1][1]), .E(g_run[2][0]), .S(g_run[3][1]), .W(g_run[2][2]), .NE(g_run[1][0]), .NW(g_run[1][2]), .SE(g_run[3][0]), .Sw(g_run[3][2]), .led(g_run[2][1]), .tick(g_set[2][1]), .go(go), .reset(reset));
	unit U22 (.clk(clk), .run(run), .N(g_run[1][2]), .E(g_run[2][1]), .S(g_run[3][2]), .W(g_run[2][3]), .NE(g_run[1][1]), .NW(g_run[1][3]), .SE(g_run[3][1]), .Sw(g_run[3][3]), .led(g_run[2][2]), .tick(g_set[2][2]), .go(go), .reset(reset));
	unit U23 (.clk(clk), .run(run), .N(g_run[1][3]), .E(g_run[2][2]), .S(g_run[3][3]), .W(g_run[2][4]), .NE(g_run[1][2]), .NW(g_run[1][4]), .SE(g_run[3][2]), .Sw(g_run[3][4]), .led(g_run[2][3]), .tick(g_set[2][3]), .go(go), .reset(reset));
	unit U24 (.clk(clk), .run(run), .N(g_run[1][4]), .E(g_run[2][3]), .S(g_run[3][4]), .W(g_run[2][5]), .NE(g_run[1][3]), .NW(g_run[1][5]), .SE(g_run[3][3]), .Sw(g_run[3][5]), .led(g_run[2][4]), .tick(g_set[2][4]), .go(go), .reset(reset));
	unit U25 (.clk(clk), .run(run), .N(g_run[1][5]), .E(g_run[2][4]), .S(g_run[3][5]), .W(g_run[2][6]), .NE(g_run[1][4]), .NW(g_run[1][6]), .SE(g_run[3][4]), .Sw(g_run[3][6]), .led(g_run[2][5]), .tick(g_set[2][5]), .go(go), .reset(reset));
	unit U26 (.clk(clk), .run(run), .N(g_run[1][6]), .E(g_run[2][5]), .S(g_run[3][6]), .W(g_run[2][7]), .NE(g_run[1][5]), .NW(g_run[1][7]), .SE(g_run[3][5]), .Sw(g_run[3][7]), .led(g_run[2][6]), .tick(g_set[2][6]), .go(go), .reset(reset));
	unit U27 (.clk(clk), .run(run), .N(g_run[1][7]), .E(g_run[2][6]), .S(g_run[3][7]), .W(1'b0),        .NE(g_run[1][6]), .NW(1'b0),        .SE(g_run[3][6]), .Sw(1'b0),        .led(g_run[2][7]), .tick(g_set[2][7]), .go(go), .reset(reset));
	
	unit U30 (.clk(clk), .run(run), .N(g_run[2][0]), .E(1'b0),        .S(g_run[4][0]), .W(g_run[3][1]), .NE(1'b0),        .NW(g_run[2][1]), .SE(1'b0),        .Sw(g_run[4][1]), .led(g_run[3][0]), .tick(g_set[3][0]), .go(go), .reset(reset));
	unit U31 (.clk(clk), .run(run), .N(g_run[2][1]), .E(g_run[3][0]), .S(g_run[4][1]), .W(g_run[3][2]), .NE(g_run[2][0]), .NW(g_run[2][2]), .SE(g_run[4][0]), .Sw(g_run[4][2]), .led(g_run[3][1]), .tick(g_set[3][1]), .go(go), .reset(reset));
	unit U32 (.clk(clk), .run(run), .N(g_run[2][2]), .E(g_run[3][1]), .S(g_run[4][2]), .W(g_run[3][3]), .NE(g_run[2][1]), .NW(g_run[2][3]), .SE(g_run[4][1]), .Sw(g_run[4][3]), .led(g_run[3][2]), .tick(g_set[3][2]), .go(go), .reset(reset));
	unit U33 (.clk(clk), .run(run), .N(g_run[2][3]), .E(g_run[3][2]), .S(g_run[4][3]), .W(g_run[3][4]), .NE(g_run[2][2]), .NW(g_run[2][4]), .SE(g_run[4][2]), .Sw(g_run[4][4]), .led(g_run[3][3]), .tick(g_set[3][3]), .go(go), .reset(reset));
	unit U34 (.clk(clk), .run(run), .N(g_run[2][4]), .E(g_run[3][3]), .S(g_run[4][4]), .W(g_run[3][5]), .NE(g_run[2][3]), .NW(g_run[2][5]), .SE(g_run[4][3]), .Sw(g_run[4][5]), .led(g_run[3][4]), .tick(g_set[3][4]), .go(go), .reset(reset));
	unit U35 (.clk(clk), .run(run), .N(g_run[2][5]), .E(g_run[3][4]), .S(g_run[4][5]), .W(g_run[3][6]), .NE(g_run[2][4]), .NW(g_run[2][6]), .SE(g_run[4][4]), .Sw(g_run[4][6]), .led(g_run[3][5]), .tick(g_set[3][5]), .go(go), .reset(reset));
	unit U36 (.clk(clk), .run(run), .N(g_run[2][6]), .E(g_run[3][5]), .S(g_run[4][6]), .W(g_run[3][7]), .NE(g_run[2][5]), .NW(g_run[2][7]), .SE(g_run[4][5]), .Sw(g_run[4][7]), .led(g_run[3][6]), .tick(g_set[3][6]), .go(go), .reset(reset));
	unit U37 (.clk(clk), .run(run), .N(g_run[2][7]), .E(g_run[3][6]), .S(g_run[4][7]), .W(1'b0),        .NE(g_run[2][6]), .NW(1'b0),        .SE(g_run[4][6]), .Sw(1'b0),        .led(g_run[3][7]), .tick(g_set[3][7]), .go(go), .reset(reset));
	
	unit U40 (.clk(clk), .run(run), .N(g_run[3][0]), .E(1'b0),        .S(g_run[5][0]), .W(g_run[4][1]), .NE(1'b0),        .NW(g_run[3][1]), .SE(1'b0),        .Sw(g_run[5][1]), .led(g_run[4][0]), .tick(g_set[4][0]), .go(go), .reset(reset));
	unit U41 (.clk(clk), .run(run), .N(g_run[3][1]), .E(g_run[4][0]), .S(g_run[5][1]), .W(g_run[4][2]), .NE(g_run[3][0]), .NW(g_run[3][2]), .SE(g_run[5][0]), .Sw(g_run[5][2]), .led(g_run[4][1]), .tick(g_set[4][1]), .go(go), .reset(reset));
	unit U42 (.clk(clk), .run(run), .N(g_run[3][2]), .E(g_run[4][1]), .S(g_run[5][2]), .W(g_run[4][3]), .NE(g_run[3][1]), .NW(g_run[3][3]), .SE(g_run[5][1]), .Sw(g_run[5][3]), .led(g_run[4][2]), .tick(g_set[4][2]), .go(go), .reset(reset));
	unit U43 (.clk(clk), .run(run), .N(g_run[3][3]), .E(g_run[4][2]), .S(g_run[5][3]), .W(g_run[4][4]), .NE(g_run[3][2]), .NW(g_run[3][4]), .SE(g_run[5][2]), .Sw(g_run[5][4]), .led(g_run[4][3]), .tick(g_set[4][3]), .go(go), .reset(reset));
	unit U44 (.clk(clk), .run(run), .N(g_run[3][4]), .E(g_run[4][3]), .S(g_run[5][4]), .W(g_run[4][5]), .NE(g_run[3][3]), .NW(g_run[3][5]), .SE(g_run[5][3]), .Sw(g_run[5][5]), .led(g_run[4][4]), .tick(g_set[4][4]), .go(go), .reset(reset));
	unit U45 (.clk(clk), .run(run), .N(g_run[3][5]), .E(g_run[4][4]), .S(g_run[5][5]), .W(g_run[4][6]), .NE(g_run[3][4]), .NW(g_run[3][6]), .SE(g_run[5][4]), .Sw(g_run[5][6]), .led(g_run[4][5]), .tick(g_set[4][5]), .go(go), .reset(reset));
	unit U46 (.clk(clk), .run(run), .N(g_run[3][6]), .E(g_run[4][5]), .S(g_run[5][6]), .W(g_run[4][7]), .NE(g_run[3][5]), .NW(g_run[3][7]), .SE(g_run[5][5]), .Sw(g_run[5][7]), .led(g_run[4][6]), .tick(g_set[4][6]), .go(go), .reset(reset));
	unit U47 (.clk(clk), .run(run), .N(g_run[3][7]), .E(g_run[4][6]), .S(g_run[5][7]), .W(1'b0),        .NE(g_run[3][6]), .NW(1'b0),        .SE(g_run[5][6]), .Sw(1'b0),        .led(g_run[4][7]), .tick(g_set[4][7]), .go(go), .reset(reset));
	
	unit U50 (.clk(clk), .run(run), .N(g_run[4][0]), .E(1'b0),        .S(g_run[6][0]), .W(g_run[5][1]), .NE(1'b0),        .NW(g_run[4][1]), .SE(1'b0),        .Sw(g_run[6][1]), .led(g_run[5][0]), .tick(g_set[5][0]), .go(go), .reset(reset));
	unit U51 (.clk(clk), .run(run), .N(g_run[4][1]), .E(g_run[5][0]), .S(g_run[6][1]), .W(g_run[5][2]), .NE(g_run[4][0]), .NW(g_run[4][2]), .SE(g_run[6][0]), .Sw(g_run[6][2]), .led(g_run[5][1]), .tick(g_set[5][1]), .go(go), .reset(reset));
	unit U52 (.clk(clk), .run(run), .N(g_run[4][2]), .E(g_run[5][1]), .S(g_run[6][2]), .W(g_run[5][3]), .NE(g_run[4][1]), .NW(g_run[4][3]), .SE(g_run[6][1]), .Sw(g_run[6][3]), .led(g_run[5][2]), .tick(g_set[5][2]), .go(go), .reset(reset));
	unit U53 (.clk(clk), .run(run), .N(g_run[4][3]), .E(g_run[5][2]), .S(g_run[6][3]), .W(g_run[5][4]), .NE(g_run[4][2]), .NW(g_run[4][4]), .SE(g_run[6][2]), .Sw(g_run[6][4]), .led(g_run[5][3]), .tick(g_set[5][3]), .go(go), .reset(reset));
	unit U54 (.clk(clk), .run(run), .N(g_run[4][4]), .E(g_run[5][3]), .S(g_run[6][4]), .W(g_run[5][5]), .NE(g_run[4][3]), .NW(g_run[4][5]), .SE(g_run[6][3]), .Sw(g_run[6][5]), .led(g_run[5][4]), .tick(g_set[5][4]), .go(go), .reset(reset));
	unit U55 (.clk(clk), .run(run), .N(g_run[4][5]), .E(g_run[5][4]), .S(g_run[6][5]), .W(g_run[5][6]), .NE(g_run[4][4]), .NW(g_run[4][6]), .SE(g_run[6][4]), .Sw(g_run[6][6]), .led(g_run[5][5]), .tick(g_set[5][5]), .go(go), .reset(reset));
	unit U56 (.clk(clk), .run(run), .N(g_run[4][6]), .E(g_run[5][5]), .S(g_run[6][6]), .W(g_run[5][7]), .NE(g_run[4][5]), .NW(g_run[4][7]), .SE(g_run[6][5]), .Sw(g_run[6][7]), .led(g_run[5][6]), .tick(g_set[5][6]), .go(go), .reset(reset));
	unit U57 (.clk(clk), .run(run), .N(g_run[4][7]), .E(g_run[5][6]), .S(g_run[6][7]), .W(1'b0),        .NE(g_run[4][6]), .NW(1'b0),        .SE(g_run[6][6]), .Sw(1'b0),        .led(g_run[5][7]), .tick(g_set[5][7]), .go(go), .reset(reset));
	
	unit U60 (.clk(clk), .run(run), .N(g_run[5][0]), .E(1'b0),        .S(g_run[7][0]), .W(g_run[6][1]), .NE(1'b0),        .NW(g_run[5][1]), .SE(1'b0),        .Sw(g_run[7][1]), .led(g_run[6][0]), .tick(g_set[6][0]), .go(go), .reset(reset));
	unit U61 (.clk(clk), .run(run), .N(g_run[5][1]), .E(g_run[6][0]), .S(g_run[7][1]), .W(g_run[6][2]), .NE(g_run[5][0]), .NW(g_run[5][2]), .SE(g_run[7][0]), .Sw(g_run[7][2]), .led(g_run[6][1]), .tick(g_set[6][1]), .go(go), .reset(reset));
	unit U62 (.clk(clk), .run(run), .N(g_run[5][2]), .E(g_run[6][1]), .S(g_run[7][2]), .W(g_run[6][3]), .NE(g_run[5][1]), .NW(g_run[5][3]), .SE(g_run[7][1]), .Sw(g_run[7][3]), .led(g_run[6][2]), .tick(g_set[6][2]), .go(go), .reset(reset));
	unit U63 (.clk(clk), .run(run), .N(g_run[5][3]), .E(g_run[6][2]), .S(g_run[7][3]), .W(g_run[6][4]), .NE(g_run[5][2]), .NW(g_run[5][4]), .SE(g_run[7][2]), .Sw(g_run[7][4]), .led(g_run[6][3]), .tick(g_set[6][3]), .go(go), .reset(reset));
	unit U64 (.clk(clk), .run(run), .N(g_run[5][4]), .E(g_run[6][3]), .S(g_run[7][4]), .W(g_run[6][5]), .NE(g_run[5][3]), .NW(g_run[5][5]), .SE(g_run[7][3]), .Sw(g_run[7][5]), .led(g_run[6][4]), .tick(g_set[6][4]), .go(go), .reset(reset));
	unit U65 (.clk(clk), .run(run), .N(g_run[5][5]), .E(g_run[6][4]), .S(g_run[7][5]), .W(g_run[6][6]), .NE(g_run[5][4]), .NW(g_run[5][6]), .SE(g_run[7][4]), .Sw(g_run[7][6]), .led(g_run[6][5]), .tick(g_set[6][5]), .go(go), .reset(reset));
	unit U66 (.clk(clk), .run(run), .N(g_run[5][6]), .E(g_run[6][5]), .S(g_run[7][6]), .W(g_run[6][7]), .NE(g_run[5][5]), .NW(g_run[5][7]), .SE(g_run[7][5]), .Sw(g_run[7][7]), .led(g_run[6][6]), .tick(g_set[6][6]), .go(go), .reset(reset));
	unit U67 (.clk(clk), .run(run), .N(g_run[5][7]), .E(g_run[6][6]), .S(g_run[7][7]), .W(1'b0),        .NE(g_run[5][6]), .NW(1'b0),        .SE(g_run[7][6]), .Sw(1'b0),        .led(g_run[6][7]), .tick(g_set[6][7]), .go(go), .reset(reset));
	
	unit U70 (.clk(clk), .run(run), .N(g_run[6][0]), .E(1'b0),        .S(1'b0), .W(g_run[7][1]), .NE(1'b0),        .NW(g_run[6][1]), .SE(1'b0), .Sw(1'b0), .led(g_run[7][0]), .tick(g_set[7][0]), .go(go), .reset(reset));
	unit U71 (.clk(clk), .run(run), .N(g_run[6][1]), .E(g_run[7][0]), .S(1'b0), .W(g_run[7][2]), .NE(g_run[6][0]), .NW(g_run[6][2]), .SE(1'b0), .Sw(1'b0), .led(g_run[7][1]), .tick(g_set[7][1]), .go(go), .reset(reset));
	unit U72 (.clk(clk), .run(run), .N(g_run[6][2]), .E(g_run[7][1]), .S(1'b0), .W(g_run[7][3]), .NE(g_run[6][1]), .NW(g_run[6][3]), .SE(1'b0), .Sw(1'b0), .led(g_run[7][2]), .tick(g_set[7][2]), .go(go), .reset(reset));
	unit U73 (.clk(clk), .run(run), .N(g_run[6][3]), .E(g_run[7][2]), .S(1'b0), .W(g_run[7][4]), .NE(g_run[6][2]), .NW(g_run[6][4]), .SE(1'b0), .Sw(1'b0), .led(g_run[7][3]), .tick(g_set[7][3]), .go(go), .reset(reset));
	unit U74 (.clk(clk), .run(run), .N(g_run[6][4]), .E(g_run[7][3]), .S(1'b0), .W(g_run[7][5]), .NE(g_run[6][3]), .NW(g_run[6][5]), .SE(1'b0), .Sw(1'b0), .led(g_run[7][4]), .tick(g_set[7][4]), .go(go), .reset(reset));
	unit U75 (.clk(clk), .run(run), .N(g_run[6][5]), .E(g_run[7][4]), .S(1'b0), .W(g_run[7][6]), .NE(g_run[6][4]), .NW(g_run[6][6]), .SE(1'b0), .Sw(1'b0), .led(g_run[7][5]), .tick(g_set[7][5]), .go(go), .reset(reset));
	unit U76 (.clk(clk), .run(run), .N(g_run[6][6]), .E(g_run[7][5]), .S(1'b0), .W(g_run[7][7]), .NE(g_run[6][5]), .NW(g_run[6][7]), .SE(1'b0), .Sw(1'b0), .led(g_run[7][6]), .tick(g_set[7][6]), .go(go), .reset(reset));
	unit U77 (.clk(clk), .run(run), .N(g_run[6][7]), .E(g_run[7][6]), .S(1'b0), .W(1'b0),        .NE(g_run[6][6]), .NW(1'b0),        .SE(1'b0), .Sw(1'b0), .led(g_run[7][7]), .tick(g_set[7][7]), .go(go), .reset(reset));
	
	
	
	enum { resetting, setting, running } ps, ns;
	
	always_comb begin
		case(ps)
			resetting: if (juice) begin ns = setting; end
						  else begin ns = resetting; end
			
			setting:   if (go) begin ns = running; end
			           else begin ns = setting; end
						  
			running:   ns = running;
			
			default: ns = resetting;
		endcase
	end
	
	assign sig = (ps == setting);
	assign run = (ps == running & cycle_zero == 1'b1);

	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= resetting;
			r  <= '0;
			g  <= '0;
		end else begin
			ps <= ns;
			//if (go) g_run <= g_set;
			if (ps == setting) begin g <= g_set; r <= r_set; end
			else if (ps == running) begin g <= g_run; r <= '0; end // ps == running
		end
	end
endmodule
			
module game_of_life2_testbench();

   logic reset, juice, plant, start, clk, up, down, left, right;
	logic [15:0][15:0] g, r;
	logic [9:0] LEDR;
   game_of_life2 dut(clk, reset, juice, start, plant, up, down, left, right, g, r, LEDR);

// Set up a simulated clock.
parameter CLOCK_PERIOD=100;
initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
end
// Set up the inputs to the design. Each line is a clock cycle.
initial begin
												  @(posedge clk);
	reset <= 1;  juice <= 0; plant <= 0; start <= 0; up <= 0; down <= 0; left <= 0; right <= 0;       repeat(10)                @(posedge clk);	
   reset <= 0;             repeat (4) @(posedge clk);		
	//set   <= 1;             repeat (4) @(posedge clk);										
	right <= 1; juice <= 1;              @(posedge clk);																													
	right <= 0; left <= 1;  repeat (3) @(posedge clk);    
	down <= 1;  left <= 0;  repeat (4) @(posedge clk);
	plant <= 1;  down <= 0;             @(posedge clk);
   plant <= 0;               repeat (4) @(posedge clk);	
	left <= 1;                           @(posedge clk);																													
	left <= 0;                repeat (2) @(posedge clk);    
	plant <= 1;                          @(posedge clk);
   plant <=0;                          @(posedge clk);
	left <= 1;                           @(posedge clk);																													
	left <= 0;                repeat (2) @(posedge clk);    
	plant <= 1;                          @(posedge clk);
   plant <= 0;               repeat (10) @(posedge clk);
	start <= 1;             repeat (5) @(posedge clk);
	start <= 0;             repeat (20) @(posedge clk);
	reset <= 1;             repeat (4) @(posedge clk);
								            
		$stop; 
	end
endmodule		
