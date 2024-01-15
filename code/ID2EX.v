`timescale 1ns / 1ps

module ID2EX(
    reset, clk, flush,
    in_pcsrc, in_regdst, in_regwr, in_alusrc1, in_alusrc2, in_alufun, in_sign, in_memwr, in_memrd, in_memtoreg, in_imm, in_pc, in_databusA, in_databusB, in_inst, in_conba,
    out_pcsrc, out_regdst, out_regwr, out_alusrc1, out_alusrc2,  out_alufun, out_sign, out_memwr, out_memrd, out_memtoreg, out_imm, out_pc, out_databusA, out_databusB, out_inst, out_conba
    );
    input reset, clk, flush;
    input [2:0] in_pcsrc;
    input [1:0] in_regdst;
    input in_regwr;
    input in_alusrc1, in_alusrc2;
    input [5:0] in_alufun;
    input in_sign;
    input in_memwr;
    input in_memrd;
    input [1:0] in_memtoreg;
    input [31:0] in_imm;
    input [31:0] in_inst; //contain shamt[4:0] as inst[10:6] and regwr addr rd[4:0] as inst[15:11]
    input [31:0] in_databusA;
    input [31:0] in_databusB;
    input [31:0] in_pc;
    input [31:0] in_conba;
    
    output reg [2:0] out_pcsrc;
    output reg [1:0] out_regdst;
    output reg out_regwr;
    output reg out_alusrc1;
    output reg out_alusrc2;
    output reg [5:0] out_alufun;
    output reg out_sign;
    output reg out_memwr;
    output reg out_memrd;
    output reg [1:0] out_memtoreg;
    output reg [31:0] out_imm;
    output reg [31:0] out_inst;
    output reg [31:0] out_databusA;
    output reg [31:0] out_databusB;
    output reg [31:0] out_pc;
    output reg [31:0] out_conba;
    
    always @(posedge clk or negedge reset)
    begin
        if(~reset)
        begin
            out_pcsrc <= 0;
            out_regdst <= 0;
            out_regwr <= 0;
            out_alusrc1 <= 0;
            out_alusrc2 <= 0;
            out_alufun <= 0;
            out_sign <= 0;
            out_memwr <= 0;
            out_memrd <= 0;
            out_memtoreg <= 0;
            out_imm <= 0;
            out_inst <= 0;
            out_databusA <= 0;
            out_databusB <= 0;
            out_pc <= 32'h80000000;
            out_conba <= 0;
        end
        else if(flush)
        begin
            out_pcsrc <= 0;
            out_regdst <= 0;
            out_regwr <= 0;
            out_alusrc1 <= 0;
            out_alusrc2 <= 0;
            out_alufun <= 0;
            out_sign <= 0;
            out_memwr <= 0;
            out_memrd <= 0;
            out_memtoreg <= 0;
            out_imm <= 0;
            out_inst <= 0;
            out_databusA <= 0;
            out_databusB <= 0;
            out_pc <= in_pc; //¸Ä
            out_conba <= 0;
        end
        else
        begin
            out_pcsrc <=  in_pcsrc;
            out_regdst <= in_regdst;
            out_regwr <= in_regwr;
            out_alusrc1 <= in_alusrc1;
            out_alusrc2 <= in_alusrc2;
            out_alufun <= in_alufun;
            out_sign <= in_sign;
            out_memwr <= in_memwr;
            out_memrd <= in_memrd;
            out_memtoreg <= in_memtoreg;
            out_imm <= in_imm;
            out_inst <= in_inst;
            out_databusA <= in_databusA;
            out_databusB <= in_databusB;
            out_pc <= in_pc;
            out_conba <= in_conba;
        end
    end
endmodule
