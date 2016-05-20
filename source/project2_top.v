module project2_top (
	input				clock_50m,
	
	// buttons
	input				start_pause_btn,
	input				lap_btn,
	input				reset_btn,
	input				clear_btn,
	
	// 7-segment displays
	output	[6:0]	hour_hex1, hour_hex0,
	output	[6:0]	minute_hex1, minute_hex0,
	output	[6:0]	second_hex1, second_hex0,
	output	[6:0]	m_sec_hex1, m_sec_hex0,
	
	output	[7*8-1:0]	hex,
	
	// led indicators
	output			start_pause_ind, run_timer_ind,
	output			reset_ind, reset_timer_ind,
	
	// lcd module interface
	output	[7:0]	LCD_DATA,
	output			LCD_RW, LCD_EN, LCD_RS, LCD_ON, LCD_BLON
);
	
	wire 				lcd_busy, reg_busy;
	
	/*
	 * Debounce the buttons.
	 */
	wire start_pause_neg, lap_neg, reset_neg, clear_neg;
	
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
	
	wire start_pause = ~start_pause_neg;
	wire lap = ~lap_neg;
	wire reset = ~reset_neg;
	wire clear = ~clear_neg;
	
	assign start_pause_ind = start_pause;
	assign reset_ind = reset;
	
	/*
	 * Key FSM.
	 */
	wire run_timer, reset_timer;
	
	key_logic_fsm key_logic (
		.clock			(clock_50m),
		.reset			(1'b0),
		.k3				(start_pause),
		.k1				(reset),
		.run_timer		(run_timer),
		.reset_timer	(reset_timer)
	);
	
	assign run_timer_ind 	= run_timer;
	assign reset_timer_ind 	= reset_timer;
	
	/*
	 * Timer logic.
	 */
	// 0: m_sec, second, minute, hour :3
	wire	[6:0]			unit_time	[0:3];
	
	stopwatch sw_timer (
		.clock 	(clock_50m),
		.run		(run_timer),
		.reset	(reset_timer),
		.epoch	(ut_flat)
	);
	
	// collapse the 1d array to 2d array
	wire	[7*4-1:0]	ut_flat;
	genvar ut_flat_idx;
	generate
		for (ut_flat_idx = 0; ut_flat_idx < 4; ut_flat_idx = ut_flat_idx+1) begin: ASSIGN_UT
			assign unit_time[ut_flat_idx] = ut_flat[7*(ut_flat_idx+1)-1 -: 7];
		end
	endgenerate
	
	/*
	 * 7-segment display.
	 */
	wire	[3:0]	bcd_data	[0:3][0:1];

	genvar ut_idx;
	generate
		for (ut_idx = 0; ut_idx < 4; ut_idx = ut_idx+1) begin: TIMER_BCD2SEG
			bin2bcd time_to_digits (
				.bin	(unit_time[ut_idx]),
				.bcd1	(bcd_data[ut_idx][1]),
				.bcd0	(bcd_data[ut_idx][0])
			);
			
			bcd2seg digit1_to_hex (
				.bcd				(bcd_data[ut_idx][1]),
				.blank			(1'b0),
				.common_anode	(1'b1),
				.seven_segment	()
			);
			
			bcd2seg digit0_to_hex (
				.bcd				(bcd_data[ut_idx][0]),
				.blank			(1'b0),
				.common_anode	(1'b1),
				.seven_segment	()
			);
		end
	endgenerate
	
	/*
	 * LCM driver.
	 */
	assign LCD_ON		=	1'b1;
	assign LCD_BLON	=	1'b1;

	lcd_bridge lcd(
		.iCLK		(clock_50m),
		.iRST_N	(1'b1),
		
		// lcd module interface
		.LCD_DATA	(LCD_DATA),
		.LCD_RS		(LCD_RS),
		.LCD_RW		(LCD_RW),
		.LCD_EN		(LCD_EN)
	);
	
endmodule
