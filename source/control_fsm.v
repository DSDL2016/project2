module control_fsm (
	input						clock,
	input			[5:0]		stimulus,
	output reg	[10:0]	state
);

	/*
	 * Parse the input from stimulus bundle.
	 */
	wire start_pause 	= stimulus[5];
	wire lap				= stimulus[4];
	wire reset			= stimulus[3];
	wire clear			= stimulus[2];
	wire lcd_busy		= stimulus[1]; // LCD
	wire reg_busy		= stimulus[0]; // timestamp
	
	/*
	 * State-parameter definitions.
	 */
	parameter	[10:0] 	IDLE			= 11'd0,
								PRE_START 	= 11'd1,
								RUN 			= 11'd2,
								PRE_PAUSE 	= 11'd3,
								PAUSE 		= 11'd4,
								RETRIEVE 	= 11'd5,
								SAVE 			= 11'd6,
								PRE_RESET 	= 11'd7,
								RESET 		= 11'd8,
								PRE_CLEAR 	= 11'd9,
								CLEAR 		= 11'd10;
	
	reg	[10:0]	next;
	
	initial begin
		// reset the state and start from RESET
		state <= 11'b0;
		state[RESET] <= 1'b1;
	end
	
	always @(posedge clock) begin
		// transition to the next state
		state <= next;
	end
	
	always @(state or start_pause or lap or reset or clear or lcd_busy or reg_busy) begin
		// reset the register
		next = 11'b0;
		
		case (1'b1) // synopsys full_case parallel_case
		state[IDLE]: begin
				if (clear)						next[PRE_CLEAR]	= 1'b1;
				if (!clear & start_pause)	next[PRE_START]	= 1'b1;
				if (!clear & !start_pause)	next[IDLE]			= 1'b1;
			end
			
		state[PRE_START]: begin
				if (start_pause)				next[PRE_START] 	= 1'b1;
				if (!start_pause) 			next[RUN] 			= 1'b1;
			end
		
		state[RUN]: begin
				if (lap)							next[RETRIEVE] 	= 1'b1;
				if (!lap & start_pause) 	next[PRE_PAUSE] 	= 1'b1;
				if (!lap & !start_pause)	next[RUN] 			= 1'b1;
			end
		
		state[PRE_PAUSE]: begin
				if (!start_pause)				next[PAUSE] 		= 1'b1;
				if (start_pause)				next[PRE_PAUSE] 	= 1'b1;
			end
			
		state[PAUSE]: begin
				if (reset)						next[PRE_RESET] 	= 1'b1;
				if (!reset & start_pause)	next[PRE_START] 	= 1'b1;
				if (!reset & !start_pause)	next[PAUSE] 		= 1'b1;
			end
			
		state[RETRIEVE]: begin
				if (!lap)						next[SAVE] 			= 1'b1;
				if (lap)							next[RETRIEVE] 	= 1'b1;
			end
			
		state[SAVE]: begin
				if (!lcd_busy)					next[RUN]			= 1'b1;
				if (lcd_busy)					next[SAVE]			= 1'b1;
			end
			
		state[PRE_RESET]: begin
				if (!reset)						next[RESET]			= 1'b1;
				if (reset)						next[PRE_RESET]	= 1'b1;
			end
			
		state[RESET]: begin
				if (!reg_busy)					next[IDLE]			= 1'b1;
				if (reg_busy)					next[RESET]			= 1'b1;
			end
			
		state[PRE_CLEAR]: begin
				if (!clear)						next[CLEAR]			= 1'b1;
				if (clear)						next[PRE_CLEAR]	= 1'b1;
			end
			
		state[CLEAR]: begin
				if	(!lcd_busy)					next[RESET]			= 1'b1;
				if (lcd_busy)					next[CLEAR]			= 1'b1;
			end
		
		// directly go to IDLE if error occurred
		~|state: begin
													next[IDLE]			= 1'b1;
			end
		endcase
	end
	
endmodule
