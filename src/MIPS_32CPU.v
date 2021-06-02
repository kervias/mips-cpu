
// top file
`include "defines.v"

module MIPS_32CPU
(
	//input
	input wire clk,
	input wire rst,
	input wire[`InsDataBus] inst,	


	// from data memory
	input wire[`RegDataBus] datamem_mem_redata,
			
	//output to instROM
	output wire[`InsAddrBus] insAddr_o,
	output wire insEn,

	// output to data memory
	output wire mem_datamem_wrn,
    output wire mem_datamem_ce,
    output wire[`RegDataBus] mem_datamem_addr,
    output wire[`RegDataBus] mem_datamem_wrdata

);

// -------- varaiables defines ---------
// The variables to connect IF_ID module and ID module
	wire[`InsAddrBus] pc;
	wire[`InsAddrBus] pipe_id_pc;
	wire[`InsDataBus] pipe_id_inst;

// ID + ID_EX
	wire[`RegDataBus] id_pipe_reData1;
	wire[`RegDataBus] id_pipe_reData2;
	wire id_pipe_wrn;
	wire[`RegAddrBus] id_pipe_wrAddr;
	wire[`ALUOpBus] id_pipe_aluOp;
	wire[`ALUSelBus] id_pipe_aluSel;

	wire id_pipe_next_delayslotEn;

	wire[`RegDataBus] id_pipe_inst;

// ID + RegFiles
	wire id_regfile_ren1;
	wire id_regfile_ren2;
	wire[`RegAddrBus] id_regfile_reData1Addr;
	wire[`RegAddrBus] id_regfile_reData2Addr;
	wire[`RegDataBus] regfile_id_reData1;
	wire[`RegDataBus] regfile_id_reData2;

// ID_EX + EX
	wire[`RegDataBus] pipe_ex_reData1;
	wire[`RegDataBus] pipe_ex_reData2;
	wire pipe_ex_wrn;
	wire[`RegAddrBus] pipe_ex_wrAddr;
	wire[`ALUOpBus] pipe_ex_aluOp;
	wire[`ALUSelBus] pipe_ex_aluSel;

	wire[`RegDataBus] pipe_ex_inst;

// EX + EX_MEM
	wire ex_pipe_wrn;
	wire[`RegAddrBus] ex_pipe_wrAddr;
	wire[`RegDataBus] ex_pipe_result;
	
	wire ex_pipe_wrn_HILO;
	wire[`RegDataBus] ex_pipe_wrData_HI;
	wire[`RegDataBus] ex_pipe_wrData_LO;

	wire[`ALUOpBus] ex_pipe_alu_op;
	wire[`RegDataBus] ex_pipe_mem_addr;
	wire[`RegDataBus] ex_pipe_mem_data;

// EX_MEM + MEM
	wire pipe_mem_wrn;
	wire[`RegAddrBus] pipe_mem_wrAddr;
	wire[`RegDataBus] pipe_mem_wrData;
	
	wire pipe_mem_wrn_HILO;
	wire[`RegDataBus] pipe_mem_wrData_HI;
	wire[`RegDataBus] pipe_mem_wrData_LO;

	wire[`ALUOpBus] pipe_mem_alu_op;
	wire[`RegDataBus] pipe_mem_mem_addr;
	wire[`RegDataBus] pipe_mem_mem_data;

// MEM + MEM_WB
	wire mem_pipe_wrn;
	wire[`RegAddrBus] mem_pipe_wrAddr;
	wire[`RegDataBus] mem_pipe_wrData;
	
	wire mem_pipe_wrn_HILO;
	wire[`RegDataBus] mem_pipe_wrData_HI;
	wire[`RegDataBus] mem_pipe_wrData_LO;

// MEM_WB + REGFILES
	wire pipe_wb_regfile_wrn;
	wire[`RegAddrBus] pipe_wb_regfile_wrAddr;
	wire[`RegDataBus] pipe_wb_regfile_wrData;

// MEM_WB + HILO
	wire pipe_HILO_wrn;
	wire[`RegDataBus] pipe_HILO_HI;
	wire[`RegDataBus] pipe_HILO_LO;

// HILO + EX
	wire[`RegDataBus] HILO_EX_HI;
	wire[`RegDataBus] HILO_EX_LO;
	
// IDEX + ID
	wire IDEX_ID_delayslotEN;

// ID + PC
	wire id_pc_branchEN;
	wire[`RegDataBus] id_pc_branchAddr;

// MEM + DATAMEM
   //wire mem_datamem_wrn;
   //wire mem_datamem_ce;
   //wire[`RegDataBus] mem_datamem_addr;
   //wire[`RegDataBus] mem_datamem_wrdata;

