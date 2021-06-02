`include "defines.v"

module dataMem(
	input wire clk,
	input wire ce,
	input wire wrn, // write en
	
	input wire[`DMAddrBus] mem_addr,
	input wire[`DMDataBus] mem_data_i,

	// output
	output reg[`DMDataBus] mem_data_o
);

	reg[`ByteWidth] DataMEM[0:`DMUnitNum];

	integer i;
	initial
	begin
		for(i = 0; i < `DMUnitNum; i=i+1)
		begin
			DataMEM[i] = 8'b0;
		end
	end
	
	always@(clk)
	begin
		if(ce == `ENABLE)
		begin
			if(wrn == `ENABLE)
			begin
				//DataMEM[mem_addr] <= mem_data_i[31:24];
				//DataMEM[mem_addr+1] <= mem_data_i[23:16];
				//DataMEM[mem_addr+2] <= mem_data_i[15:8];
				//DataMEM[mem_addr+3] <= mem_data_i[7:0];
				
				{DataMEM[mem_addr],DataMEM[mem_addr+1],DataMEM[mem_addr+2],DataMEM[mem_addr+3]} <= mem_data_i;
			end
		end
	end
	
	always@(*)
	begin
		if(ce == `DISABLE)
		begin
			mem_data_o <= `ZeroWord;
		end
		else
		begin
			mem_data_o <= {DataMEM[mem_addr],DataMEM[mem_addr+1],DataMEM[mem_addr+2],DataMEM[mem_addr+3]};
		end
	end


endmodule
