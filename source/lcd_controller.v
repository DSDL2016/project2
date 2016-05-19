module lcd_controller (
	// host side interface
	input 		clock,
	input			reset,
	input	[7:0]	data,
	input			iRS,
	input			start,
	output reg	done,
	
	// lcd module interface
	output		LCD_DATA,
	output		LCD_RW,
	output reg	LCD_EN,
	output		LCD_RS
);

	parameter	clock_divider	=	16;

	/*
	 * Internal registers.
	 */
	reg	[4:0]	Cont;	
	reg	[1:0]	ST;
	reg			preStart, mStart;

/////////////////////////////////////////////
//	Only write to LCD, bypass iRS to LCD_RS
assign	LCD_DATA	=	data; 
assign	LCD_RW		=	1'b0;
assign	LCD_RS		=	iRS;
/////////////////////////////////////////////

always@(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		done	<=	1'b0;
		LCD_EN	<=	1'b0;
		preStart<=	1'b0;
		mStart	<=	1'b0;
		Cont	<=	0;
		ST		<=	0;
	end
	else
	begin
		//////	Input Start Detect ///////
		preStart<=	start;
		if({preStart,start}==2'b01)
		begin
			mStart	<=	1'b1;
			done	<=	1'b0;
		end
		//////////////////////////////////
		if(mStart)
		begin
			case(ST)
			0:	ST	<=	1;	//	Wait Setup
			1:	begin
					LCD_EN	<=	1'b1;
					ST		<=	2;
				end
			2:	begin					
					if(Cont<clock_divider)
					Cont	<=	Cont+1;
					else
					ST		<=	3;
				end
			3:	begin
					LCD_EN	<=	1'b0;
					mStart	<=	1'b0;
					done	<=	1'b1;
					Cont	<=	0;
					ST		<=	0;
				end
			endcase
		end
	end
end

endmodule
