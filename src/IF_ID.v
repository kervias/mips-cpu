
`include "defines.v"

module IF_ID(
	// INPUT
	input wire rst,
	input wire clk,
	input wire[`InsAddrWidth] if_pc,
	input wire[`InsWidth] if_ins,
	input wire[5:0] stall,

	//OUTPUT
	output reg[`InsAddrWidth] id_pc,
	output reg[`InsWidth] id_ins
);

	always@(posedge clk)
	begin
		if(rst == `RstEnable)
		begin
			id_pc <= `ZeroWord;
			id_ins <= `ZeroWord;
		end
		else
		begin
			if(stall[1] == `ENABLE && stall[2] == `DISABLE)
			begin
				id_pc <= `ZeroWord;
				id_ins <= `ZeroWord;
			end
			else if(stall[1] == `DISABLE)
			begin
				id_pc <= if_pc;
				id_ins <= if_ins;
			end
		end
	end

endmodule
