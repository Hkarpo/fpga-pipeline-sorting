`timescale 1ns / 1ps
// branch success, stall: 2, flush: if_flush and id_flush, update PC
// load-use hazard, stall: 1, flush: id_flush
// jump, stall: 1, flush: if_flush (judge jump in ID), update PC
module Hazard(id_pcsrc,id_rs, id_rt, ex_pcsrc, ex_memrd, ex_rt, ex_rs, branch, if_flush, id_flush, if_upd_pc);
    input [4:0] id_rs; //id_rs: id_inst[25:21]
    input [4:0] id_rt; //id_rt: id_inst[20:16]
    input [4:0] ex_rs; //ex_rs: ex_inst[25:21]
    input [4:0] ex_rt; //ex_rt: ex_inst[20:16]
    input [2:0] id_pcsrc;
    input [2:0] ex_pcsrc;
    input ex_memrd;
    input branch; //ex_aluout[0]
    
    output if_flush;
    output id_flush;
    output if_upd_pc;
    
    assign if_flush = // IF/ID.flsuh
        ((ex_pcsrc == 3'd1 && branch) || (id_pcsrc == 3'd2) || (id_pcsrc == 3'd3))? 1'b1: //branch success and jump
        1'b0;
        
    assign id_flush = //ID/EX.flush
        ((ex_pcsrc == 3'd1 && branch) || (ex_memrd && ((ex_rt == id_rs) || (ex_rt == id_rt)))|| (id_pcsrc == 3'd3))? 1'b1: // branch success and load-use hazard
        1'b0;
    
    assign if_upd_pc = 
        (ex_memrd && ((ex_rt == id_rs) || (ex_rt == id_rt)))? 1'b0: // load-use hazard
        1'b1;
endmodule
