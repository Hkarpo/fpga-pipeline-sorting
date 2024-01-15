
module DataMemory(reset, clk, Address, Write_data, Read_data, MemRead, MemWrite, leds, irq, digi);
	input reset, clk;
	input [31:0] Address, Write_data;
	input MemRead, MemWrite;
	output irq;
	output [31:0] Read_data;
	output [7:0] leds;
	output [11:0] digi;
	wire [31:0] mem_rddata1, mem_rddata2;
	
	parameter RAM_SIZE = 512;
	parameter RAM_SIZE_BIT = 8;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	assign mem_rddata1 = (MemRead && !Address[30])? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	integer i;
	always @(posedge reset or posedge clk)
		if (reset)
			for (i = 0; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
		else if (MemWrite && !Address[30])
			RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
    
    peripheral per(.reset(reset), .clk(clk), .rd(MemRead), .wr(MemWrite), .addr(Address), .rdata(mem_rddata2), .led(leds), .irq(irq), .wdata(Write_data), .digi(digi));
    
    assign Read_data = (Address[30:28] == 3'd4)? mem_rddata2: mem_rddata1;
    
endmodule
