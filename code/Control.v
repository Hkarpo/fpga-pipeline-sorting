module Control(OpCode, Funct, irq, PCSrc, RegWrite, RegDst, MemRead, MemWrite, MemtoReg, ALUSrc1, ALUSrc2, ExtOp, LuOp, Sign, ALUfun);
	input [5:0] OpCode;
	input [5:0] Funct;
	input wire irq;
	output [2:0] PCSrc;
//	output Branch; //应没有
	output RegWrite;
	output [1:0] RegDst;
	output MemRead;
	output MemWrite;
	output [1:0] MemtoReg;
	output ALUSrc1;
	output ALUSrc2;
	output ExtOp;
	output LuOp;
	output Sign;
	output [5:0] ALUfun;
	
	// Your code below
	assign PCSrc[2:0] =
	    ((OpCode ==6'h00 && (Funct != 6'h08 && Funct != 6'h09)) || OpCode == 6'h08 || OpCode == 6'h09 || OpCode == 6'h0a || OpCode == 6'h0b 
	       || OpCode == 6'h0c || OpCode == 6'h0f || OpCode ==6'h23 || OpCode == 6'h2b)? 3'd0:
	    (OpCode == 6'h01 || OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07)?3'd1:
	    (OpCode == 6'h02 || OpCode ==6'h03)? 3'd2:
	    (OpCode == 6'h0 && (Funct == 6'h08 || Funct == 6'h09))? 3'd3:
	    irq? 3'd4:
	    3'd5;
       
    assign RegWrite =
        (OpCode == 6'h2b || OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01 || OpCode == 6'h02 || (OpCode == 6'h0 && Funct == 6'h08))? 1'b0:
        1'b1;
    
    assign RegDst[1:0] =
        irq? 2'd3:
        (OpCode == 6'h0)? 2'd0:
        (OpCode == 6'h02 || OpCode == 6'h03)? 2'd2:
        (OpCode == 6'h23 || OpCode == 6'h2b || OpCode == 6'h0f || OpCode == 6'h08 || OpCode == 6'h09 || OpCode == 6'h0c || OpCode == 6'h0a || OpCode == 6'h0b 
            || OpCode == 6'h04 || OpCode == 6'h01 || OpCode == 6'h06 || OpCode == 6'h07)? 2'd1: //改
        2'd3;
    
    assign MemRead =
        (OpCode == 6'h23)? 1'b1: 1'b0;
    
    assign MemWrite =
        (OpCode == 6'h2b)? 1'b1: 1'b0;
        
    assign MemtoReg =
        (OpCode == 6'h23)? 2'd1:
        (OpCode == 6'h03 || (OpCode ==6'h00 && Funct == 6'h09) || irq)? 2'd2:
        2'd0;
    
    assign ALUSrc1 =
        (OpCode == 6'h00 && (Funct == 6'h00 || Funct == 6'h02 || Funct == 6'h03))? 1'b1: 1'b0;
    
    assign ALUSrc2 =
        (OpCode == 6'h00 || OpCode == 6'h01 || OpCode == 6'h02 || OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07)? 0:1; //OpCode == 6'h03 ||  no jal
    
    assign ExtOp =
        (OpCode == 6'h0c || OpCode == 6'h0d)? 1'b0: 1'b1; //加入ori
    
    assign LuOp =
        (OpCode == 6'h0f)? 1'b1: 1'b0;
        
    assign Sign =
        ((OpCode == 6'h00 && (Funct == 6'h21 || Funct == 6'h23)) || OpCode ==6'h09 || OpCode == 6'h0b)? 1'b0: 1'b1; //OpCode == 6'h08 ||  no addi

    assign ALUfun =
        (OpCode==6'h23 || OpCode==6'h2b || OpCode==6'h0f || OpCode==6'h08 || OpCode==6'h09 || (OpCode==6'h00 && (Funct==6'h20 || Funct==6'h21)))?6'b000000:
        (OpCode==6'h00 && (Funct==6'h22 || Funct==6'h23))?6'b000001:
        ((OpCode==6'h00 && Funct==6'h24)|| OpCode==6'h0c)?6'b011000:
        ((OpCode==6'h00 && Funct==6'h25) || OpCode==6'h0d)?6'b011110: //加入ori
        (OpCode==6'h00 && Funct==6'h26)?6'b010110:
        (OpCode==6'h00 && Funct==6'h27)?6'b010001:
        (OpCode==6'h00 && Funct==6'h00)?6'b100000:
        (OpCode==6'h00 && Funct==6'h02)?6'b100001:
        (OpCode==6'h00 && Funct==6'h03)?6'b100011:
        ((OpCode==6'h00 && Funct==6'h2a) || OpCode==6'h0a || OpCode==6'h0b ||OpCode==6'h01)?6'b110101://set less than = (A-B)<0
        (OpCode==6'h04)?6'b110011:
        (OpCode==6'h05)?6'b110001:
        (OpCode==6'h06)?6'b111101:
        (OpCode==6'h07)?6'b111111:
        6'b110101;
	
endmodule