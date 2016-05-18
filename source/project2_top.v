module project2-top (
	input		start_pause,
	input		lap,
	input		reset,
	input		clear
);
	
	control_fsm ctrl_logic (
		.clock			(),
		.stimulus		({start_pause, lap, reset, clear}),
		.state			()
	);

endmodule
