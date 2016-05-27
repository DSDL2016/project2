module bcd2seg (
	input			[3:0]	bcd,
	input					blank,
	input					active_low,
	output reg	[6:0]	seven_segment
);

	always @ (bcd or blank or active_low) begin
		seven_segment = 7'b000_0000 ;
		case (bcd)
			0: seven_segment = 7'b0111111;
			1: seven_segment = 7'b0000110;
			2: seven_segment = 7'b1011011;
			3: seven_segment = 7'b1001111;
			4: seven_segment = 7'b1100110;
			5: seven_segment = 7'b1101101;
			6: seven_segment = 7'b1111101;
			7: seven_segment = 7'b0000111;
			8: seven_segment = 7'b1111111;
			9: seven_segment = 7'b1100111;
			default: seven_segment = 7'b0000000;
		endcase 
		if (blank == 1'b1) 			seven_segment = 7'b0000000 ;
		if (active_low == 1'b1) 	seven_segment = ~seven_segment ;
	end

endmodule
