module reset_gen (
	input			clock,
	output reg	reset
);

	reg	[19:0]	counter;
	
	initial begin
		counter <= 20'd0;
	end
	
	always @(posedge clock) begin
		// reset is active low
		// hold the reset signal for 2^20 * 20ns = 20.97ms
		if(counter != 20'hFFFFF) begin
			counter	<=	counter+20'd1;
			reset		<=	1'b0;
		end
		else begin
			reset		<=	1'b1;
		end
	end

endmodule
