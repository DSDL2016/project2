module freq_100hz (
	input			clock_50m,
	output reg	clock_100
);

	reg	[17:0]	divider_counter;
	
	initial begin
		divider_counter <= 18'd0;
		clock_100 <= 1'b0;
	end
	
	// 50M / 100 = 500,000
	// cut at 500,000 / 2 = 250,000 to achieve 50% duty cycle
	// since we start from 0, so the cut point is located at 249,999
	always @(posedge clock_50m) begin
		if (divider_counter < 18'd249999) begin
			divider_counter <= divider_counter + 18'd1;
		end
		else begin
			divider_counter <= 18'd0;
			clock_100 <= ~clock_100;
		end
	end	

endmodule
