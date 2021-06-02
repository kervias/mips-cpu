
`include "defines.v"

module MEM_WB(
	//input
	input wire clk,
	input wire rst,
	
	input wire wrn_i,
	input wire[`RegAddrBus] wrAddr_i,
	input wire[`RegDataBus] wrData_i,
	
	input wire wrn_HILO_i,
	input wire[`RegDataBus] wrData_HI_i,
	input wire[`RegDataBus] wrData_LO_i,

	input wire[5:0] stall,
	//output
	output reg wrn_o,
	output reg[`RegAddrBus] wrAddr_o,
	output reg[`RegDataBus] wrData_o,
	
	output reg wrn_HILO_o,
	output reg[`RegDataBus] wrData_HI_o,
	output reg[`RegDataBus] wrData_LO_o
);

	always@(posedge clk)
	begin
		if(rst == `ENABLE)
		begin
			wrn_o <= `DISABLE;
			wrAddr_o <= 5'b00000;
			wrData_o <= `ZeroWord;
			wrn_HILO_o <= `DISABLE;
			wrData_HI_o <= `ZeroWord;
			wrData_LO_o <= `ZeroWord;
		end
		else
		begin
			if(stall[4] == `ENABLE && stall[5] == `DISABLE)
			begin
				wrn_o <= `DISABLE;
				wrAddr_o <= 5'b00000;
				wrData_o <= `ZeroWord;
				wrn_HILO_o <= `DISABLE;
				wrData_HI_o <= `ZeroWord;
				wrData_LO_o <= `ZeroWord;
			end
			else if(stall[4] == `DISABLE)
			begin
				wrn_o <= wrn_i;
				wrAddr_o <= wrAddr_i;
				wrData_o <= wrData_i;
				wrn_HILO_o <= wrn_HILO_i;
				wrData_HI_o <= wrData_HI_i;
				wrData_LO_o <= wrData_LO_i;
			end
		end
	end
endmodule
