module lcd_controller (
	// host side interface
	input 		clock,
	input	[7:0]	data,
	input			rs,
	input			start,
	output reg	done,
	
	// lcd module interface
	output		lcd_data,
	output		lcd_ctrl
);

	// divide the clock by 16
	parameter clock_divider = 16;
	
	
	/*
	 * Expand the I/O bundle.
	 */
	wire	lcd_rw, lcd_rs, lcd_on, lcd_blon;
	assign lcd_ctrl = {lcd_rw, reg_lcd_en, lcd_rs, lcd_on, lcd_blon};
	
	
	/*
	 * LCM control states.
	 */
	parameter [1:0] 	IDLE			= 2'd0,
							WRITE_START	= 2'd1,
							WRITE_WAIT	= 2'd2,
							WRITE_END	= 2'd3;
				
				
	/*
	 * Internal registers.
	 */
	reg	[4:0]	clock_counter;
	reg	[1:0]	state;
	reg			pre_start, lcd_busy;
	reg			reg_lcd_en;

	
	/*
	 * LCM low level control, write only.
	 */
	assign lcd_data = data;
	assign lcd_rs	 = rs;
	assign lcd_rw	 = 1'b0;
	
	// default operation, permanent on.
	assign lcd_on	 = 1'b1;
	assign lcd_blon = 1'b1;
	
	
	/*
	 * LCM control sequence.
	 */
	initial begin
		// bus state
		reg_lcd_en 		<= 1'b0;
		
		// device state
		pre_start 		<= 1'b0;
		lcd_busy			<=	1'b0;
		done 				<= 1'b0;
		
		clock_counter	<=	1'b0;
		state				<=	IDLE;
	end
	
	always @(posedge clock) begin
		// detect start trigger
		pre_start <= start;
		if ({pre_start, start} == 2'b01) begin
			lcd_busy	<=	1'b1;
			done		<=	1'b0;
		end
		
		if (lcd_busy) begin
			case(state)
				IDLE:	begin
					state					<=	WRITE_START;
				end
				
				WRITE_START:	begin
					reg_lcd_en				<=	1'b1;
					state					<=	WRITE_WAIT;
				end
				
				WRITE_WAIT:	begin			
					if(clock_counter < clock_divider)
						clock_counter	<= clock_counter+1;
					else
						state				<=	WRITE_END;
				end
				
				WRITE_END:	begin
					// bus state
					reg_lcd_en				<=	1'b0;
					
					// device state
					lcd_busy				<=	1'b0;
					done					<=	1'b1;
					
					clock_counter		<=	5'd0;
					state					<=	IDLE;
				end
			endcase
		end
	end

endmodule
