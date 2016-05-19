module stopwatch (
	input					clock,
	input					run,
	input					reset,
	output reg	[6:0]	hour, minute, second,
	output reg	[7:0]	m_sec
);
	
	/*
	 * Divide the 50Mhz input to 100Hz.
	 */
	reg	[17:0]	divider_counter;
	reg				clock_100;
	
	initial begin
		divider_counter <= 0;
		clock_100 <= 0;
	end
		
	always @(posedge clock) begin
		if (divider_counter < 249999) begin
			divider_counter <= divider_counter + 1;
		end
		else begin
			divider_counter <= 0;
			clock_100 <= ~clock_100;
		end
	end	
	
	
	/*
	 * Internal counters.
	 */
	initial begin
		hour 		<= 0;
		minute	<= 0;
		second 	<= 0;
		m_sec 	<= 0;
	end
	
	wire internal_clock = (clock_100 & run);
	
	always @(posedge internal_clock or posedge reset) begin
		if (reset) begin
			hour 		<= 0;
			minute 	<= 0;
			second 	<= 0;
			m_sec 	<= 0;
		end
		else begin
			m_sec <= m_sec + 1;
		
			if (m_sec == 100) begin
				m_sec <= 0;
				second <= second + 1;
			end
		
			if (second == 60) begin 
				second <= 0;
				minute <= minute + 1;
			end
	
			if (minute == 60) begin
				minute <= 0;
				hour <= hour + 1;
			end
	
			if (hour == 24) begin
				hour <= 0;
				// TODO: indicator for overflow
			end
		end
	end
	
endmodule
