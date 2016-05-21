module lcd_controller (
	input					clock,
	input					reset,
	input			[7:0]	data,
	input					rs,
	input					write_start,
	output reg			lcd_done,
	
	//	LCD interface
	output		[7:0]	lcd_data,
	output		[4:0]	lcd_ctrl
);
	
	// 50MHz has 20ns pulse width
	// LCD requires minimum of 230ns, 16 * 20ns = 320ns
	parameter	SUSTAINED_PULSES	=	16;
	
	
	/*
	 * Internal registers.
	 */
	reg		[4:0]	pulse_counter;
	reg		[1:0]	state;
	reg				reg_pre_start, reg_start;
	reg				reg_lcd_en;
	

	assign	lcd_data	=	data;
	// RW, EN, RS, ON, BLON
	// only write to LCD, so RW=0
	assign	lcd_ctrl = {1'b0, reg_lcd_en, rs, 1'b1, 1'b1};
	
	
	/*
	 * FSM state definitions.
	 */
	parameter	[1:0]	WAIT			= 2'd0,
							BEGIN			= 2'd1,
							HOLD_DATA	= 2'd2,
							END			= 2'd3;
							
	always@(posedge clock or negedge reset) begin
		if (!reset) begin
			lcd_done			<=	1'b0;
			reg_lcd_en		<=	1'b0;
			reg_pre_start	<=	1'b0;
			reg_start		<=	1'b0;
			pulse_counter	<=	5'd0;
			state				<=	WAIT;
		end
		else begin
			//////	Input Start Detect ///////
			reg_pre_start <= write_start;
			if ({reg_pre_start,write_start} == 2'b01) begin
				reg_start	<=	1'b1;
				lcd_done		<=	1'b0;
			end
			//////////////////////////////////
			if (reg_start) begin
				case(state)
				WAIT:	begin
					state	<=	BEGIN;
				end
				
				BEGIN: begin
					reg_lcd_en	<=	1'b1;
					state			<=	HOLD_DATA;
				end
				
				HOLD_DATA:	begin					
					if(pulse_counter < SUSTAINED_PULSES)
						pulse_counter	<=	pulse_counter+5'd1;
					else
						state				<=	END;
				end
				
				END:	begin
					reg_lcd_en		<=	1'b0;
					reg_start		<=	1'b0;
					lcd_done			<=	1'b1;
					pulse_counter	<=	0;
					state				<=	WAIT;
				end
				endcase
			end
		end
	end

endmodule
