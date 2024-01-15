`timescale 1ns / 1ps
module PC(reset, clk, if_upd_pc, id_jt, id_pcsrc, branch, ex_conba, ex_pcsrc, databusA, if_pc);
    input reset, clk;
    input if_upd_pc;
    input branch; // ex_aluout[0]
    input [31:0] id_jt;
    input [2:0] id_pcsrc;
    input [2:0] ex_pcsrc;
    input [31:0] ex_conba;
    input databusA;
    output wire [31:0]if_pc;
    reg [31:0] if_pc_next;
    initial
        #0 if_pc_next = 32'h80000000;
        
    assign if_pc = if_pc_next;
    
    wire [31:0] pcnext;
    wire [31:0] if_pc_4;
    assign if_pc_4 = {if_pc[31], if_pc[30:0] + 31'd4};
    
       //(ex_pcsrc == 3'd03 || (ex_pcsrc == 3'd01 && branch))? ex_pcsrc:
       
    wire [2:0] pcsrc;
    assign pcsrc =
        (id_pcsrc == 3'd02 || id_pcsrc == 3'd04)? id_pcsrc:
        (ex_pcsrc != 3'd0 && ex_pcsrc != 3'd02 && ex_pcsrc != 3'd04)? ex_pcsrc:
        3'd0;
    
    assign pcnext = 
        (pcsrc == 3'd0 && if_upd_pc)? if_pc_4: //except load-use
        (pcsrc == 3'd1 && branch)? ex_conba:
        (pcsrc == 3'd1 && !branch)? if_pc_4:
        (pcsrc == 3'd2)? id_jt:
        (pcsrc == 3'd3)? databusA:
        (pcsrc == 3'd4)? 32'h80000004:
        (!if_upd_pc)? if_pc:
        32'h80000008;

    always @(posedge clk or negedge reset)
    begin
        if(~reset)
        begin
            if_pc_next <= 32'h80000000;
        end
        else
        begin
            if_pc_next <= pcnext;
        end
    end
endmodule
