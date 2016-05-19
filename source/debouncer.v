module debouncer(
	input 		clock,
	input 		PB,
	output reg	PB_db
);
	/*
	 * Initial state..
	 */
	initial begin
		PB_db = 1;
	end

	/*
	 * Synchronize the switch input to the clock.
	 */
	reg PB_sync_0;
	always @(posedge clock) begin
		PB_sync_0 <= PB; 
	end
	
	reg PB_sync_1;
	always @(posedge clock) begin
		PB_sync_1 <= PB_sync_0;
	end

	/*
	 * Debounce the switch.
	 */
	reg [15:0] PB_cnt;
	always @(posedge clock) begin
		if (PB_db == PB_sync_1) begin
			PB_cnt <= 0;
		end
		else begin
			PB_cnt <= PB_cnt + 1'b1;  
			if (PB_cnt == 16'hffff) 
				PB_db <= ~PB_db;  
		end
	end
	
endmodule
