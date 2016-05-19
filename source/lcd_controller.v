module lcd_controller (
	// host side interface
	input 		clock,
	input	[7:0]	data,
	input			rs,
	input			start,
	output reg	done,
	
	// lcd module interface
	output		lcd_data,
	output		lcd_rs,
	output		lcd_rw,
	output reg	lcd_en
);

	// divide the clock by 16
	parameter clock_divider = 16;
	
	/*
	 * LCM control states.
	 */
	parameter [1:0] 	IDLE			= 1'd0,
							WRITE_START	= 1'd1,
							WRITE_WAIT	= 1'd2,
							WRITE_END	= 1'd3;
							
	/*
	 * Internal registers.
	 */
	reg	[4:0]	clock_counter;
	reg	[1:0]	state;
	reg			pre_start, lcd_busy;

	/*
	 * LCM low level control, write only.
	 */
	assign lcd_data = data;
	assign lcd_rs	 = rs;
	assign lcd_rw	 = 1'b0;
	
	/*
	 * LCM control sequence.
	 */
	initial begin
		// bus state
		lcd_en 			<= 1'b0;
		
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
					lcd_en				<=	1'b1;
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
					lcd_en				<=	1'b0;
					
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
