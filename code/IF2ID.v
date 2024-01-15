`timescale 1ns / 1ps

module IF2ID(reset, clk, flush, irq,
    in_inst, in_pc,
    out_inst, out_pc,
    upd_pc
    );
    
    input reset, clk, flush, irq;
    input [31:0] in_inst;
    input [31:0] in_pc;
    input upd_pc;
    
    output[31:0] out_inst;
    output[31:0] out_pc;
    
    reg [31:0] out_inst;
    reg [31:0] out_pc;
    
    always @(posedge clk or negedge reset)
    begin
        if(~reset)
        begin
            out_pc <= 32'h80000000;
            out_inst <= 32'h0;
        end
        else if(flush)
        begin
            //out_pc <= 32'h0;
            out_pc <= in_pc;
            out_inst <= 32'h0;
        end
        else if(upd_pc && irq == 0)
        begin
            out_pc <= in_pc;
            out_inst <= in_inst;
        end
        else if(upd_pc && irq != 0)
        begin
            out_pc <= 32'h0;
            out_inst <= 32'h0;
        end
    end
endmodule
