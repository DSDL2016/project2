module project2_top (
	input				clock,
	
	
	// buttons and indicators
	input				start_pause_key,
	output			start_pause_led,
	
	input				lap_key,
	output			lap_led,
	
	input				reset_key,
	output			reset_led,
	
	input				clear_key,
	output			clear_led,
	
	output			timer_running,
	output			lcd_updating,
	
	
	// 7-segment displays
	output	[6:0]	m_sec_1, m_sec_0,
	output	[6:0]	second_1, second_0,
	output	[6:0]	minute_1, minute_0,
	output	[6:0]	hour_1, hour_0,
	
	
	// lcd module interface
	output	[7:0]	lcd_data,
	output			lcd_rw, lcd_en, lcd_rs,
	output			lcd_on, lcd_blon,
	
	
	input				debug_sw,
	output			debug_led
);
	
	genvar i;
	
	
	/*
	 * Internal wires and registers.
	 */
	wire	wire_global_reset;
	
	wire	[3:0]	keys_nodb = { start_pause_key, lap_key, reset_key, clear_key };
	wire	[3:0]	keys;
	wire	[6:0]	seg_disp [0:3][0:1];
	
	
	/*
	 * Global reset generation.
	 */
	reset_gen r0 (
		.clock	(clock),
		.reset	(wire_global_reset)
	);
	
	
	/*
	 * Debouncers.
	 */
	generate
		for (i = 0; i < 4; i = i+1) begin: DB_BTN
			debouncer db_key (
				.clock		(clock),
				.key_in		(keys_nodb[i]),
				.active_low	(1'b1),
				.key_out		(keys[i])
			);
		end
	endgenerate
	
	// preview the debounced output
	assign {	start_pause_led, lap_led, reset_led, clear_led } = keys;
	
	
	/*
	 * State machine.
	 */
	wire	run_timer, reset_timer;
	wire	insert_value, clear_value;
	
	wire	timer_busy_wire;
	
	key_logic_fsm fsm (
		.clock			(clock),
		.reset			(1'b0),
		
		// input from the keys
		.k					(keys),
		
		// internal busy state
		.lcd_busy		(lcd_busy),
		.reg_busy		(timer_busy_wire),
		
		// timer control
		.run_timer		(run_timer),
		.reset_timer	(reset_timer),
		
		// lcd control
		.insert_value	(insert_value),
		.clear_value	(clear_value)
	);
	
	assign timer_running = run_timer;
	
	
	/*
	 * Internal timer logic.
	 */
	// 4 time units: hour, minute, second, m_sec
	localparam time_units = 4;
	
	wire	[7*time_units-1:0]	timestamp_flat;
	
	internal_timer timer (
		.clock		(clock),
		.run			(run_timer),
		.reset		(reset_timer),
		.timestamp	(timestamp_flat),
		.reg_busy	(timer_busy_wire)
	);
	
	
	/*
	 * Expand the timestamp.
	 */
	wire	[6:0]	timestamp	[0:3];
	parameter [1:0]	M_SEC		= 2'd0,
							SECOND	= 2'd1,
							MINUTE	= 2'd2,
							HOUR		= 2'd3;
							
	generate
		for (i = 0; i < 4; i = i+1) begin: EXP_FLAT_TIMESTAMP
			assign timestamp[i] = timestamp_flat[7*(i+1)-1 -: 7];
		end
	endgenerate
	
	
	/*
	 * 7-segment display conversions.
	 */
	wire	[3:0]	bcd	[0:3][0:1];
	
	generate
		for (i = 0; i < 4; i = i+1) begin: SEG_CONV
			bin2bcd conv_bin (
				.bin	(timestamp[i]),
				.bcd1	(bcd[i][1]),
				.bcd0	(bcd[i][0])
			);
			
			bcd2seg conv_bcd1 (
				.bcd				(bcd[i][1]),
				.blank			(1'b0),
				.active_low		(1'b1),
				.seven_segment	(seg_disp[i][1])
			);
			
			bcd2seg conv_bcd0 (
				.bcd				(bcd[i][0]),
				.blank			(1'b0),
				.active_low		(1'b1),
				.seven_segment	(seg_disp[i][0])
			);
		end
	endgenerate
	
	assign {m_sec_0, m_sec_1} 		= {seg_disp[M_SEC][0], 	seg_disp[M_SEC][1]};
	assign {second_0, second_1} 	= {seg_disp[SECOND][0], seg_disp[SECOND][1]};
	assign {minute_0, minute_1} 	= {seg_disp[MINUTE][0], seg_disp[MINUTE][1]};
	assign {hour_0, hour_1} 		= {seg_disp[HOUR][0], 	seg_disp[HOUR][1]};
	
	
	/*
	 * Flatten the BCD representations.
	 */
	wire	[2*4*4-1:0]	flat_bcd;
	generate
		for (i = 0; i < 4; i = i+1) begin: FLAT_BCD
			assign flat_bcd[8*i +: 8] = {bcd[3-i][0], bcd[3-i][1]};
		end
	endgenerate
	
	
	/*
	 * LCM driver.
	 */
	wire	[7:0]	lcd_data_wire;
	wire	[4:0]	lcd_ctrl_wire;
	
	assign lcd_data = lcd_data_wire;
	assign {lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon} = lcd_ctrl_wire;
	
	lcd_bridge lcd_bridge (
		.clock		(clock),
		.reset		(wire_global_reset),
		
		.insert		(insert_value),
		.new_record	(flat_bcd),
		.clear		(clear_value),
		
		.busy			(lcd_busy),

		// lcd module interface
		.lcd_data	(lcd_data_wire),
		.lcd_ctrl	(lcd_ctrl_wire)
	);
	
	assign lcd_updating = lcd_busy;
	
	/*
	 * Debug LED.
	 */
	//assign lcd_busy = debug_sw;
	//assign debug_led = ;
	
endmodule
