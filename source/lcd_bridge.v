module lcd_bridge (
	input				clock,
	input				reset,
	
	// lcd module interface
	output	[7:0]	lcd_data,
	output	[4:0]	lcd_ctrl
);

	/*
	 * Internal registers.
	 */
	// bridge internal state
	reg	[2:0]		state;
	wire				reg_lcd_done;
	
	reg	[5:0]		lut_index;
	reg	[8:0]		lut_data;
	
	reg	[17:0]	delay_counter;
	
	// lcd control signals
	reg				mLCD_Start;
	reg	[7:0]		char_buffer;
	reg				reg_lcd_rs;
	
	
	/*
	 * Display parameters.
	 */
	parameter	LCD_INTIAL	=	0;
	parameter	LCD_LINE1	=	5;
	parameter	LCD_CH_LINE	=	LCD_LINE1+16;
	parameter	LCD_LINE2	=	LCD_LINE1+16+1;
	parameter	LUT_SIZE		=	LCD_LINE1+32+1;
	
	parameter	[2:0]		BEGIN				= 3'd0,
								CHECK_LCD_BUSY	= 3'd1,
								DELAY				= 3'd2,
								NEXT_DATA		= 3'd3;
	/*
	 * Display bridge state machine.
	 */
	always @(posedge clock or negedge reset) begin
		if (!reset) begin
			state				<=	0;
		
			lut_index		<=	0;
			
			delay_counter	<=	0;
			
			mLCD_Start		<=	0;
			char_buffer		<=	0;
			reg_lcd_rs		<=	0;
		end
		else if (lut_index < LUT_SIZE) begin
			case (state)
			BEGIN: begin
				char_buffer			<=	lut_data[7:0];
				reg_lcd_rs			<=	lut_data[8];
				mLCD_Start			<=	1;
				state					<=	1;
			end
			
			CHECK_LCD_BUSY: begin
				if(reg_lcd_done) begin
					mLCD_Start		<=	0;
					state				<=	2;					
				end
			end
			
			DELAY: begin
				if(delay_counter < 18'h3FFFE)
					delay_counter	<=	delay_counter+1;
				else begin
					delay_counter	<=	0;
					state				<=	3;
				end
			end
			
			NEXT_DATA: begin
				lut_index			<=	lut_index+1;
				state					<=	0;
			end
			endcase
		end
	end
	
	always begin
		case (lut_index)
		//	initialize
		LCD_INTIAL+0:	lut_data	<=	9'h038;	// function, 8-bit data, 2 display line, 5x11 font
		LCD_INTIAL+1:	lut_data	<=	9'h00C;	// display on, no cursor
		LCD_INTIAL+2:	lut_data	<=	9'h001;	// clear display
		LCD_INTIAL+3:	lut_data	<=	9'h006;	// cursor pos++, no screen shift
		LCD_INTIAL+4:	lut_data	<=	9'h080;	// set DDRAM to 0x00 (1st line)
		
		//	line 1
		LCD_LINE1+0:	lut_data	<=	9'h120;	//	Welcome to the
		LCD_LINE1+1:	lut_data	<=	9'h157;
		LCD_LINE1+2:	lut_data	<=	9'h165;
		LCD_LINE1+3:	lut_data	<=	9'h16C;
		LCD_LINE1+4:	lut_data	<=	9'h163;
		LCD_LINE1+5:	lut_data	<=	9'h16F;
		LCD_LINE1+6:	lut_data	<=	9'h16D;
		LCD_LINE1+7:	lut_data	<=	9'h165;
		LCD_LINE1+8:	lut_data	<=	9'h120;
		LCD_LINE1+9:	lut_data	<=	9'h174;
		LCD_LINE1+10:	lut_data	<=	9'h16F;
		LCD_LINE1+11:	lut_data	<=	9'h120;
		LCD_LINE1+12:	lut_data	<=	9'h174;
		LCD_LINE1+13:	lut_data	<=	9'h168;
		LCD_LINE1+14:	lut_data	<=	9'h165;
		LCD_LINE1+15:	lut_data	<=	9'h120;
		
		//	change line
		LCD_CH_LINE:	lut_data	<=	9'h0C0;	// set DDRAM to 0x40 (2nd line)
		
		//	line 2
		LCD_LINE2+0:	lut_data	<=	9'h141;	//	Altera DE2 Board
		LCD_LINE2+1:	lut_data	<=	9'h16C;
		LCD_LINE2+2:	lut_data	<=	9'h174;
		LCD_LINE2+3:	lut_data	<=	9'h165;
		LCD_LINE2+4:	lut_data	<=	9'h172;
		LCD_LINE2+5:	lut_data	<=	9'h161;
		LCD_LINE2+6:	lut_data	<=	9'h120;
		LCD_LINE2+7:	lut_data	<=	9'h144;
		LCD_LINE2+8:	lut_data	<=	9'h145;
		LCD_LINE2+9:	lut_data	<=	9'h132;
		LCD_LINE2+10:	lut_data	<=	9'h120;
		LCD_LINE2+11:	lut_data	<=	9'h142;
		LCD_LINE2+12:	lut_data	<=	9'h16F;
		LCD_LINE2+13:	lut_data	<=	9'h161;
		LCD_LINE2+14:	lut_data	<=	9'h172;
		LCD_LINE2+15:	lut_data	<=	9'h164;
		
		default:			lut_data	<=	9'h000;
		endcase
	end
					
	lcd_controller device (
		// host side interface
		.clock		(clock),
		.data			(char_buffer),
		.rs			(reg_lcd_rs),
		.start		(mLCD_Start),
		.done			(reg_lcd_done),
		
		// lcd module interface
		.lcd_data	(lcd_data_wire),
		.lcd_ctrl	(lcd_ctrl_wire)
	);

endmodule
