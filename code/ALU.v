
module ALU(in1, in2, ALUFun, Opcode, Sign, out);
//zero);
	input [31:0] in1, in2;
	input [5:0] ALUFun;
	input [5:0] Opcode;
	input Sign;
	output reg [31:0] out;
//	output zero;
//	assign zero = (out == 0);
	
	wire ss;
	assign ss = {in1[31], in2[31]};
	
	wire lt_31;
	assign lt_31 = (in1[30:0] < in2[30:0]);
	
	wire lt_signed;
	assign lt_signed = (in1[31] ^ in2[31])? 
		((ss == 2'b01)? 0: 1): lt_31;
	
	always @(*)
	begin
	    case (Opcode)
	       6'h0f: out <= in1; //lui
	       6'h08: out <= in1 + in2; //addi
	       6'h09: out <= in1 + in2; //addiu
	       6'h0c: out <= in1 & in2; //andi
	       6'h0d: out <= in1 | in2; //ori
	       6'h0a: out <= {31'h00000000, Sign? lt_signed: (in1 < in2)}; //slti
	       6'h0b: out <= {31'h00000000, (in1 < in2)? 1:0}; //sltiu
        endcase
        
        case (ALUFun)
			6'b100000: out <= (in2 << in1[4:0]); //sll
			6'b100001: out <= (in2 >> in1[4:0]); //srl
			6'b100011: out <= ({{32{in2[31]}}, in2} >> in1[4:0]); //sra
			6'b000000: out <= in1 + in2; //add
			6'b000001: out <= in1 - in2; //sub
			6'b011000: out <= in1 & in2; //and
			6'b011110: out <= in1 | in2; //or
			6'b010001: out <= ~(in1 | in2); //nor
			6'b010110: out <= in1 ^ in2; //xor
			6'b011010: out <= in1; //A
			6'b110011: out <= (in1 == in2) ? 1: 0; //beq
			6'b110001: out <= (in1 != in2) ? 1: 0; //bneq;
			6'b110101: out <= {31'h00000000, Sign? lt_signed: (in1 < in2)}; //slt
			6'b111101: out <= {31'h00000000, Sign? lt_signed: (in1 < 0 || in1 ==0)}; //blez
			6'b111011: out <= {31'h00000000, Sign? lt_signed: (in1 < 0)}; //bltz
			6'b111111: out <= {31'h00000000, Sign? lt_signed: (in1 > 0)}; //bgtz
			default: out <= 32'h00000000;
		endcase
    end
endmodule