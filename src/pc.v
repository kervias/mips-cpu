
`include "defines.v"

module pc(
	
	// ---- input -----
	input wire rst,
	input wire clk,
	
	input wire branchEN,
	input wire[`RegDataBus] branchAddr,	
	
	input wire[5:0] stall,
	
	// ---- output ----
	output reg[`InsAddrWidth] pc,
	output reg insEn
);
	
	// ******* maybe should init pc = 0 there *************
	
	// judge <rst> state
	always@(posedge clk)
	begin
		if(rst == `RstEnable) 
		begin
			insEn <= `InsDisable;
			pc <= `ZeroWord;
		end
		else
		begin
			insEn <= `InsEnable;
		end
	end
	
	always@(posedge clk)
	begin
		if(insEn == `DISABLE)
			pc <= `ZeroWord;
		else
		begin
			if(stall[0] == `DISABLE)
			begin
				if(branchEN == `ENABLE)
					pc <= branchAddr;
				else
				pc <= pc + 4;
			end

		end
	
	end
endmodule
