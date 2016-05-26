module project2_top (
   input				_CLOCK_27,
	input				_CLOCK_50,
	
	input 			switch_string_wav,
	output			led_switch_string_wav,
	input 			switch_mute,	
	output			led_switch_mute,
	input 			switch_marquee,
	output			led_switch_marquee,
	input 			switch_ticking_sound,
	output			led_switch_ticking_sound,
	
	inout				_I2C_SDAT,				//	I2C Data
	output			_I2C_SCLK,				//	I2C Clock
	
	inout				_AUD_ADCLRCK,			//	Audio CODEC ADC LR Clock
	inout				_AUD_DACLRCK,			//	Audio CODEC DAC LR Clock
	input				_AUD_ADCDAT,			    //	Audio CODEC ADC Data
	output			_AUD_DACDAT,				//	Audio CODEC DAC Data
	inout				_AUD_BCLK,				//	Audio CODEC Bit-Stream Clock
	output			_AUD_XCK,				//	Audio CODEC Chip Clock

	output			_TD_RESET,				//	TV Decoder Reset
	
	
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
	
	output [10:0] ledr
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
		.clock	(_CLOCK_50),
		.reset	(wire_global_reset)
	);
	
	
	/*
	 * Debouncers.
	 */
	generate
		for (i = 0; i < 4; i = i+1) begin: DB_BTN
			debouncer db_key (
				.clock		(_CLOCK_50),
				.key_in		(keys_nodb[i]),
				.active_low	(1'b1),
				.key_out		(keys[i])
			);
		end
	endgenerate
	
	// preview the debounced output
	assign {	start_pause_led, lap_led, reset_led, clear_led } = keys;
	
	// preview the switch output
	assign { led_switch_marquee, led_switch_ticking_sound, led_switch_string_wav, led_switch_mute }
			= { switch_marquee, switch_ticking_sound, switch_string_wav, switch_mute};	
				
	
	
	/*
	 * State machine.
	 */
	wire	run_timer, reset_timer;
	wire	insert_value, clear_value;
	
	wire	timer_busy_wire;
	
	key_logic_fsm fsm (
		.clock			(_CLOCK_50),
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
		.clock		(_CLOCK_50),
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
	 * Marquee Blinker LED Red 
	 */
	generate 
	   for (i = 0; i < 10; i = i+1) begin: MARQUEE
			assign ledr[i] = switch_marquee & 
								((bcd[0][1] == i && ~ bcd[1][0][0]) || (bcd[0][1] == (10 - i) && bcd[1][0][0]));
		end
	endgenerate
	
	assign ledr[10] = switch_marquee & (bcd[0][1] == 4'd0 &&  bcd[1][0][0]);
	
	
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
		.clock		(_CLOCK_50),
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
	
	wire is_1sec = (bcd[0][1] == 4'b0000) && timer_running && switch_ticking_sound;
	
	DE2_synthesizer synthesizer (	 
		.CLOCK_27 (_CLOCK_27),							
		.CLOCK_50 (_CLOCK_50),											
		////////////////////	Push Button		////////////////////
		.START_KEY1 ( start_pause_key & lap_key & reset_key & ~is_1sec),
		.START_KEY2 ( clear_key ),			
		////////////////////	DPDT Switch		////////////////////
		.SW_STRING (switch_string_wav),
		.SW_MUTE (switch_mute),						
		////////////////////	I2C		////////////////////////////
		.I2C_SDAT (_I2C_SDAT),					
		.I2C_SCLK (_I2C_SCLK),						
		
	
		////////////////	Audio CODEC		////////////////////////
		.AUD_ADCLRCK (_AUD_ADCLRCK),				
		.AUD_ADCDAT (_AUD_ADCDAT),						
		.AUD_DACLRCK (_AUD_DACLRCK),				
		.AUD_DACDAT (_AUD_DACDAT),						
		.AUD_BCLK (_AUD_BCLK),						
		.AUD_XCK (_AUD_XCK),						
		.TD_RESET (_TD_RESET)						
	);
	
	
endmodule
