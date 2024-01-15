`timescale 1ns / 1ps

module pipeline(reset, clk, led, digi);
    input reset, clk;
    output [7:0] led; //其实最后没有用上
    output [11:0] digi;
    
    wire irq;
    wire [31:0] if_inst;
    wire [31:0] if_pc;
    wire if_flush; //IF/ID
    wire if_upd_pc;
    
    wire id_flush; //ID/EX
    wire [2:0] id_pcsrc;
    wire [1:0] id_regdst;
    wire id_regwr;
    wire id_alusrc1, id_alusrc2;
    wire [5:0] id_alufun;
    wire id_sign;
    wire id_memwr;
    wire id_memrd;
    wire [1:0] id_memtoreg;
    wire [31:0] id_imm;
    wire [31:0] id_inst; //contain shamt[4:0] as inst[10:6] and regwr addr rd[4:0] as inst[15:11]
    wire [31:0] id_databusA;
    wire [31:0] id_fwd_dbA;
    wire [31:0] id_databusB;
    wire [31:0] id_fwd_dbB;
    wire [31:0] id_pc;
    wire [31:0] id_conba;
    wire id_extop;
    wire id_luop;
    wire [31:0] id_jt;
    
    wire [2:0] ex_pcsrc;
    wire [1:0] ex_regdst;
    wire ex_regwr;
    wire ex_alusrc1, ex_alusrc2;
    wire [5:0] ex_alufun;
    wire ex_sign;
    wire ex_memwr;
    wire ex_memrd;
    wire [1:0] ex_memtoreg;
    wire [31:0] ex_imm;
    wire [31:0] ex_inst; //contain shamt[4:0] as inst[10:6] and regwr addr rd[4:0] as inst[15:11]
    wire [31:0] ex_databusA;
    wire [31:0] ex_fwd_dbA;
    wire [31:0] ex_databusB;
    wire [31:0] ex_fwd_dbB;
    wire [31:0] ex_pc;
    wire [31:0] ex_conba;
    wire [31:0] ex_aluout;
    wire [4:0] ex_wraddr;
    
    wire [31:0] mem_aluout;
    wire mem_regwr;
    wire mem_memwr;
    wire mem_memrd;
    wire [1:0] mem_memtoreg;
    wire [31:0] mem_databusB;
    wire [31:0] mem_pc;
    wire [4:0] mem_wraddr;
    wire [31:0] mem_rddata;
    wire [2:0] mem_pcsrc;
    
    wire [4:0] wb_wraddr;
    wire [1:0] wb_memtoreg;
    wire wb_regwr;
    wire [31:0] wb_pc;
    wire [31:0] wb_aluout;
    wire [31:0] wb_rddata;
    wire [31:0] wb_databusC;
        
    wire [1:0] id_fwdA, id_fwdB, ex_fwdA, ex_fwdB, jr_fwd;
    
// IF module    
	InstructionMemory instruction_memory1(.Address(if_pc), .Instruction(if_inst));

// IF/ID
    //wire [31:0] id_inst1;
    IF2ID if2id(.reset(reset), .clk(clk), .flush(if_flush), .in_inst(if_inst), .in_pc(if_pc), .out_inst(id_inst), .out_pc(id_pc), .upd_pc(if_upd_pc), .irq(irq));
    
// ID module
    //assign id_inst = irq? 32'b0: id_inst1;
    Control control1(.OpCode(id_inst[31:26]), .Funct(id_inst[5:0]), .irq(irq), .PCSrc(id_pcsrc), .RegWrite(id_regwr), .RegDst(id_regdst), 
		.MemRead(id_memrd),	.MemWrite(id_memwr), .MemtoReg(id_memtoreg), .ALUSrc1(id_alusrc1), .ALUSrc2(id_alusrc2), .ExtOp(id_extop), .LuOp(id_luop), .Sign(id_sign), .ALUfun(id_alufun)); 
    
    RegisterFile register_file1(.reset(reset), .clk(clk), .RegWrite(wb_regwr), 
		.Read_register1(id_inst[25:21]), .Read_register2(id_inst[20:16]), .Write_register(wb_wraddr),
		.Write_data(wb_databusC), .Read_data1(id_databusA), .Read_data2(id_databusB));
    
    assign id_jt = {id_pc[31:28], id_inst[25:0], 2'b00};
    
    // Ext32 and LuOp select
    wire [31:0] id_extout;
	assign id_extout = (id_extop && id_inst[15])? {16'hffff,id_inst[15:0]}: {16'h0000, id_inst[15:0]};
	assign id_imm = id_luop? {id_inst[15:0], 16'h0000}: id_extout;
	
	assign id_conba = {id_extout[29:0],2'b00}+id_pc+3'd4;
    
// ID/EX
    ID2EX id2ex( .reset(reset), .clk(clk), .flush(id_flush),
        .in_pcsrc(id_pcsrc), .in_regdst(id_regdst), .in_regwr(id_regwr), .in_alusrc1(id_alusrc1), .in_alusrc2(id_alusrc2), .in_alufun(id_alufun), .in_sign(id_sign), .in_memwr(id_memwr), .in_memrd(id_memrd), .in_memtoreg(id_memtoreg), .in_imm(id_imm), .in_pc(id_pc), .in_databusA(id_fwd_dbA), .in_databusB(id_fwd_dbB), .in_inst(id_inst), .in_conba(id_conba),
        .out_pcsrc(ex_pcsrc), .out_regdst(ex_regdst), .out_regwr(ex_regwr), .out_alusrc1(ex_alusrc1), .out_alusrc2(ex_alusrc2),  .out_alufun(ex_alufun), .out_sign(ex_sign), .out_memwr(ex_memwr), .out_memrd(ex_memrd), .out_memtoreg(ex_memtoreg), .out_imm(ex_imm), .out_pc(ex_pc), .out_databusA(ex_databusA), .out_databusB(ex_databusB), .out_inst(ex_inst), .out_conba(ex_conba));
    
// EX module
    wire [31:0] ex_ALU_in1;
	wire [31:0] ex_ALU_in2;
	//wire Zero;
	assign ex_ALU_in1 = ex_alusrc1? {27'h00000, ex_inst[10:6]}: ex_fwd_dbA;
	assign ex_ALU_in2 = ex_alusrc2? ex_imm: ex_fwd_dbB;
	
	ALU alu1(.in1(ex_ALU_in1), .in2(ex_ALU_in2), .ALUFun(ex_alufun), .Opcode(ex_inst[31:26]), .Sign(ex_sign), .out(ex_aluout));
	
    assign ex_wraddr = 
        (ex_regdst == 2'd0)? ex_inst[15:11]:
        (ex_regdst == 2'd1)? ex_inst[20:16]:
        (ex_regdst == 2'd2)? 5'd31:
        (ex_regdst == 2'd3)? 5'd26:
        5'd26;
        
// EX/MEM
    EX2MEM ex2mem(.reset(reset), .clk(clk),
        .in_aluout(ex_aluout), .in_databusB(ex_fwd_dbB), .in_pc(ex_pc), .in_memrd(ex_memrd), .in_memwr(ex_memwr), .in_memtoreg(ex_memtoreg), .in_regwr(ex_regwr), .in_wraddr(ex_wraddr), .in_pcsrc(ex_pcsrc),
        .out_aluout(mem_aluout), .out_databusB(mem_databusB), .out_pc(mem_pc), .out_memrd(mem_memrd), .out_memwr(mem_memwr), .out_memtoreg(mem_memtoreg), .out_regwr(mem_regwr), .out_wraddr(mem_wraddr), .out_pcsrc(mem_pcsrc));
    
// MEM module
    wire [11:0] digi;
    wire [31:0] pr;
   // wire [7:0] led1, led2;
    //wire [31:0] mem_rddata1, mem_rddata2;
    
    DataMemory datamem(.reset(reset), .clk(clk), .Address(mem_aluout), .Write_data(mem_databusB), .Read_data(mem_rddata), .MemRead(mem_memrd), .MemWrite(mem_memwr), .leds(led), .irq(irq), .digi(digi));
    
//    peripheral per(.reset(reset), .clk(clk), .rd(mem_memrd), .wr(mem_memwr), .addr(mem_aluout), .rdata(mem_rddata2), .led(led2), .irq(irq), .pr(pr), .wdata(mem_databusB), .digi(digi));
   
    //assign led = led_enable? led2: led1;
    //assign mem_rddata = (mem_aluout[30:28] == 3'd4)? mem_rddata2: mem_rddata1;
 
// MEM/WB
    MEM2WB mem2wb(.reset(reset), .clk(clk),
        .in_regwr(mem_regwr), .in_wraddr(mem_wraddr), .in_memtoreg(mem_memtoreg), .in_pc(mem_pc), .in_aluout(mem_aluout), .in_rddata(mem_rddata),
        .out_regwr(wb_regwr), .out_wraddr(wb_wraddr), .out_memtoreg(wb_memtoreg), .out_pc(wb_pc), .out_aluout(wb_aluout), .out_rddata(wb_rddata));
   
//WB
    assign wb_databusC = 
        (wb_memtoreg == 2'd0)? wb_aluout:
        (wb_memtoreg == 2'd1)? wb_rddata:
        {wb_pc[31], wb_pc[30:0] + 31'd4};

// Forwarding
    wire [31:0] jrdatabusA;
    Forward fwd(.id_pcsrc(id_pcsrc), .id_rs(id_inst[25:21]), .id_rt(id_inst[20:16]), .ex_rs(ex_inst[25:21]), .ex_rt(ex_wraddr),
        .ex_regwr(ex_regwr), .ex_wraddr(ex_inst[15:11]), .mem_wraddr(mem_wraddr), .mem_regwr(mem_regwr), .wb_wraddr(wb_wraddr), .wb_regwr(wb_regwr),
        .id_fwdA(id_fwdA), .id_fwdB(id_fwdB), .ex_fwdA(ex_fwdA), .ex_fwdB(ex_fwdB), .jr_fwd(jr_fwd));
    assign id_fwd_dbA = (id_fwdA == 2'd3)? wb_databusC: id_databusA;
    assign id_fwd_dbB = (id_fwdB == 2'd3)? wb_databusC: id_databusB;
    assign ex_fwd_dbA = 
        (ex_fwdA == 2'd2)? wb_databusC:
        (ex_fwdA == 2'd1)? mem_aluout:
        ex_databusA;
    assign ex_fwd_dbB = 
        (ex_fwdB == 2'd2)? wb_databusC:
        (ex_fwdB == 2'd1)? mem_aluout:
        ex_databusB;
    assign jrdatabusA =
        (jr_fwd == 2'd3)? wb_databusC:
        (jr_fwd == 2'd2)? mem_aluout:
        (jr_fwd == 2'd1)? ex_aluout:
        id_databusA;
        

// Hazard
    Hazard hzd(.id_pcsrc(id_pcsrc), .id_rs(id_inst[25:21]), .id_rt(id_inst[20:16]), .ex_pcsrc(ex_pcsrc), .ex_memrd(ex_memrd),
        .ex_rs(ex_inst[25:21]), .ex_rt(ex_inst[20:16]), .branch(ex_aluout[0]), .if_flush(if_flush), .id_flush(id_flush), .if_upd_pc(if_upd_pc));

// PC
    PC pc(.reset(reset), .clk(clk), .if_upd_pc(if_upd_pc), .id_jt(id_jt), .id_pcsrc(id_pcsrc), .branch(ex_aluout[0]), .ex_conba(ex_conba), .ex_pcsrc(ex_pcsrc), .databusA(jrdatabusA), .if_pc(if_pc));

//display
//    wire clk1k;
//    clk1 c(.sysclk(clk), .sysclk1k(clk1k));
//    display DIS(pr[15:0],clk1k,digi[11:8],digi[6:0]);
endmodule
