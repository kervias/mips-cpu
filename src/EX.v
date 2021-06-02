`include "defines.v"


module EX(
	// input
	input wire rst,
	input wire[`InsDataBus] inst,
	input wire[`RegDataBus] reg1Data,
	input wire[`RegDataBus] reg2Data,
	input wire wrn_i,
	input wire[`RegAddrBus] wrAddr_i,
	
	input wire[`ALUOpBus] alu_op,
	input wire[`ALUSelBus] alu_sel,
	
	// output
	output reg[`RegAddrBus] wrAddr_o,
	output reg wrn_o,
	output reg[`RegDataBus] result,


	// HILO input and output
	input wire[`RegDataBus] regData_HI, // from HI
	input wire[`RegDataBus] regData_LO, // from LO
	// handle raw for HI and LO
	input wire mem_wrn_HILO_i,
	input wire[`RegDataBus] mem_wrData_HI_i,
	input wire[`RegDataBus] mem_wrData_LO_i,
	input wire wb_wrn_HILO_i,
	input wire[`RegDataBus] wb_wrData_HI_i,
	input wire[`RegDataBus] wb_wrData_LO_i,
	
	output reg wrn_HILO_o,
	output reg[`RegDataBus] wrData_HI_o,
	output reg[`RegDataBus] wrData_LO_o,

	// output to mem
	output wire[`ALUOpBus] alu_op_o,
	output wire[`RegDataBus] mem_addr_o,
	output wire[`RegDataBus] mem_data_o
);
	
	reg[`RegDataBus] logic_res; // store logical result
	reg[`RegDataBus] shift_res; // store shift result
	reg[`RegDataBus] move_res;  // store move result
	reg[`RegDataBus] arith_res; // store arith result
	reg[`DRegDataBus] mult_res;  // store multiply result

	reg[`RegDataBus] new_HI; // get the latest value of HI to solve raw conflict
	reg[`RegDataBus] new_LO; // same above

	assign alu_op_o = alu_op;
	assign mem_addr_o = reg1Data + {{16{inst[15]}}, inst[15:0]};
	assign mem_data_o = reg2Data;

	// define some variables for arithmetic compute
	wire overflow;
	wire reg1_lt_reg2;
	wire[`RegDataBus] sum;
	wire[`RegDataBus] reg2Data_plus;
	

	assign reg2Data_plus = (alu_op == `ALU_OP_SUB || alu_op == `ALU_OP_SUBU || alu_op == `ALU_OP_SLT)?((~reg2Data)+1):reg2Data;
	assign sum = reg1Data + reg2Data_plus;
	assign overflow = (!reg1Data[31] && !reg2Data_plus[31] && sum[31]) || (reg1Data[31] && reg2Data_plus[31] && !sum[31]);
	//assign reg_lt_reg2 = (alu_op == `ALU_OP_SLTU)?(reg1Data < reg2Data):((reg1Data[31] && !reg2Data[31]) || (reg1Data[31] && reg2Data[31] && sum[31]) || (!reg1Data[31] && !reg2Data[31] && sum[31]));
	assign reg1_lt_reg2 = ((alu_op == `ALU_OP_SLT))?
                         ((reg1Data[31] && !reg2Data[31]) || 
                         (!reg1Data[31] && !reg2Data[31] && sum[31])||
			                   (reg1Data[31] && reg2Data[31] && sum[31]))
                         :(reg1Data < reg2Data);
	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			arith_res <= `ZeroWord;
		end
		else
		begin
			case(alu_op)
				`ALU_OP_ADD,`ALU_OP_ADDI,`ALU_OP_ADDU,`ALU_OP_ADDIU,`ALU_OP_SUB,`ALU_OP_SUBU:
					begin
						arith_res <= sum;
					end
				`ALU_OP_SLT, `ALU_OP_SLTU:
					begin
						arith_res <= {31'b0,reg1_lt_reg2};
					end
				`ALU_OP_CLZ:
					begin
						arith_res <= 
						  reg1Data[31] ? 0 : reg1Data[30] ? 1 :
                          reg1Data[29] ? 2 : reg1Data[28] ? 3 :
                          reg1Data[27] ? 4 : reg1Data[26] ? 5 :
                          reg1Data[25] ? 6 : reg1Data[24] ? 7 :
                          reg1Data[23] ? 8 : reg1Data[22] ? 9 :
                          reg1Data[21] ? 10 : reg1Data[20] ? 11 :
                          reg1Data[19] ? 12 : reg1Data[18] ? 13 :
                          reg1Data[17] ? 14 : reg1Data[16] ? 15 :
                          reg1Data[15] ? 16 : reg1Data[14] ? 17 :
                          reg1Data[13] ? 18 : reg1Data[12] ? 19 :
                          reg1Data[11] ? 20 : reg1Data[10] ? 21 :
                          reg1Data[9]  ? 22 : reg1Data[8]  ? 23 :
                          reg1Data[7]  ? 24 : reg1Data[6]  ? 25 :
                          reg1Data[5]  ? 26 : reg1Data[4]  ? 27 :
                          reg1Data[3]  ? 28 : reg1Data[2]  ? 29 :
                          reg1Data[1]  ? 30 : reg1Data[0]  ? 31 : 32;
					end
				`ALU_OP_CLO:
					begin
						arith_res <=
						  !reg1Data[31] ? 0 : !reg1Data[30] ? 1 :
                          !reg1Data[29] ? 2 :!reg1Data[28] ? 3 : 
                          !reg1Data[27] ? 4 : !reg1Data[26] ? 5 :
                          !reg1Data[25] ? 6 : !reg1Data[24] ? 7 : 
                          !reg1Data[23] ? 8 : !reg1Data[22] ? 9 : 
                          !reg1Data[21] ? 10 : !reg1Data[20] ? 11 :
                          !reg1Data[19] ? 12 : !reg1Data[18] ? 13 : 
                          !reg1Data[17] ? 14 : !reg1Data[16] ? 15 : 
                          !reg1Data[15] ? 16 : !reg1Data[14] ? 17 : 
                          !reg1Data[13] ? 18 : !reg1Data[12] ? 19 : 
                          !reg1Data[11] ? 20 :!reg1Data[10] ? 21 : 
                          !reg1Data[9] ? 22 : !reg1Data[8] ? 23 : 
                          !reg1Data[7] ? 24 : !reg1Data[6] ? 25 : 
                          !reg1Data[5] ? 26 : !reg1Data[4] ? 27 : 
                          !reg1Data[3] ? 28 : !reg1Data[2] ? 29 : 
                          !reg1Data[1] ? 30 : !reg1Data[0] ? 31 : 32;
					end
				default:
					begin
						arith_res <= `ZeroWord;
					end
			endcase
		end
	end

	// multiply varaibles

	wire[`RegDataBus] mult1_plus;
	wire[`RegDataBus] mult2_plus;
	wire[`DRegDataBus] mult_temp;

	assign mult1_plus = ((alu_op == `ALU_OP_MUL || alu_op == `ALU_OP_MULT) && reg1Data[31])?((~reg1Data)+1):reg1Data;
	assign mult2_plus = ((alu_op == `ALU_OP_MUL || alu_op == `ALU_OP_MULT) && reg2Data[31])?((~reg2Data)+1):reg2Data;
	assign mult_temp = mult1_plus * mult2_plus;
	
	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			mult_res <= {`ZeroWord,`ZeroWord};
		end
		else
		begin
			if(alu_op == `ALU_OP_MUL || alu_op == `ALU_OP_MULT && (reg1Data[31] ^ reg2Data[31] == 1'b1))
			begin
				mult_res <= (~mult_temp) + 1;
			end
			else
			begin
				mult_res <= mult_temp;
			end
		end
	end


	// get the lastest value of HI and LO
	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			new_HI <= `ZeroWord;
			new_LO <= `ZeroWord;
		end
		else
		begin
			if(mem_wrn_HILO_i == `ENABLE)
			begin
				new_HI <= mem_wrData_HI_i;
				new_LO <= mem_wrData_LO_i;
			end
			else if(wb_wrn_HILO_i == `ENABLE)
			begin
				new_HI <= wb_wrData_HI_i;
				new_LO <= wb_wrData_LO_i;
			end
			else
			begin
				new_HI <= regData_HI;
				new_LO <= regData_LO;
			end
		end

	end


	// for MFHI, MFLO, MOVN, MOVZ inst
	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			move_res <= `ZeroWord;
		end
		else
		begin
			case(alu_op)
			`ALU_OP_MOVZ:
				begin
					move_res <= reg1Data;
				end
			`ALU_OP_MOVN:
				begin
					move_res <= reg1Data;
				end
			`ALU_OP_MFHI:
				begin
					move_res <= new_HI;
				end
			`ALU_OP_MFLO:
				begin
					move_res <= new_LO;
				end
			default:
				begin
					move_res <= `ZeroWord;
				end
			endcase
		end
	end



	//according to alu_op to compute result
	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			logic_res <= `ZeroWord;
		end
		else
		begin
			case(alu_op)
			`alu_op_or:
				begin
					logic_res <= reg1Data | reg2Data;
				end
			`ALU_OP_AND:
				begin
					logic_res <= reg1Data & reg2Data;
				end
			`ALU_OP_XOR:
				begin
					logic_res <= reg1Data ^ reg2Data;
				end
			`ALU_OP_NOR:
				begin
					logic_res <= ~(reg1Data | reg2Data);
				end
			default: 
				begin
					logic_res <= `ZeroWord;
				end
			endcase
		end
	end

	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			shift_res <= `ZeroWord;
		end
		else
		begin
			case(alu_op)
			`ALU_OP_SLL:
				begin
					shift_res <= reg2Data << reg1Data[4:0];
				end
			`ALU_OP_SRL:
				begin
					shift_res <= reg2Data >> reg1Data[4:0];
				end
			`ALU_OP_SRA:
				begin
					shift_res <= ({32{reg2Data[31]}}<<(6'd32-{1'b0,reg1Data[4:0]})) | reg2Data >> reg1Data[4:0];
				end
			default: 
				begin
					shift_res <= `ZeroWord;
				end
			endcase
		end
	end


	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			wrn_o <= `DISABLE;
			wrAddr_o <= 5'b00000;
			result <= `ZeroWord;
		end
		else
		begin
			if(((alu_op == `ALU_OP_ADD) || (alu_op == `ALU_OP_ADDI) || (alu_op == `ALU_OP_SUB)) && (overflow == 1'b1)) 
			begin
	   			wrn_o <= `DISABLE;
			end
			else
			begin
				wrn_o <= wrn_i;
			end
			wrAddr_o <= wrAddr_i;
			result <= `ZeroWord;
			case(alu_sel)
			`ALU_SEL_LOGIC:
				begin
					result <= logic_res;
				end
			`ALU_SEL_SHIFT:
				begin
					result <= shift_res;
				end
			`ALU_SEL_MOVE:
				begin
					result <= move_res;
				end
			`ALU_SEL_ARITH:
				begin
					result <= arith_res;
				end
			`ALU_SEL_MUL: // fro inst MUL
				begin
					result <= mult_res[31:0];
				end
			default:
				begin
					result <= `ZeroWord;
				end
			endcase
		end
	end

	// FOR MTHI and MTLO inst
	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			wrn_HILO_o <= `DISABLE;
			wrData_HI_o <= `ZeroWord;
			wrData_LO_o <= `ZeroWord;
		end
		else
		begin
			wrn_HILO_o <= `DISABLE;
			wrData_HI_o <= `ZeroWord;
			wrData_LO_o <= `ZeroWord;
			if(alu_op == `ALU_OP_MTHI)
			begin
				wrn_HILO_o <= `ENABLE;
				wrData_HI_o <= regData_HI;
				wrData_LO_o <= new_LO;
			end
			else if(alu_op == `ALU_OP_MTLO)
			begin
				wrn_HILO_o <= `ENABLE;
				wrData_HI_o <= new_HI;
				wrData_LO_o <= regData_LO;
			end
			else if(alu_op == `ALU_OP_MULT || alu_op == `ALU_OP_MULTU)
			begin
				wrn_HILO_o <= `ENABLE;
				wrData_HI_o <= mult_res[63:32];
				wrData_LO_o <= mult_res[31:0];				
			end
		end
	end
	

endmodule

