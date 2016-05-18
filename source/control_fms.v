module control_fsm (
	input				clock,
	input		[3:0]	stimulus,
	output	[]		state
);

	/*
	 * Parse the input from stimulus bundle.
	 */
	wire start_pause 	= stimulus[3];
	wire lap				= stimulus[2];
	wire reset			= stimulus[1];
	wire clear			= stimulus[0];
	
	/*
	 * State-parameter definitions.
	 */
	parameter [9:0] 	PRE-START = 4'd0,
							RUN = 4'd1,
							PRE-PAUSE = 4'd2,
							PAUSE = 4'd3,
							RETRIEVE = 4'd4,
							SAVE = 4'd5,
							PRE-RESET = 4'd6,
							RESET = 4'd7,
							PRE-CLEAR = 4'd8,
							CLEAR = 4'd9;
	
	reg [9:0] state, next;
	
	initial begin
		// reset the state and start from RESET
		state <= 9'b0;
		state[RESET] <= 1'b1;
	end
	
	always @(posedge clock) begin
		// transition to the next state
		state <= next;
	end

endmodule
