/*
	Annoations:
	------------
		+ RegFiles
		 	- 32 32bit Registers
	INPUT:
	------
		- clk[1]: colock signal
		- rst[1]: reset signal

		- wrn[1]: wrtite enable signal
		- wrDataAddr[32]: the address of the data which will be written
		- wrData[32]: the data that will be write back into the regfile

		- ren1[1]: read enable signal1 
		- reData1Addr[32]: the address of the first data
		- ren2[1]: read enable signal2
		- reData2Addr[32]: the address of the second data
	
	OUTPUT:
	------
		- reData1[32]: the first data that will be read out 
		- reData2[32]: the second data that will be read out 
*/

`include "defines.v"

module RegFiles(
	// INPUT
	input wire rst,
	input wire clk,

	input wire wrn,
	input wire[`RegAddrBus] wrDataAddr,
	input wire[`RegDataBus] wrData,

	input wire ren1,
	input wire[`RegAddrBus] reData1Addr,
	
	input wire ren2,
	input wire[`RegAddrBus] reData2Addr,

	// OUTPUT
	output reg[`RegDataBus] reData1,
	output reg[`RegDataBus] reData2
);


	// define all registers
	reg[`RegDataBus] regFiles[0:`RegFilesNum-1];
	
	integer i;
	// init all registers to be zero
	initial
	begin
		for(i = 0; i < `RegFilesNum; i = i + 1)
			regFiles[i] = `ZeroWord;
	end
	
	
	// write operation
	always@(posedge clk)
	begin
		if(rst == `RstDisable && wrn == `WriteEnable && wrDataAddr !=  `RegFilesNumLog2'b0)
		begin
			regFiles[wrDataAddr] <= wrData;
		end	
	end


	// read operation1
	always@(*)
	begin
		if(rst == `ENABLE)
			reData1 <= `ZeroWord;
		else if(wrn == `ENABLE && wrDataAddr == reData1Addr && ren1 == `ENABLE)
			reData1 <= wrData;
		else if(ren1 == `ENABLE)
			reData1 <= regFiles[reData1Addr];
		else
			reData1 <= `ZeroWord;
	end
	
	// read operation2
	always@(*)
	begin
		if(rst == `ENABLE)
			reData2 <= `ZeroWord;
		else if(wrn == `ENABLE && wrDataAddr == reData2Addr && ren2 == `ENABLE)
			reData2 <= wrData;
		else if(ren2 == `ENABLE)
			reData2 <= regFiles[reData2Addr];
		else
			reData2 <= `ZeroWord;
	end
endmodule
