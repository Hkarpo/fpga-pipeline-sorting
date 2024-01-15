`timescale 1ns / 1ps

module MEM2WB(reset, clk,
    in_regwr, in_wraddr, in_memtoreg, in_pc, in_aluout, in_rddata,
    out_regwr, out_wraddr, out_memtoreg, out_pc, out_aluout, out_rddata
    );
    input reset, clk;
    input in_regwr;
    input [4:0] in_wraddr;
    input [1:0] in_memtoreg;
    input [31:0] in_pc;
    input [31:0] in_aluout;
    input [31:0] in_rddata;
    
    output reg out_regwr;
    output reg [4:0] out_wraddr;
    output reg [1:0]  out_memtoreg;
    output reg [31:0] out_pc;
    output reg [31:0] out_aluout;
    output reg [31:0] out_rddata;
    
    always @(posedge clk or negedge reset)
    begin
        if(~reset)
        begin
            out_regwr <= 0;
            out_wraddr <= 0;
            out_memtoreg <= 0;
            out_pc <= 32'h80000000;
            out_aluout <= 0;
            out_rddata <= 0;
        end
        else
        begin
            out_regwr <= in_regwr;
            out_wraddr <= in_wraddr;
            out_memtoreg <= in_memtoreg;
            out_pc <= in_pc;
            out_aluout <= in_aluout;
            out_rddata <= in_rddata;
        end
    end
endmodule
