`timescale 1ns / 1ps

module EX2MEM(reset, clk,
    in_aluout, in_databusB, in_pc, in_memrd, in_memwr, in_memtoreg, in_regwr, in_wraddr, in_pcsrc,
    out_aluout, out_databusB, out_pc, out_memrd, out_memwr, out_memtoreg, out_regwr, out_wraddr, out_pcsrc
    );
    input reset, clk;
    input [31:0] in_aluout;
    input in_regwr;
    input in_memwr;
    input in_memrd;
    input [1:0] in_memtoreg;
    input [31:0] in_databusB;
    input [31:0] in_pc;
    input [4:0] in_wraddr;
    input [2:0] in_pcsrc;
    
    output reg [31:0] out_aluout;
    output reg out_regwr;
    output reg out_memwr;
    output reg out_memrd;
    output reg [1:0] out_memtoreg;
    output reg [31:0] out_databusB;
    output reg [31:0] out_pc;
    output reg [4:0] out_wraddr;
    output reg [2:0] out_pcsrc;
    
    always @(posedge clk or negedge reset)
    begin
        if(~reset)
        begin
            out_aluout <= 0;
            out_regwr <= 0;
            out_memwr <= 0;
            out_memrd <= 0;
            out_memtoreg <= 0;
            out_databusB <= 0;
            out_pc <= 32'h80000000;
            out_wraddr <= 0;
            out_pcsrc <= 0;
        end
        else
        begin
            out_aluout <= in_aluout;
            out_regwr <= in_regwr;
            out_memwr <= in_memwr;
            out_memrd <= in_memrd;
            out_memtoreg <= in_memtoreg;
            out_databusB <= in_databusB;
            out_pc <= in_pc;
            out_wraddr <= in_wraddr;
            out_pcsrc <= in_pcsrc;
        end
    end
endmodule
