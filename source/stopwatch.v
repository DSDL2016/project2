module stopwatch (
	input					clock,
	input					run,
	input					reset,
	output [7*4-1:0]	epoch
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
	wire 			internal_clock = (clock_100 & run);
	reg	[6:0]	unit_time	[0:3];
	
	integer ut_idx;
	initial begin
		for (ut_idx = 0; ut_idx < 4; ut_idx = ut_idx+1)
			unit_time[ut_idx] <= 7'd0;
	end
	
	always @(posedge internal_clock or posedge reset) begin
		if (reset) begin
			for (ut_idx = 0; ut_idx < 4; ut_idx = ut_idx+1) begin
				unit_time[ut_idx] <= 7'd0;
			end
		end
		else begin
			unit_time[0] <= unit_time[0] + 7'd1;
		
			if (unit_time[0] == 7'd100) begin
				unit_time[0] <= 7'd0;
				unit_time[1] <= unit_time[1] + 6'd1;
			end
		
			if (unit_time[1] == 6'd60) begin 
				unit_time[1] <= 6'd0;
				unit_time[2] <= unit_time[2] + 6'd1;
			end
	
			if (unit_time[2] == 6'd60) begin
				unit_time[2] <= 6'd0;
				unit_time[3] <= unit_time[3] + 6'd1;
			end
	
			if (unit_time[3] == 6'd24) begin
				unit_time[3] <= 6'd0;
				// TODO: indicator for overflow
			end
		end
	end
	
	// expand 2d array to 1d array
	genvar ut_flat_idx;
	generate
		for (ut_flat_idx = 0; ut_flat_idx < 4; ut_flat_idx = ut_flat_idx+1) begin: ASSIGN_EPO
			assign epoch[7*(ut_flat_idx+1)-1 -: 7] = unit_time[ut_flat_idx];
		end
	endgenerate
	
endmodule
