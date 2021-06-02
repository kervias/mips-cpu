`include "defines.v"

module HILO(
	input wire clk,
	input wire rst,
	
	input wire wrn_HILO_i,
	input wire[`RegDataBus] wrData_HI_i,
	input wire[`RegDataBus] wrData_LO_i,
	
	output reg[`RegDataBus] HIData_o,
	output reg[`RegDataBus] LOData_o
);
	/*
	reg[`RegDataBus] HI;
	reg[`RegDataBus] LO;
		
	initial
	begin
		HI <= `ZeroWord;
		LO <= `ZeroWord;
	end	
	

	assign HIData_o = HI;
	assign LOData_o = LO;
	*/
	always@(posedge clk)
	begin
		if(rst == `ENABLE)
		begin
			HIData_o <= `ZeroWord;
			LOData_o <= `ZeroWord;
			//HI <= `ZeroWord;
			//LO <= `ZeroWord;
		end
		else
		begin
			if(wrn_HILO_i == `ENABLE)
			begin
				//HI <= wrData_HI_i;
				//LO <= wrData_LO_i;
				HIData_o <= wrData_HI_i;
				LOData_o <= wrData_LO_i;
			end
		end
	end
	
endmodule