// DATAMEM + MEM
	//wire[`RegDataBus] datamem_mem_redata;

// stallreq
	wire id_ctrl_stall_req;


// ctrl + stall
	wire[5:0] ctrl_stall;

// ------------------------------------------------------------

// PC 
	pc pc_0
	(
		// input
		.clk(clk), .rst(rst), .stall(ctrl_stall),
		.branchEN(id_pc_branchEN), .branchAddr(id_pc_branchAddr),
		// output
		.pc(pc), .insEn(insEn)
	);	

assign insAddr_o = pc;
// IF_ID
	IF_ID IF_ID_0
	(
		// input
		.clk(clk), .rst(rst), .stall(ctrl_stall),
		.if_pc(pc), .if_ins(inst),
		// output
		.id_pc(pipe_id_pc), .id_ins(pipe_id_inst)
	);

// ID
	ID ID_0
	(
		// input 
		.rst(rst),
		.inst(pipe_id_inst), .pc(pipe_id_pc),
		.reData1_in(regfile_id_reData1), .reData2_in(regfile_id_reData2), // from regfiles

		.ex_wrn(ex_pipe_wrn), .ex_wrAddr(ex_pipe_wrAddr), .ex_wrData(ex_pipe_result),
		.mem_wrn(mem_pipe_wrn), .mem_wrAddr(mem_pipe_wrAddr), .mem_wrData(mem_pipe_wrData),
		
		.delayslotEn(ID_EX_delayslotEN),

		.last_alu_op(pipe_ex_aluOp),

		// output to pipe
		.regData1_out(id_pipe_reData1), .regData2_out(id_pipe_reData2), 
		.wrn(id_pipe_wrn), .wrDataAddr(id_pipe_wrAddr),
		.alu_op(id_pipe_aluOp), .alu_sel(id_pipe_aluSel),
		
		//output to regfiles
		.ren1(id_regfile_ren1), .ren2(id_regfile_ren2),
		.reData1Addr(id_regfile_reData1Addr), .reData2Addr(id_regfile_reData2Addr),

		.next_delayslotEn(id_pipe_next_delayslotEn),
		
		.branchEN(id_pc_branchEN), 
		.branchAddr(id_pc_branchAddr),
		
		.inst_o(id_pipe_inst),
		.stall_req(id_ctrl_stall_req)
	);

// ID_EX
	ID_EX ID_EX_0
	(
		// input
		.clk(clk), .rst(rst), .id_inst(id_pipe_inst), .stall(ctrl_stall),
		.id_reg1Data(id_pipe_reData1), .id_reg2Data(id_pipe_reData2),
		.id_wrn(id_pipe_wrn), .id_wrAddr(id_pipe_wrAddr),
		.id_alu_op(id_pipe_aluOp), .id_alu_sel(id_pipe_aluSel),

		.id_next_delayslotEn(id_pipe_next_delayslotEn),
		// output
		.ex_reg1Data(pipe_ex_reData1), .ex_reg2Data(pipe_ex_reData2),
		.ex_wrn(pipe_ex_wrn), .ex_wrAddr(pipe_ex_wrAddr),
		.ex_alu_op(pipe_ex_aluOp), .ex_alu_sel(pipe_ex_aluSel),

		.ex_next_delayslotEn(ID_EX_delayslotEN),
		.ex_inst(pipe_ex_inst)
	);

// EX
	EX EX_0
	(
		// input
		.rst(rst), .inst(pipe_ex_inst),
		.reg1Data(pipe_ex_reData1), .reg2Data(pipe_ex_reData2),
		.wrn_i(pipe_ex_wrn), .wrAddr_i(pipe_ex_wrAddr),
		.alu_op(pipe_ex_aluOp), .alu_sel(pipe_ex_aluSel),
		
			// HILO
		.mem_wrn_HILO_i(mem_pipe_wrn_HILO), .mem_wrData_HI_i(mem_pipe_wrData_HI), .mem_wrData_LO_i(mem_pipe_wrData_LO),
		.wb_wrn_HILO_i(pipe_HILO_wrn), .wb_wrData_HI_i(pipe_HILO_HI), .wb_wrData_LO_i(pipe_HILO_LO),
		.regData_HI(HILO_EX_HI), .regData_LO(HILO_EX_LO),
		
		// output
		.wrn_o(ex_pipe_wrn), .wrAddr_o(ex_pipe_wrAddr),
		.result(ex_pipe_result),

			//HILO
		.wrn_HILO_o(ex_pipe_wrn_HILO), .wrData_HI_o(ex_pipe_wrData_HI), .wrData_LO_o(ex_pipe_wrData_LO),

		// output about mem
		.alu_op_o(ex_pipe_alu_op), .mem_addr_o(ex_pipe_mem_addr), .mem_data_o(ex_pipe_mem_data)
	);

