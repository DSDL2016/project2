module bcd2seg (
	input			[3:0]	bcd,
	input					blank,
	input					common_anode,
	output reg	[6:0]	seven_segment
);

	always @ (bcd or blank or common_anode) begin
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
		endcase 
		if (blank == 1'b1) 			seven_segment = 7'b000_0000 ;
		if (common_anode == 1'b1) 	seven_segment = ~seven_segment ;
	end

endmodule
