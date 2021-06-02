
`include "defines.v"

module MEM(
	//input 
	input wire rst,
	input wire[`RegDataBus] result_i,
	input wire wrn_i,
	input wire[`RegAddrBus] wrAddr_i,

	input wire wrn_HILO_i,
	input wire[`RegDataBus] wrData_HI_i,
	input wire[`RegDataBus] wrData_LO_i,

	input wire[`ALUOpBus] alu_op_i,
	input wire[`RegDataBus] mem_wrdata_i,
	input wire[`RegDataBus] mem_addr_i,


	// input from dataMem
	input wire[`RegDataBus] mem_redata_i,
	
	//output
	output reg wrn_o,
	output reg[`RegDataBus] result_o,
	output reg[`RegAddrBus] wrAddr_o,

	output reg wrn_HILO_o,
	output reg[`RegDataBus] wrData_HI_o,
	output reg[`RegDataBus] wrData_LO_o,


	//output to dataMem
	output reg mem_wrn,
	output reg mem_ce,
	output reg[`RegDataBus] mem_wraddr,
	output reg[`RegDataBus] mem_wrdata
);

	always@(*)
	begin
		
		if(rst == `ENABLE)
		begin
			wrn_o <= `DISABLE;
			wrAddr_o <= 5'b00000;
			result_o <= `ZeroWord;
			wrn_HILO_o <= `DISABLE;
			wrData_HI_o <= `ZeroWord;
			wrData_LO_o <= `ZeroWord;
			// about mem
			mem_wrn <= `DISABLE;
			mem_ce <= `DISABLE;
			mem_wraddr <= `ZeroWord;
			mem_wrdata <= `ZeroWord;
		end
		else
		begin
			wrn_o <= wrn_i;
			wrAddr_o <= wrAddr_i;
			result_o <= result_i;
			wrn_HILO_o <= wrn_HILO_i;
			wrData_HI_o <= wrData_HI_i;
			wrData_LO_o <= wrData_LO_i;

			// about mem
			mem_wrn <= `DISABLE;
			mem_ce <= `DISABLE;
			mem_wraddr <= `ZeroWord;
			mem_wrdata <= `ZeroWord;
			case(alu_op_i)
				`ALU_OP_SW:
					begin
						mem_wrn <= `ENABLE;
						mem_ce <= `ENABLE;
						mem_wraddr <= mem_addr_i;
						mem_wrdata <= mem_wrdata_i;
					end
				`ALU_OP_LW:
					begin
						mem_wrn <= `DISABLE;
						mem_ce <= `ENABLE;
						mem_wraddr <= mem_addr_i;
						result_o <= mem_redata_i;
					end
				default:
					begin
					end
			endcase
		end

	end
endmodule
