`include "defines.v"

module ID_EX(
	//input
	input wire clk,
	input wire rst,
	input wire[`InsDataBus] id_inst,
	
	input wire[`RegDataBus] id_reg1Data,
	input wire[`RegDataBus] id_reg2Data,
	
	input wire[`ALUOpBus] id_alu_op,
	input wire[`ALUSelBus] id_alu_sel,

	input wire[`RegAddrBus] id_wrAddr,
	input wire id_wrn,

	input wire id_next_delayslotEn,

	input wire[5:0] stall,
	
	//output
	output reg[`RegDataBus] ex_reg1Data,
	output reg[`RegDataBus] ex_reg2Data,
	
	output reg[`ALUOpBus] ex_alu_op,
	output reg[`ALUSelBus] ex_alu_sel,
	
	output reg[`RegAddrBus] ex_wrAddr,
	output reg ex_wrn,

	output reg ex_next_delayslotEn,
	output reg[`InsDataBus] ex_inst
);


	always@(posedge clk)
	begin
		if(rst == `ENABLE)
		begin
			ex_reg1Data <= `ZeroWord;
			ex_reg2Data <= `ZeroWord;
			ex_alu_sel <= `ALU_NOP;
			ex_alu_op <= `alu_op_nop;
			ex_wrn <= `DISABLE;
			ex_wrAddr <= 5'b00000;
			ex_next_delayslotEn <= `DISABLE;
			ex_inst <= `ZeroWord;
		end
		else
		begin
			if(stall[2] == `ENABLE && stall[3] == `DISABLE)
			begin
				ex_reg1Data <= `ZeroWord;
				ex_reg2Data <= `ZeroWord;
				ex_alu_sel <= `ALU_NOP;
				ex_alu_op <= `alu_op_nop;
				ex_wrn <= `DISABLE;
				ex_wrAddr <= 5'b00000;
				ex_next_delayslotEn <= `DISABLE;
				ex_inst <= `ZeroWord;
			end
			else if(stall[2] == `DISABLE)
			begin
				ex_reg1Data <= id_reg1Data;
				ex_reg2Data <= id_reg2Data;
				ex_alu_op <= id_alu_op;
				ex_alu_sel <= id_alu_sel;
				ex_wrn <= id_wrn;
				ex_wrAddr <= id_wrAddr;
				ex_next_delayslotEn <= id_next_delayslotEn;
				ex_inst <= id_inst;
			end
		end

	end
		
endmodule

