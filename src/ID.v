
`include "defines.v"

module ID(
	// ------ input ------
	input wire rst,
	input wire[`InsDataBus] inst,
	input wire[`InsAddrWidth] pc,
	input wire[`RegDataBus] reData1_in,
	input wire[`RegDataBus] reData2_in,

	//--------------handle raw ---------------------------

	input wire ex_wrn,
	input wire[`RegAddrBus] ex_wrAddr,
	input wire[`RegDataBus] ex_wrData,
	
	input wire mem_wrn,
	input wire[`RegAddrBus] mem_wrAddr,
	input wire[`RegDataBus] mem_wrData,

	// branch
	input wire delayslotEn,

	// next stage inst load stall
	input wire[`ALUOpBus] last_alu_op,

	//-------------------------------------------

	// ------ output -------
	output reg ren1,
	output reg ren2,
	output reg[`RegAddrBus] reData1Addr,
	output reg[`RegAddrBus] reData2Addr,
	
	output reg[`RegAddrBus] wrDataAddr,
	output reg wrn,
	//output reg[`RegDataBus] wrData,
	
	output reg[`RegDataBus] regData1_out,
	output reg[`RegDataBus] regData2_out,

	output reg[`ALUOpBus] alu_op,
	output reg[`ALUSelBus] alu_sel,

	// output to pc
	output reg branchEN,
	output reg[`RegDataBus] branchAddr,

	output reg next_delayslotEn,

	output reg[`InsDataBus] inst_o,
	
	output wire stall_req
);

	wire[5:0] op = inst[31:26];
	wire[4:0] rs = inst[25:21];
	wire[4:0] rt = inst[20:16];
	wire[4:0] rd = inst[15:11];
	wire[4:0] shamt = inst[10:6];
	wire[5:0] func = inst[5:0];
	wire[15:0] imm = inst[15:0];
	
	reg[31:0] ext_imm; // extend imm

	// varaibles for branch instructions
	wire[`RegDataBus] pc_plus_4;
	wire[`RegDataBus] imm_sll2_ext;
	assign pc_plus_4 = pc + 4;
	assign imm_sll2_ext = {{14{imm[15]}},imm,2'b00};


	// varaibles for judge load stall
	wire pre_inst_is_load;
	assign pre_inst_is_load = (last_alu_op == `ALU_OP_LW)?1'b1:1'b0;
	
	reg reg1_stall;
	reg reg2_stall;

	// control signal settings
	always@(*)
	begin
		if(rst == `ENABLE)
		begin
			alu_op <= `alu_op_nop;
			alu_sel <= `ALU_NOP;
			wrn <= `DISABLE;
			ren1 <= `DISABLE;
			ren2 <= `DISABLE;
			wrDataAddr <= 5'b00000;
			reData1Addr <= 5'b00000;
			reData2Addr <= 5'b00000;
			branchEN <= `DISABLE;
			branchAddr <= `ZeroWord;
			next_delayslotEn <= `DISABLE;
			inst_o <= `ZeroWord;
		end
		else
		begin
			// initial settings
			alu_op <= `alu_op_nop; // default: inst = nop
			alu_sel <= `ALU_NOP;
			wrn <= `DISABLE; // unable to write
			wrDataAddr <= rd;
			
			ren1 <= `DISABLE;
			ren2 <= `DISABLE;
			reData1Addr <= rs;
			reData2Addr <= rt;
			ext_imm <= `ZeroWord;
			
			branchEN <= `DISABLE;
			branchAddr <= `ZeroWord;
			next_delayslotEn <= `DISABLE;
			inst_o <= inst;
			if(delayslotEn == `DISABLE)
			begin
			case(op)
			// -------------------------------------------
			`SPECIAL: 
				begin
					case(func)
					`AND: // AND: reg[rd] = reg[rs] & reg[rt]
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData1Addr <= rs;
								reData2Addr <= rt;
								alu_op <= `ALU_OP_AND;
								alu_sel <= `ALU_SEL_LOGIC;
							end
						end
					`OR: //OR: reg[rd] = reg[rs] | reg[rt]
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData1Addr <= rs;
								reData2Addr <= rt;
								alu_op <= `ALU_OP_OR;
								alu_sel <= `ALU_SEL_LOGIC;
							end
						end
					`XOR: //XOR: reg[rd] = reg[rs] xor reg[rt]
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData1Addr <= rs;
								reData2Addr <= rt;
								alu_op <= `ALU_OP_XOR;
								alu_sel <= `ALU_SEL_LOGIC;
							end
						end
					`NOR: //NOR: reg[rd] = reg[rs] nor reg[rt]
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData1Addr <= rs;
								reData2Addr <= rt;
								alu_op <= `ALU_OP_NOR;
								alu_sel <= `ALU_SEL_LOGIC;
							end
						end
					`SLL:
						begin
							if(rs == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `DISABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData2Addr <= rt;
								ext_imm[4:0] <= shamt;
								alu_op <= `ALU_OP_SLL;
								alu_sel <= `ALU_SEL_SHIFT;
							end
						end
					`SRL:
						begin
							if(rs == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `DISABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData2Addr <= rt;
								ext_imm[4:0] <= shamt;
								alu_op <= `ALU_OP_SRL;
								alu_sel <= `ALU_SEL_SHIFT;
							end
						end
					`SRA:
						begin
							if(rs == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `DISABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData2Addr <= rt;
								ext_imm[4:0] <= shamt;
								alu_op <= `ALU_OP_SRA;
								alu_sel <= `ALU_SEL_SHIFT;
							end
						end
					`SLLV:
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData1Addr <= rs;
								reData2Addr <= rt;
								ext_imm[4:0] <= rs[4:0];
								alu_op <= `ALU_OP_SLL;
								alu_sel <= `ALU_SEL_SHIFT;
							end
						end
					`SRLV:
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData1Addr <= rs;
								reData2Addr <= rt;
								ext_imm[4:0] <= rs[4:0];
								alu_op <= `ALU_OP_SRL;
								alu_sel <= `ALU_SEL_SHIFT;
							end
						end
					`SRAV:
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `ENABLE;
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								wrDataAddr <= rd;
								reData1Addr <= rs;
								reData2Addr <= rt;
								ext_imm[4:0] <= rs[4:0];
								alu_op <= `ALU_OP_SRA;
								alu_sel <= `ALU_SEL_SHIFT;
							end
						end
					`SYNC:
						begin
							if(shamt == 5'b0)
							begin
								wrn <= `DISABLE;
								ren1 <= `DISABLE;
								ren2 <= `ENABLE;
								reData2Addr <= rt;
								alu_op <= `ALU_OP_NOP;
								alu_sel <= `ALU_SEL_NOP;
							end
						end
					`MOVZ:
						begin
							if(shamt == 5'b0)
							begin
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								reData1Addr <= rs;
								reData2Addr <= rt;
								alu_op <= `ALU_OP_MOVZ;
								alu_sel <= `ALU_SEL_MOVE;
								if(regData2_out == `ZeroWord)
									wrn <= `ENABLE;
								else
									wrn <= `DISABLE;
							end
						end
					`MOVN:
						begin
							if(shamt == 5'b0)
							begin
								ren1 <= `ENABLE;
								ren2 <= `ENABLE;
								reData1Addr <= rs;
								reData2Addr <= rt;
								alu_op <= `ALU_OP_MOVZ;
								alu_sel <= `ALU_SEL_MOVE;
								if(regData2_out != `ZeroWord)
									wrn <= `ENABLE;
								else
									wrn <= `DISABLE;
							end
						end
					`MFHI:
						begin
							ren1 <= `DISABLE;
							ren2 <= `DISABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_MFHI;
							alu_sel <= `ALU_SEL_MOVE;
						end
					`MFLO:
						begin
							ren1 <= `DISABLE;
							ren2 <= `DISABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_MFLO;
							alu_sel <= `ALU_SEL_MOVE;
						end
					`MTHI:
						begin
							ren1 <= `ENABLE;
							ren2 <= `DISABLE;
							wrn <= `DISABLE;
							alu_op <= `ALU_OP_MTHI;
						end
					`MTLO:
						begin
							ren1 <= `ENABLE;
							ren2 <= `DISABLE;
							wrn <= `DISABLE;
							alu_op <= `ALU_OP_MTLO;
						end
					// ARITHMETIC Insts
					`ADD:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_ADD;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`ADDU:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_ADDU;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`SUB:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_SUB;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`SUBU:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_SUBU;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`SLT:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_SLT;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`SLTU:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_SLTU;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`MULT:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `DISABLE;
							alu_op <= `ALU_OP_MULT;
						end
					`MULTU:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrn <= `DISABLE;
							alu_op <= `ALU_OP_MULTU;
						end
					`JR:
						begin
							ren1 <= `ENABLE;
							ren2 <= `DISABLE;
							wrn <= `DISABLE;
							branchEN <= `ENABLE;
							branchAddr <= regData1_out;
							next_delayslotEn <= `ENABLE;
							alu_op <= `ALU_OP_JR;
							alu_sel <= `ALU_SEL_BRANCH;
						end
					default:
						begin
						end
					endcase
				end
			// SPECIAL2
			`SPECIAL2:
				begin
					case(func)
					`CLZ:
						begin
							ren1 <= `ENABLE;
							ren2 <= `DISABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_CLZ;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`CLO:
						begin
							ren1 <= `ENABLE;
							ren2 <= `DISABLE;
							wrn <= `ENABLE;
							alu_op <= `ALU_OP_CLO;
							alu_sel <= `ALU_SEL_ARITH;
						end
					`MUL:
						begin
							ren1 <= `ENABLE;
							ren2 <= `ENABLE;
							wrDataAddr <= rd;
							wrn<= `ENABLE;
							alu_op <= `ALU_OP_MUL;
							alu_sel <= `ALU_SEL_MUL;
						end
					default:
						begin
						end
					endcase
				end
			
			`REGIMM:
				begin
					case(rt)
					`BLTZ:
						begin
							ren1 <= `ENABLE;
							ren2 <= `DISABLE;
							wrn<= `DISABLE;
							alu_op <= `ALU_OP_BLTZ;
							alu_sel <= `ALU_SEL_BRANCH;
							if(regData1_out[31] == 1'b1)
							begin
								branchEN <= `ENABLE;
								branchAddr <= pc_plus_4 + imm_sll2_ext;
								next_delayslotEn <= `ENABLE;
							end
						end
					
					`BGEZ:
						begin
							ren1 <= `ENABLE;
							ren2 <= `DISABLE;
							wrn<= `DISABLE;
							alu_op <= `ALU_OP_BGEZ;
							alu_sel <= `ALU_SEL_BRANCH;
							if(regData1_out[31] == 1'b0)
							begin
								branchEN <= `ENABLE;
								branchAddr <= pc_plus_4 + imm_sll2_ext;
								next_delayslotEn <= `ENABLE;
							end
						end

					endcase
				end

			// -------------------------------------------
			`ANDI: // ANDI: reg[rt] = reg[rs] & extend(imm)
				begin
				wrn <= `ENABLE;
				alu_op <= `ALU_OP_AND;
				alu_sel <= `ALU_LOGIC;
				ren1 <= `ENABLE;
				ren2 <= `DISABLE;
				ext_imm <= {16'b0, imm};
				wrDataAddr <= rt;
				end
			`ORI: // ORI: reg[rt] = reg[rs] | extend(imm)
				begin
				wrn <= `ENABLE;
				alu_op <= `alu_op_or;
				alu_sel <= `ALU_LOGIC;
				ren1 <= `ENABLE;
				ren2 <= `DISABLE;
				ext_imm <= {16'b0, imm};
				wrDataAddr <= rt;
				end
			`XORI: // XORI: reg[rt] = reg[rs] xor extend(imm)
				begin
				wrn <= `ENABLE;
				alu_op <= `ALU_OP_XOR;
				alu_sel <= `ALU_LOGIC;
				ren1 <= `ENABLE;
				ren2 <= `DISABLE;
				ext_imm <= {16'b0, imm};
				wrDataAddr <= rt;
				end
			`LUI:
				begin
				if(rs == 5'b0)
				begin
					wrn <= `ENABLE;
					alu_op <= `ALU_OP_OR;
					alu_sel <= `ALU_LOGIC;
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					ext_imm <= {imm,16'b0};
					wrDataAddr <= rt;
				end
				end
			`PREF:
				begin
					wrn <= `DISABLE;
					ren1 <= `DISABLE;
					ren2 <= `DISABLE;
					alu_op <= `ALU_OP_NOP;
					alu_sel <= `ALU_SEL_NOP;
				end
			`ADDI:
				begin
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					wrn <= `ENABLE;
					wrDataAddr <= rt;
					ext_imm <= {{16{imm[15]}}, imm[15:0]};
					alu_op <= `ALU_OP_ADDI;
					alu_sel <= `ALU_SEL_ARITH;
				end
			`ADDIU:
				begin
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					wrn <= `ENABLE;
					wrDataAddr <= rt;
					ext_imm <= {{16{imm[15]}}, imm[15:0]};
					alu_op <= `ALU_OP_ADDIU;
					alu_sel <= `ALU_SEL_ARITH;
				end
			`SLTI:
				begin
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					wrn <= `ENABLE;
					wrDataAddr <= rt;
					ext_imm <= {{16{imm[15]}}, imm[15:0]};
					alu_op <= `ALU_OP_SLT;
					alu_sel <= `ALU_SEL_ARITH;
				end
			`SLTIU:
				begin
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					wrn <= `ENABLE;
					wrDataAddr <= rt;
					ext_imm <= {{16{imm[15]}}, imm[15:0]};
					alu_op <= `ALU_OP_SLTU;
					alu_sel <= `ALU_SEL_ARITH;
				end
			`J:
				begin
					ren1 <= `DISABLE;
					ren2 <= `DISABLE;
					wrn <= `DISABLE;
					branchEN <= `ENABLE;
					branchAddr <= {pc_plus_4[31:28],imm,2'b00};
					next_delayslotEn <= `ENABLE;
					alu_op <= `ALU_OP_J;
					alu_sel <= `ALU_SEL_BRANCH;
				end
			`BEQ:
				begin
					ren1 <= `ENABLE;
					ren2 <= `ENABLE;
					wrn <= `DISABLE;
					alu_op <= `ALU_OP_BEQ;
					alu_sel <= `ALU_SEL_BRANCH;
					if(regData1_out == regData2_out)
					begin
						branchEN <= `ENABLE;
						branchAddr <= pc_plus_4 + imm_sll2_ext;
						next_delayslotEn <= `ENABLE;
					end
				end
			`BGTZ:
				begin
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					wrn <= `DISABLE;
					alu_op <= `ALU_OP_BGTZ;
					alu_sel <= `ALU_SEL_BRANCH;
					if(regData1_out[31] == 1'b0 && regData1_out != `ZeroWord)
					begin
						branchEN <= `ENABLE;
						branchAddr <= pc_plus_4 + imm_sll2_ext;
						next_delayslotEn <= `ENABLE;
					end
				end
			`BLEZ:
				begin
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					wrn <= `DISABLE;
					alu_op <= `ALU_OP_BLEZ;
					alu_sel <= `ALU_SEL_BRANCH;
					if(regData1_out[31] == 1'b1 || regData1_out != `ZeroWord)
					begin
						branchEN <= `ENABLE;
						branchAddr <= pc_plus_4 + imm_sll2_ext;
						next_delayslotEn <= `ENABLE;
					end
				end
			`BNE:
				begin
					ren1 <= `ENABLE;
					ren2 <= `ENABLE;
					wrn <= `DISABLE;
					alu_op <= `ALU_OP_BNE;
					alu_sel <= `ALU_SEL_BRANCH;
					if(regData1_out != regData2_out)
					begin
						branchEN <= `ENABLE;
						branchAddr <= pc_plus_4 + imm_sll2_ext;
						next_delayslotEn <= `ENABLE;
					end
				end
			`LW:
				begin
					ren1 <= `ENABLE;
					ren2 <= `DISABLE;
					wrn <= `ENABLE;
					wrDataAddr <= rt;
					alu_op <= `ALU_OP_LW;
					alu_sel <= `ALU_SEL_LOADSTORE;
				end
			`SW:
				begin
					ren1 <= `ENABLE;
					ren2 <= `ENABLE;
					wrn <= `DISABLE;
					alu_op <= `ALU_OP_SW;
					alu_sel <= `ALU_SEL_LOADSTORE;
				end
			// -------------------------------------------
			default: begin
					 end
			endcase
			// -------------------------------------------
			end
		end
	end
	

	// decide the first Reg out
	always@(*)
	begin
		reg1_stall <= `DISABLE;
		if(rst == `ENABLE)
			regData1_out <= `ZeroWord;
		else if(ren1 == `ENABLE)
		begin
			if(pre_inst_is_load == `ENABLE && ex_wrAddr == reData1Addr)
				reg1_stall <= `ENABLE;
			else if(ex_wrn == `ENABLE && ex_wrAddr == reData1Addr)
				regData1_out <= ex_wrData;
			else if(mem_wrn == `ENABLE && mem_wrAddr == reData1Addr)
				regData1_out <= mem_wrData;
			else
				regData1_out <= reData1_in;
		end
		else if(ren1 == `DISABLE)
			regData1_out <= ext_imm;
		else
			regData1_out <= `ZeroWord;
	end

	//decide the second reg out
	always@(*)
	begin
		reg2_stall <= `DISABLE;
		if(rst == `ENABLE)
			regData2_out <= `ZeroWord;
		else if(ren2 == `ENABLE)
		begin
			if(pre_inst_is_load == `ENABLE && ex_wrAddr == reData2Addr)
				reg2_stall <= `ENABLE;
			else if(ex_wrn == `ENABLE && ex_wrAddr == reData2Addr)
				regData2_out <= ex_wrData;
			else if(mem_wrn == `ENABLE && mem_wrAddr == reData2Addr)
				regData2_out <= mem_wrData;
			else
				regData2_out <= reData2_in;
		end
		else if(ren2 == `DISABLE)
			regData2_out <= ext_imm;
		else
			regData2_out <= `ZeroWord;	
	end


	assign stall_req = reg1_stall | reg2_stall;

endmodule
