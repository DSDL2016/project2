module internal_timer (
	input								clock,
	
	// timer control
	input								run,
	input								reset,
	
	// actual time
	output [7*time_units-1:0]	timestamp,
	
	// timer status
	output reg						reg_busy
);
	
	// 4 time units: hour, minute, second, m_sec
	localparam time_units = 4;
	parameter [1:0]	M_SEC		= 2'd0,
							SECOND	= 2'd1,
							MINUTE	= 2'd2,
							HOUR		= 2'd3;
	// time unit restrictions
	parameter bit [6:0] time_unit_bound [0:3] = '{7'd100, 7'd60, 7'd60, 7'd24};
	
							
	/*
	 * 100Hz clock source.
	 */
	wire	int_clock;
	
	freq_100hz internal_clock (
		.clock_50m	(clock),
		.clock_100	(int_clock)
	);
	
	// controlled clock source, by the run signal
	wire	ctrl_clock = (int_clock & run);
	
	
	/*
	 * Internal counters.
	 */
	// additional slot is ignored
	reg	[6:0]	timestamp_reg	[0:4];
	
	integer i;
	task reset_timestamp;
		reg_busy <= 1;

		for (i = 0; i < 5; i = i+1)
			timestamp_reg[i] <= 7'd0;
		
		reg_busy <= 0;
	endtask
	
	
	/*
	 * Primary timer logic.
	 */
	initial begin
		reset_timestamp;
	end
	
	always @(posedge ctrl_clock or posedge reset) begin
		if (reset) begin
			reset_timestamp;
		end
		else begin
			// increase the m_sec slot
			timestamp_reg[M_SEC] <= timestamp_reg[M_SEC] + 7'd1;
			
			for (i = 0; i < 4; i = i+1) begin
				if (timestamp_reg[i] == time_unit_bound[i]) begin
					timestamp_reg[i] 		<= 7'd0;
					timestamp_reg[i+1]	<= timestamp_reg[i+1] + 7'd1;
				end
				
				// TODO: test for timestamp_reg[4] != 0 for overflow.
			end
		end
	end
	
	
	/*
	 * Expand the register to output.
	 */
	genvar j;
	generate
		for (j = 0; j < 4; j = j+1) begin: EXP_TIMESTAMP
			assign timestamp[7*(j+1)-1 -: 7] = timestamp_reg[j];
		end
	endgenerate
	
endmodule
