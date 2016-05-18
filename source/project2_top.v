module project2_top (
	input				clock_50m,
	input				start_pause,
	input				lap,
	input				reset,
	input				clear,
	output	[6:0]	hour_hex1, hour_hex0,
	output	[6:0]	minute_hex1, minute_hex0,
	output	[6:0]	second_hex1, second_hex0,
	output	[6:0]	m_sec_hex3, m_sec_hex2, m_sec_hex1, m_sec_hex0
);
	
	wire 				lcd_busy, reg_busy;
	wire	[10:0]	state;
	
	wire	[5:0]		hour, minute, second;
	wire	[9:0]		m_sec;
	
	/*
	 * Branch out the states.
	 */
	wire	IDLE 			= state[0];
	wire	PRE_START 	= state[1];
	wire 	RUN 			= state[2];
	wire	PRE_PAUSE 	= state[3];
	wire	PAUSE 		= state[4];
	wire	RETRIEVE 	= state[5];
	wire	SAVE			= state[6];
	wire	PRE_RESET 	= state[7];
	wire	RESET 		= state[8];
	wire	PRE_CLEAR 	= state[9];
	wire	CLEAR 		= state[10];
	
	control_fsm fsm (
		.clock		(clock_50m),
		.stimulus	({start_pause, lap, reset, clear, lcd_busy, reg_busy}),
		.state		(state)
	);
	
	stopwatch sw (
		.clock 		(clock_50m),
		.run			(RUN),
		.reset		(RESET),
		.epoch		({hour, minute, second}),
		.m_epoch		(m_sec)
	);

endmodule
