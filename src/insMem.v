/*
	Annoations:
	---------
		+ instructions Memory
		+ ROM
	
	INPUT:
	---------
		- insEn: [instruction Enable signal] -> insEn = insDisable , inst = nop(0)
		- insAddr: [the address of instruction
	
	OUTPUT:
	---------
		+ inst: [instruction]
*/

`include "defines.v"

module insMem(insEn, insAddr, inst);
	// ----- input ------
	input wire insEn;
	input wire[`InsAddrWidth] insAddr;
	
	// ----- output -----
	output reg[`InsWidth] inst;
	
	// instruction memory init
	reg[`InsWidth] instM[0:`InsMemUnitNum];
	initial
	begin
		$readmemh("instructions.data",instM);
	end

	
	always@(*)
	begin
		if(insEn == `InsDisable) begin
			inst <= `ZeroWord;
		end
		else begin
			inst <= instM[insAddr[`InsMemUnitNumLog2+1:2]];
		end
	end
	
endmodule
