module stopwatch (
	input					clock,
	input					run,
	input					reset,
	output reg	[5:0]	hour, minute, second,
	output reg	[6:0]	m_sec
);
	
	/*
	 * Divide the 50Mhz input to 100Hz.
	 */
	reg	[17:0]	divider_counter;
	reg				clock_100;
	
	initial begin
		divider_counter <= 18'd0;
		clock_100 <= 1'b0;
	end
		
	always @(posedge clock) begin
		if (divider_counter < 18'd249999) begin
			divider_counter <= divider_counter + 18'd1;
		end
		else begin
			divider_counter <= 18'd0;
			clock_100 <= ~clock_100;
		end
	end	
	
	
	/*
	 * Internal counters.
	 */
	initial begin
		hour 		<= 6'd0;
		minute	<= 6'd0;
		second 	<= 6'd0;
		m_sec 	<= 7'd0;
	end
	
	wire internal_clock = (clock_100 & run);
	
	always @(posedge internal_clock or posedge reset) begin
		if (reset) begin
			hour 		<= 6'd0;
			minute 	<= 6'd0;
			second 	<= 6'd0;
			m_sec 	<= 7'd0;
		end
		else begin
			m_sec <= m_sec + 7'd1;
		
			if (m_sec == 7'd100) begin
				m_sec <= 7'd0;
				second <= second + 6'd1;
			end
		
			if (second == 6'd60) begin 
				second <= 6'd0;
				minute <= minute + 6'd1;
			end
	
			if (minute == 6'd60) begin
				minute <= 6'd0;
				hour <= hour + 6'd1;
			end
	
			if (hour == 6'd24) begin
				hour <= 6'd0;
				// TODO: indicator for overflow
			end
		end
	end
	
endmodule
