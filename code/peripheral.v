`timescale 1ns / 1ps
module peripheral(reset, clk, rd, wr, addr, rdata, led, irq, wdata, digi);
//    input reset, clk;
//    input rd, wr;
//    input [31:0] addr;
//    output [31:0] rdata;
//    output [7:0] led;
//    output [11:0] digi;
//    output irq;
//    output pr;
    
//    reg [31:0] rdata, wdata;
//    reg [31:0] TH, TL;
//    reg [2:0] TCON;
//    reg [31:0] systick;
//    reg [7:0] led;
//    reg [11:0] digi;
//    reg [31:0] pr;
    
//    assign irq = TCON[2]; //中断信号
    
//    always@(*) begin
//        if(rd) begin //读外设寄存器
//            case(addr)
//                32'h40000000: rdata <= TH;
//                32'h40000004: rdata <= TL;
//                32'h40000008: rdata <= {29'b0, TCON};
//                32'h4000000C: rdata <= {24'b0, led};
//                32'h40000010: rdata <= {20'b0, digi};
//                32'h40000014: rdata <= systick;
//                default: rdata <= 32'b0;
//            endcase
//        end
//        else
//            rdata <= 32'b0;
//    end
//    always@(negedge reset or posedge clk) begin
//        if(reset) begin //未reset 定时器继续计时
//            systick <= systick + 32'b1;
//            if(TCON[0]) begin //timer is enabled
//               if(TL == 32'hffffffff) begin
//                TL <= TH;
//                if(TCON[1]) TCON[2] <= 1'b1; //irq is enabled
//               end
//               else TL <= TL + 1;
//            end
            
//            if(wr) begin //写外设寄存器
//                case(addr)
//                    32'h40000000: TH <= wdata;
//                    32'h40000004: TL <= wdata;
//                    32'h40000008: TCON <= {29'b0, wdata[2:0]};
//                    32'h4000000C: led <= {24'b0, wdata[7:0]};
//                    32'h40000010: digi <= {20'b0, wdata[11:0]};
//                    32'h4000001c: pr <= wdata;	
//                endcase
//            end
//        end
//        else begin //重置 定时器重新开始计时
//            TH <= 32'b0;
//            TL <= 32'b0;
//            TCON <= 32'b0;
//            systick <= 32'b0;
//            pr <= 32'b0;
//        end
//    end
    
input clk,reset;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
output reg [7:0] led;
output reg [11:0] digi;
reg [2:0] TCON;
output irq;
reg [31:0] TH,TL;
reg [31:0] systick;


assign irq = TCON[2];

initial 
	begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;
		systick<=32'b0;
		led <= 32'b0;
		digi <= 12'b0;
	end

assign rdata = (rd == 0)? 32'b0 :
			(addr == 32'h40000000)? TH:
			(addr == 32'h40000004)? TL:
			(addr == 32'h40000008)? {29'b0,TCON}:
			(addr == 32'h4000000C)? {24'b0,led}:
			(addr == 32'h40000010)? {20'b0,digi}:
			(addr == 32'h40000014)? systick:
			32'b0;
			

always@(negedge reset or posedge clk) begin
	if(reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
		systick <= 32'b0;
		led <= 32'b0;
		digi <= 12'b0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
	if(wr) begin
		case(addr)
			32'h40000000: TH <= wdata;
			32'h40000004: TL <= wdata;
			32'h40000008: TCON <= wdata[2:0];	
		    32'h40000010: digi<=wdata[11:0];	
			32'h4000000C: led <= wdata[7:0];		
			default:;
		endcase
	end
	systick <= systick+1;
	end
end
endmodule
