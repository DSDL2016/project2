module lcd_bridge (
	input					clock,
	input					reset,
	
	input					insert,
	input		[31:0]	new_record,
	input					clear,
	
	output				busy,
	
	//	LCD interface
	output	[7:0]		lcd_data,
	output	[4:0]		lcd_ctrl
);
	
	/*
	 * Internal wires and registers.
	 */
	reg	[2:0]		state;
	reg	[17:0]	counter;
	
	reg	[5:0]		lut_index;
	reg	[8:0]		lut_data;
	
	reg				reg_lcd_start;
	
	reg	[7:0]		reg_lcd_data;
	reg				reg_lcd_rs;
	
	wire				wire_lcd_done;
	reg				reg_update_busy;
	
	reg				reg_pre_insert, reg_insert;
	reg				reg_pre_clear, reg_clear;
	reg	[8:0]		records	[0:1][0:10];
	
	
	/*
	 * Set the records as blank at start.
	 */
	initial begin
		integer i, j;
		for (i = 0; i < 2; i = i+1) begin
			for (j = 0; j < 11; j = j+1) begin
				records[i][j] <= 9'h120;
			end
		end
	end
	
	/*
	 * LCD position definitions.
	 */
	parameter	LCD_INTIAL			 =	0;
	parameter	LCD_LINE1			 =	5;
	parameter	LCD_CH_LINE			 =	LCD_LINE1+11;
	parameter	LCD_LINE2			 =	LCD_LINE1+11+1;
	parameter	LUT_SIZE				 =	LCD_LINE1+22+1;
	
	
	/*
	 * FSM state definitions.
	 */
	parameter	[2:0]	BEGIN					= 3'd0,
							CHECK_BUSY_FLAG	= 3'd1,
							DELAY					= 3'd2,
							FETCH_DATA			= 3'd3;
							
	always @(posedge clock or negedge reset) begin
		if (!reset) begin
			counter				<=	0;
			reg_lcd_start		<=	0;
			reg_lcd_data		<=	0;
			reg_lcd_rs			<=	0;
			lut_index			<=	0;
			reg_update_busy	<= 0;
			state					<=	BEGIN;
		end
		else begin
			// detect insert signal 
			reg_pre_insert <= insert;
			if ({reg_pre_insert, insert} == 2'b01) begin
				reg_insert	<=	1'b1;
			end
			
			// detect clear signal 
			reg_pre_clear <= clear;
			if ({reg_pre_clear, clear} == 2'b01) begin
				reg_clear	<=	1'b1;
			end
			
			if (reg_insert) begin
				integer i;
				for (i = 0; i < 11; i = i+1) begin
					records[1][i] <= records[0][i];
					case (i)
					2, 5: 	records[0][i] <= 9'h13A;
					8:			records[0][i] <= 9'h12E;
					0, 1:		records[0][i] <= {1'b1, 4'b0011, new_record[i*4 +: 4]};
					3, 4:		records[0][i] <= {1'b1, 4'b0011, new_record[(i-1)*4 +: 4]};
					6, 7: 	records[0][i] <= {1'b1, 4'b0011, new_record[(i-2)*4 +: 4]};
					9, 10:	records[0][i] <= {1'b1, 4'b0011, new_record[(i-3)*4 +: 4]};
					endcase
				end
				
				lut_index	<= 0;
				state			<= BEGIN;
				
				reg_insert	<= 0;
			end
			else if (reg_clear) begin
				// write blank to cells
				integer i, j;
				for (i = 0; i < 2; i = i+1) begin
					for (j = 0; j < 11; j = j+1) begin
						records[i][j] <= 9'h120;
					end
				end
				
				lut_index	<= 0;
				state			<= BEGIN;
				
				reg_clear	<= 0;
			end
			
			if (lut_index < LUT_SIZE) begin
				case (state)
				BEGIN:	begin
					reg_update_busy	<= 1;
					reg_lcd_data		<=	lut_data[7:0];
					reg_lcd_rs			<=	lut_data[8];
					reg_lcd_start		<=	1;
					state					<=	CHECK_BUSY_FLAG;
				end
				
				CHECK_BUSY_FLAG:	begin
					if (wire_lcd_done) begin
						reg_lcd_start	<=	0;
						state				<=	DELAY;					
					end
				end
				
				DELAY:	begin
					if (counter < 18'h3FFFE)
						counter	<=	counter+18'd1;
					else begin
						counter	<=	18'd0;
						state		<=	FETCH_DATA;
					end
				end
				
				FETCH_DATA: begin
					lut_index	<=	lut_index+1;
					state			<=	BEGIN;
				end
				endcase
			end
			else begin
				reg_update_busy 	<= 0;
			end
		end
	end
	
	
	/*
	 * Instruction lookup table.
	 */
	always begin
		case (lut_index)
		//	initialize
		LCD_INTIAL+0:	lut_data	<=	9'h038;	// 8-bit data, 2 lines, 5x11 font
		LCD_INTIAL+1:	lut_data	<=	9'h00C;	// display on, no cursor (and no blinking)
		LCD_INTIAL+2:	lut_data	<=	9'h001;	// clear display
		LCD_INTIAL+3:	lut_data	<=	9'h006;	// cursor pos++, no screen shift
		LCD_INTIAL+4:	lut_data	<=	9'h080;	// set DDRAM to 0x00 (row0, col0)
		
		//	line 1
		LCD_LINE1+0:	lut_data	<=	records[0][0];
		LCD_LINE1+1:	lut_data	<= records[0][1];	
		LCD_LINE1+2:	lut_data	<=	records[0][2];
		LCD_LINE1+3:	lut_data	<=	records[0][3];	
		LCD_LINE1+4:	lut_data	<=	records[0][4];
		LCD_LINE1+5:	lut_data	<=	records[0][5];
		LCD_LINE1+6:	lut_data	<=	records[0][6];
		LCD_LINE1+7:	lut_data	<=	records[0][7];
		LCD_LINE1+8:	lut_data	<=	records[0][8];
		LCD_LINE1+9:	lut_data	<=	records[0][9];
		LCD_LINE1+10:	lut_data	<=	records[0][10];
		
		//	change Line
		LCD_CH_LINE:	lut_data	<=	9'h0C0;	// set DDRAM to 0x40 (row1, col0)
		
		//	line 2
		LCD_LINE2+0:	lut_data	<=	records[1][0];
		LCD_LINE2+1:	lut_data	<=	records[1][1];
		LCD_LINE2+2:	lut_data	<=	records[1][2];
		LCD_LINE2+3:	lut_data	<=	records[1][3];
		LCD_LINE2+4:	lut_data	<=	records[1][4];
		LCD_LINE2+5:	lut_data	<=	records[1][5];
		LCD_LINE2+6:	lut_data	<= records[1][6];
		LCD_LINE2+7:	lut_data	<=	records[1][7];
		LCD_LINE2+8:	lut_data	<=	records[1][8];
		LCD_LINE2+9:	lut_data	<=	records[1][9];
		LCD_LINE2+10:	lut_data	<=	records[1][10];
		
		default:			lut_data	<=	9'h000;
		endcase
	end
	
	
	lcd_controller controller_module (
		.clock			(clock),
		.reset			(reset),
		
		.data				(reg_lcd_data),
		.rs				(reg_lcd_rs),
		.write_start	(reg_lcd_start),
		.lcd_done		(wire_lcd_done),
		
		//	LCD Interface
		.lcd_data		(lcd_data),
		.lcd_ctrl		(lcd_ctrl)
	);
	
	assign busy = reg_update_busy;

endmodule
