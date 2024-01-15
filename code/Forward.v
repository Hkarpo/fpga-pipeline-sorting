`timescale 1ns / 1ps
//  0: 正常
//	1: 从前一条指令forward
//	2: 从前两条指令forward
//	3: 从前三条指令forward
module Forward(id_pcsrc, id_rs, id_rt, ex_rs, ex_rt, ex_regwr, ex_wraddr, mem_wraddr, mem_regwr, wb_wraddr, wb_regwr,
    id_fwdA, id_fwdB, ex_fwdA, ex_fwdB, jr_fwd);
    input [2:0] id_pcsrc;
    input [4:0] id_rs; //id_rs: id_inst[25:21]
    input [4:0] id_rt; //id_rt: id_inst[20:16]
    input [4:0] ex_rs; //ex_rs: ex_inst[25:21]
    input [4:0] ex_rt; //ex_rt: ex_inst[20:16]
    input ex_regwr;
    input [4:0] ex_wraddr;//ex_wraddr: ex_inst[15:11]
    input [4:0] mem_wraddr;
    input mem_regwr;
    input [4:0] wb_wraddr;
    input wb_regwr;
    
    output [1:0] id_fwdA;
    output [1:0] id_fwdB;
    output [1:0] ex_fwdA;
    output [1:0] ex_fwdB;
    output [1:0] jr_fwd;
    
// WB -> ID: rs and rt
    assign id_fwdA = 
        (wb_regwr && (wb_wraddr == id_rs))? 2'd3: //(wb_wraddr != 0) && 
        //&& ((id_rs != mem_wraddr || ~mem_regwr) && (id_rs != ex_wraddr || ~ex_regwr)) 
        2'd0;
    
    assign id_fwdB =
        (wb_regwr && (wb_wraddr == id_rt))? 2'd3: //(wb_wraddr != 0) && 
         //&& ((id_rt != mem_wraddr || ~mem_regwr) && (id_rt != ex_wraddr || ~ex_regwr))
        2'd0;

// WB -> EX_rs or MEM -> EX_rs
    assign ex_fwdA =
        ((wb_wraddr != 0) && wb_regwr && (wb_wraddr == ex_rs))? 2'd2: // && (ex_rs != mem_wraddr || ~mem_regwr)
        ((mem_wraddr != 0) && mem_regwr && (ex_rs == mem_wraddr))? 2'd1:
        2'd0;
        
// WB -> EX_rt or MEM -> EX_rt
    assign ex_fwdB =
        ((wb_wraddr != 0) && wb_regwr && (wb_wraddr == ex_rt))? 2'd2: // && (ex_rt != mem_wraddr || ~mem_regwr)
        ((mem_wraddr != 0) && mem_regwr && (ex_rt == mem_wraddr))? 2'd1:
        2'd0;
    
// jr
    assign jr_fwd = 
        ((id_pcsrc == 3'd3) && (ex_wraddr != 0) && ex_regwr &&(ex_wraddr == id_rs))? 2'd1:
        ((id_pcsrc == 3'd3) && (mem_wraddr != 0) && mem_regwr && (mem_wraddr == id_rs) && (id_rs != ex_wraddr))? 2'd2:
        ((id_pcsrc == 3'd3) && (wb_wraddr != 0) && wb_regwr && (wb_wraddr == id_rs) && (id_rs != ex_wraddr) && (id_rs != mem_wraddr))? 2'd3:
        2'd0;
endmodule
