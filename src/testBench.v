`include "defines.v"
`timescale 1ns/1ns

module testBench();
	reg CLOCK;
	reg rst;

	initial
	begin
		CLOCK = 1'b0;
		forever #10 CLOCK = ~CLOCK;
	end
	
	initial
	begin
		rst = `ENABLE;
		#20 rst = `DISABLE;
		#1000 $stop;
	end

	min_sopc min_sopc_0
	(	
		.clk(CLOCK),
		.rst(rst)
	);





endmodule
