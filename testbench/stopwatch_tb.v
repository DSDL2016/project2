module stopwatch_tb ();
	reg clock = 0;
	reg run = 1;
	reg reset;
	wire [5:0] hour, min, sec;
	wire	[7:0]			m_sec;
	stopwatch sw (
		.clock 		(clock),
		.run			(run),
		.reset		(reset),
		.epoch	 ({hour, min, sec}),
		.m_epoch		(m_sec)
	);
  initial begin
    while (1) begin
#500
    $display("%d %d %d %d", hour, min, sec, m_sec);
    end
  end

  always begin
#1
    clock = ~clock;
  end
endmodule
