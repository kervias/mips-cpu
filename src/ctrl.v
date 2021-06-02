`include "defines.v"

module ctrl(
	input wire rst,
	input wire id_stall,
	//input wire ex_stall,

	output reg[5:0] stall

);

	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			stall <= 6'b000000;
		end
		else
		begin
			if(id_stall == `ENABLE)
			begin
				stall <= 6'b000111;
			end
			else
			begin
				stall <= 6'b000000;
			end
		end
	end

endmodule
