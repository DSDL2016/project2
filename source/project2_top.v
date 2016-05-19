module project2_top (
	input				clock_50m,
	input				start_pause_btn,
	input				lap_btn,
	input				reset_btn,
	input				clear_btn,
	output	[6:0]	hour_hex1, hour_hex0,
	output	[6:0]	minute_hex1, minute_hex0,
	output	[6:0]	second_hex1, second_hex0,
	output	[6:0]	m_sec_hex1, m_sec_hex0
);
	
	wire 				lcd_busy, reg_busy;
	wire	[10:0]	state;
	
	/*
	 * Debounce the buttons.
	 */
	wire start_pause = ~start_pause_neg;
	wire lap = ~lap_neg;
	wire reset = ~reset_neg;
	wire clear = ~clear_neg;
	
	debouncer start_pause_db (
		.clock	(clock_50m), 
		.PB		(start_pause_btn), 
		.PB_db	(start_pause_neg)
	);
	
	debouncer lap_db (
		.clock	(clock_50m),
		.PB		(lap_btn),
		.PB_db	(lap_neg)
	);
	
	debouncer reset_db (
		.clock	(clock_50m),
		.PB		(reset_btn),
		.PB_db	(reset_neg)
	);
	
	debouncer clear_db (
		.clock	(clock_50m),
		.PB		(clear_btn),
		.PB_db	(clear_neg)
	);
	
	/*
	 * Key FSM.
	 */
	wire run_timer, reset_timer;
	
	key_logic_fsm key_logic (
		.clock		(clock_50m),
		.reset		(1'b0),
		.k3			(start_pause),
		.run_timer	(run_timer)
	);
	
	/*
	 * Timer logic.
	 */
	wire	[5:0]		hour, minute, second;
	wire	[6:0]		m_sec;
	
	stopwatch sw_timer (
		.clock 	(clock_50m),
		.run		(run_timer),
		.reset	(reset_timer),
		.hour		(hour),
		.minute	(minute),
		.second	(second),
		.m_sec	(m_sec)
	);
	
	/*
	 * 7-segment display.
	 */
	wire	[3:0]	m_sec_bcd1, m_sec_bcd0;
	wire	[3:0]	second_bcd1, second_bcd0;
	wire	[3:0]	minute_bcd1, minute_bcd0;
	wire	[3:0]	hour_bcd1, hour_bcd0;
	
	bin2bcd conv_m_sec (
		.bin	({1'b0, m_sec}),
		.bcd1	(m_sec_bcd1),
		.bcd0	(m_sec_bcd0)
	);
	
	bcd2seg seg_m_sec_hex1 (
		.bcd				(m_sec_bcd1),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(m_sec_hex1)
	);
	
	bcd2seg seg_m_sec_hex0 (
		.bcd				(m_sec_bcd0),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(m_sec_hex0)
	);

	bin2bcd conv_second (
		.bin	({1'b0, second}),
		.bcd1	(second_bcd1),
		.bcd0	(second_bcd0)
	);
	
	bcd2seg seg_second_hex1 (
		.bcd				(second_bcd1),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(second_hex1)
	);
	
	bcd2seg seg_second_hex0 (
		.bcd				(second_bcd0),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(second_hex0)
	);
	
	bin2bcd conv_minute (
		.bin	({1'b0, minute}),
		.bcd1	(minute_bcd1),
		.bcd0	(minute_bcd0)
	);
	
	bcd2seg seg_minute_hex1 (
		.bcd				(minute_bcd1),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(minute_hex1)
	);
	
	bcd2seg seg_minute_hex0 (
		.bcd				(minute_bcd0),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(minute_hex0)
	);
	
	bin2bcd conv_hour (
		.bin	({1'b0, hour}),
		.bcd1	(hour_bcd1),
		.bcd0	(hour_bcd0)
	);
	
	bcd2seg seg_hour_hex1 (
		.bcd				(hour_bcd1),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(hour_hex1)
	);
	
	bcd2seg seg_hour_hex0 (
		.bcd				(hour_bcd0),
		.blank			(1'b0),
		.common_anode	(1'b1),
		.seven_segment	(hour_hex0)
	);
	
endmodule
