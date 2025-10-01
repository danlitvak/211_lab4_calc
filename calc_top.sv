// calc_top.sv
// calculates sum of regA and regB

module calc_top(
  input  logic [9:0] SW,        // switches
  input  logic [1:0] KEY,       // buttons
  output logic [9:0] LEDR,      // LEDs
  output logic [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

	// clock and reset
	logic clk;
	logic rst_n;

	// assign clock and reset to buttons
	assign clk   = KEY[1];
	assign rst_n = KEY[0];

	// registers
	logic [3:0] A, B;

	// always for sequention logic (flip-flop)
	// use <= so values uptdate after block
	always_ff @(posedge clk) begin
		// on rising edge of clock
		if (!rst_n) begin
			// if reset is low (pressed)
			A <= 4'b0;
			B <= 4'b0;
		end else begin
			if (SW[9]) A <= SW[3:0];
			if (SW[8]) B <= SW[3:0];
		end
	end

	// create 5 bits
	logic [4:0] SUM;
	// assign to the sum of regA and regB
	assign SUM = A + B;

	// create 7 bits for each display
	logic [6:0] segA, segB, segLow, segHigh;
	
	// decode A, B, SUM
	//             ( input: data              output: segments )
	sevenseg uA    (.data(A),                .segments(segA)   ); // regA
	sevenseg uB    (.data(B),                .segments(segB)   ); // regB
	sevenseg uLow  (.data(SUM[3:0]),         .segments(segLow) ); // LSB
	sevenseg uHigh (.data({3'b000, SUM[4]}), .segments(segHigh)); // MSB

	// map to board HEX displays
	assign HEX5[6:0] = segA;   
	assign HEX3[6:0] = segB;   
	assign HEX0[6:0] = segLow; 
	assign HEX1[6:0] = segHigh;
	
	// remove dot by tying to high (off)
	assign HEX5[7] = 1'b1; 
	assign HEX3[7] = 1'b1;
	assign HEX0[7] = 1'b1;
	assign HEX1[7] = 1'b1;

	// turn off HEX4 and HEX2
	assign HEX4 = 8'hFF;
	assign HEX2 = 8'hFF;

	// LEDs mirror switches
	assign LEDR = SW;
	
endmodule