module stopwatch (
	input						clock,
	input						run,
	input						reset,
	output	[6*3-1:0]	epoch,
	output	[9:0]			m_epoch
);
	
	/*
	 * Divide the 50Mhz input to 1kHz.
	 */
	reg	[14:0]	divider_counter;
	reg				clock_1k;
	
	initial begin
		divider_counter <= 0;
		clock_1k <= 0;
	end
		
	always @(posedge clock) begin
		if (divider_counter < 24999) begin
			divider_counter <= divider_counter + 1;
		end
		else begin
			divider_counter <= 0;
			clock_1k <= ~clock_1k;
		end
	end	
	
	
	/*
	 * Internal counters.
	 */
	reg	[5:0]	hour, minute, second;
	reg	[9:0]	m_sec;
	
	initial begin
		hour 		<= 0;
		minute	<= 0;
		second 	<= 0;
		m_sec 	<= 0;
	end
	
	always @(posedge reset) begin
		hour 		<= 0;
		minute 	<= 0;
		second 	<= 0;
		m_sec 	<= 0;
	end
	
	wire internal_clock = (clock_1k & run);
	
	always @(posedge internal_clock) begin
		if (m_sec < 1000)	begin
			m_sec <= m_sec + 1;
		end 
		else begin
			m_sec <= 0;
			second <= second + 1;
		end
	end
	
	assign @(posedge internal_clock) begin
		if (second < 60) begin
			second <= second + 1;
		end
		else begin 
			second <= 0;
			minute <= minute + 1;
		end
	end
	
	assign @(posedge internal_clock) begin
		if (minute < 60) begin
			minute <= minute + 1;
		end
		else begin
			minute <= 0;
			hour <= hour + 1;
		end
	end
	
	assign @(posedge internal_clock) begin
		if (hour < 24) begin
			hour <= hour + 1;
		end
		else begin
			hour <= 0;
			// TODO: indicator for overflow
		end
	end
	
	assign epoch 	= {hour, minute, second};
	assign m_epoch	= m_sec;
endmodule