// EX_MEM
	EX_MEM EX_MEM_0
	(
		// input
		.clk(clk), .rst(rst),.stall(ctrl_stall),
		.wrn_i(ex_pipe_wrn), .wrAddr_i(ex_pipe_wrAddr),
		.result_i(ex_pipe_result),

			// HILO
		.wrn_HILO_i(ex_pipe_wrn_HILO), .wrData_HI_i(ex_pipe_wrData_HI), .wrData_LO_i(ex_pipe_wrData_LO),

		.alu_op_i(ex_pipe_alu_op), .mem_addr_i(ex_pipe_mem_addr), .mem_data_i(ex_pipe_mem_data),
		
		//output
		.wrn_o(pipe_mem_wrn), .wrAddr_o(pipe_mem_wrAddr),
		.result_o(pipe_mem_wrData),

			//HILO
		.wrn_HILO_o(pipe_mem_wrn_HILO), .wrData_HI_o(pipe_mem_wrData_HI), .wrData_LO_o(pipe_mem_wrData_LO),

		.alu_op_o(pipe_mem_alu_op), .mem_addr_o(pipe_mem_mem_addr), .mem_data_o(pipe_mem_mem_data)
	);

// MEM
	MEM MEM_0
	(
		// input
		.rst(rst),
		.wrn_i(pipe_mem_wrn), .wrAddr_i(pipe_mem_wrAddr), .result_i(pipe_mem_wrData),
		
			// HILO
		.wrn_HILO_i(pipe_mem_wrn_HILO), .wrData_HI_i(pipe_mem_wrData_HI), .wrData_LO_i(pipe_mem_wrData_LO),

		// about memory
		.alu_op_i(pipe_mem_alu_op), .mem_addr_i(pipe_mem_mem_addr), .mem_wrdata_i(pipe_mem_mem_data),

		// from memory
		.mem_redata_i(datamem_mem_redata),

		//output
		.wrn_o(mem_pipe_wrn), .wrAddr_o(mem_pipe_wrAddr), .result_o(mem_pipe_wrData),
			//HILO
		.wrn_HILO_o(mem_pipe_wrn_HILO), .wrData_HI_o(mem_pipe_wrData_HI), .wrData_LO_o(mem_pipe_wrData_LO),

		// into memory
		.mem_wrn(mem_datamem_wrn), .mem_ce(mem_datamem_ce), .mem_wrdata(mem_datamem_wrdata), .mem_wraddr(mem_datamem_addr)
	);
	
// MEM_WB
	MEM_WB MEM_WB_0
	(
		// input
		.clk(clk), .rst(rst),.stall(ctrl_stall),
		.wrn_i(mem_pipe_wrn), .wrAddr_i(mem_pipe_wrAddr), .wrData_i(mem_pipe_wrData),

			//HILO
		.wrn_HILO_i(mem_pipe_wrn_HILO), .wrData_HI_i(mem_pipe_wrData_HI), .wrData_LO_i(mem_pipe_wrData_LO),

		// output
		.wrn_o(pipe_wb_regfile_wrn), .wrAddr_o(pipe_wb_regfile_wrAddr), .wrData_o(pipe_wb_regfile_wrData),
			//HILO
		.wrn_HILO_o(pipe_HILO_wrn), .wrData_HI_o(pipe_HILO_HI), .wrData_LO_o(pipe_HILO_LO)
	);

// RegFiles
	RegFiles RegFiles_0
	(
		// input
		.clk(clk), .rst(rst),
		.ren1(id_regfile_ren1), .ren2(id_regfile_ren2),
		.reData1Addr(id_regfile_reData1Addr), .reData2Addr(id_regfile_reData2Addr),
		
		.wrn(pipe_wb_regfile_wrn), .wrDataAddr(pipe_wb_regfile_wrAddr), .wrData(pipe_wb_regfile_wrData),
		//output
		.reData1(regfile_id_reData1), .reData2(regfile_id_reData2)
	);

// HILO
	HILO HILO_0
	(
		// input
		.clk(clk), .rst(rst),
		.wrn_HILO_i(pipe_HILO_wrn), .wrData_HI_i(pipe_HILO_HI), .wrData_LO_i(pipe_HILO_LO),

		// ouptut
		.HIData_o(HILO_EX_HI), .LOData_o(HILO_EX_LO)
	);

// CTRL
	ctrl CTRL
	(
		.rst(rst),
		.id_stall(id_ctrl_stall_req),
		//.ex_stall(),
		.stall(ctrl_stall)
	);


endmodule
