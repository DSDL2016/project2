module project2-top (
	input		clock_50m,
	input		start_pause,
	input		lap,
	input		reset,
	input		clear
);
	
	wire 				lcd_busy, reg_busy;
	wire	[10:0]	state;
	
	wire	[5:0]		hour, minute, second;
	wire	[9:0]		m_sec;
	
	/*
	 * Branch out the states.
	 */
	wire	IDLE 			= state[0];
	wire	PRE-START 	= state[1];
	wire 	RUN 			= state[2];
	wire	PRE-PAUSE 	= state[3];
	wire	PAUSE 		= state[4];
	wire	RETRIEVE 	= state[5];
	wire	SAVE			= state[6];
	wire	PRE-RESET 	= state[7];
	wire	RESET 		= state[8];
	wire	PRE-CLEAR 	= state[9];
	wire	CLEAR 		= state[10];
	
	control_fsm fsm (
		.clock		(clock_50m),
		.stimulus	({start_pause, lap, reset, clear, lcd_busy, reg_busy}),
		.state		(state)
	);
	
	stopwatch sw (
		.clock 		(clock_50m),
		.start		(RUN),
		.pause		(PAUSE),
		.reset		(RESET),
		.epoch		({hour, minute, second}),
		.m_epoch		(m_sec)
	);

endmodule
