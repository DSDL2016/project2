module debouncer(
	input 	clock,
	input 	key_in,
	input		active_low,
	output	key_out
);

	reg	key_debounced;
	
	/*
	 * Initial state..
	 */
	initial begin
		key_debounced = (active_low) ? 1'b1 : 1'b0;
	end

	/*
	 * Synchronize the switch input to the clock.
	 */
	reg key_sync_0;
	always @(posedge clock) begin
		key_sync_0 <= key_in; 
	end
	
	reg key_sync_1;
	always @(posedge clock) begin
		key_sync_1 <= key_sync_0;
	end

	/*
	 * Debounce the switch.
	 */
	reg [15:0] bounce_counter;
	always @(posedge clock) begin
		if (key_debounced == key_sync_1) begin
			bounce_counter <= 0;
		end
		else begin
			bounce_counter <= bounce_counter + 1'b1;  
			if (bounce_counter == 16'hffff) 
				key_debounced <= ~key_debounced;  
		end
	end
	
	/*
	 * Assign the output accordingly.
	 */
	assign key_out = (active_low) ? ~key_debounced : key_debounced;
	
endmodule
