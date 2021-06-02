
`include "defines.v"

module min_sopc(
	// input
	input wire clk,
	input wire rst
);

	wire insEn;
	wire[`InsDataBus] inst;
	wire[`InsAddrBus] instAddr;
	
	wire[`RegDataBus] datamem_mem_redata;
	wire mem_datamem_wrn;
    wire mem_datamem_ce;
    wire[`RegDataBus] mem_datamem_addr;
    wire[`RegDataBus] mem_datamem_wrdata;

	//OpenMips OpenMips_0
	MIPS_32CPU MIPS32
	(
		// input
		.clk(clk),
		.rst(rst),
		.inst(inst),
		
		// output
		.insAddr_o(instAddr),
		.insEn(insEn),
		.datamem_mem_redata(datamem_mem_redata),
	    .mem_datamem_wrn(mem_datamem_wrn),
        .mem_datamem_ce(mem_datamem_ce),
        .mem_datamem_addr(mem_datamem_addr),
        .mem_datamem_wrdata(mem_datamem_wrdata)
	);

	insMem insMem_0
	(
		//input
		.insAddr(instAddr),
		.insEn(insEn),
		
		// output
		.inst(inst)
	);

	// dataMemory
	dataMem DATAMEM
	(
		.clk(clk),.ce(mem_datamem_ce), .wrn(mem_datamem_wrn),
		.mem_addr(mem_datamem_addr), .mem_data_i(mem_datamem_wrdata),
		.mem_data_o(datamem_mem_redata)
	);


endmodule
