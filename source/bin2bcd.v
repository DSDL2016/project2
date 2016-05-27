module bin2bcd (
	input			[6:0]	bin,
	output reg	[3:0]	bcd1, bcd0
);
	
	reg	[7:0]	bcd;
	integer  i;
	always @ (bin) begin
		bcd1 = 4'd0 ;
		bcd0 = 4'd0 ;
		for (i = 0; i < 7; i = i+1) begin
			if (bcd0 >= 4'd5)	bcd0 = bcd0 + 4'd3 ;
			if (bcd1 >= 4'd5)	bcd1 = bcd1 + 4'd3 ;
			bcd = {bcd1, bcd0} ;
			bcd = bcd << 1;
			bcd[0] = bin[6-i] ;
			bcd1 = bcd[7:4] ;
			bcd0 = bcd[3:0] ;
		end
	end

endmodule
