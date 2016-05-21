module testbench (
	CLOCK_50,						//	50 MHz
	
	////////////////////	LCD Module 16X2		////////////////
	LCD_ON,							//	LCD Power ON/OFF
	LCD_BLON,						//	LCD Back Light ON/OFF
	LCD_RW,							//	LCD Read/Write Select, 0 = Write, 1 = Read
	LCD_EN,							//	LCD Enable
	LCD_RS,							//	LCD Command/Data Select, 0 = Command, 1 = Data
	LCD_DATA,						//	LCD Data bus 8 bits
	
	debug_sw
);

	input				CLOCK_50;				//	50 MHz
	
	inout	[7:0]		LCD_DATA;				//	LCD Data bus 8 bits
	output			LCD_ON;					//	LCD Power ON/OFF
	output			LCD_BLON;				//	LCD Back Light ON/OFF
	output			LCD_RW;					//	LCD Read/Write Select, 0 = Write, 1 = Read
	output			LCD_EN;					//	LCD Enable
	output			LCD_RS;					//	LCD Command/Data Select, 0 = Command, 1 = Data
	
	input				debug_sw;
	
	wire		DLY_RST;
	wire	[4:0]	wire_lcd_ctrl;
	
	reset_gen r0 (
		.clock	(CLOCK_50), 
		.reset	(DLY_RST)	
	);
		
	lcd_bridge u5 (	
		.clock		(CLOCK_50),
		.reset		(DLY_RST),
		
		.insert		(debug_sw),
		.new_record	({4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8}),
		
		//	LCD Side
		.lcd_data	(LCD_DATA),
		.lcd_ctrl	(wire_lcd_ctrl)
	);
	
	assign {LCD_RW, LCD_EN, LCD_RS, LCD_ON, LCD_BLON} = wire_lcd_ctrl;
	
endmodule
