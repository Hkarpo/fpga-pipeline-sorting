        j main
        j Interrupt
        j Exception

main:   addi $s5, $zero, 1
        sll $s5, $s5, 30 #s5=32'h40000000
        sw $zero, 8($s5) #关闭定时器
        add $t0, $zero, $zero
        lui $t0, 65535
        addi $t0, $t0, 62767 #0xfffff52f
        sw $t0, 0($s5) #设置TH，即中断周期
        add $t0, $zero, $zero
        lui $t0, 65535
        addi $t0, $t0, 65535
        sw $t0, 4($s5) #TL=0xffffffff
        
        jal input #存数进RAM 
        
	addi $s1, $s1, 99 #s1：序列末尾编号100-1=99
	addi $s0, $zero, 0 #s0:首地址，含100
	addi $s0, $s0, 4 #跳过长度，s0：变成数组的首地址
	lw $s6, 20($s5) #s6:Systick初值
	
    	jal sort #冒泡
    	
    	lw $s7, 20($s5) #s7：Systick终值
        sub $s7, $s7, $s6 #s7：排序消耗的时钟周期数
        addi $t0, $zero, 3
        sw $t0, 8($s5) #开始定时器
        add $s4, $zero, $zero #s4记录中断次数
        addi $t6, $zero, 2000 #C显示2000次中断
        
wait1:  beq $t6, $s4, shownum #显示排好的数
        j wait1
shownum:
	add $s4, $zero, $zero #s4记录中断次数
        addi $t6, $zero, 2000 #每个数显示2000次中断
        lw $s7, 0($s0)
wait2:  beq $t6, $s4, nextnum
        j wait2
nextnum:   addi $s0, $s0, 4
        addi $s1, $s1, -4
        beq $s1, $zero, exit #退出
	j shownum

sort:	#冒泡
	addi $sp, $sp, -20
	sw   $ra, 16($sp)
	sw   $t8, 12($sp)
	sw   $t7, 8($sp)
	sw   $t6, 4($sp)
	sw   $t5, 0($sp)
	
	move $t7, $s0
	move $t8, $s1
	move $t5, $zero
for1tst:
	slt  $t0, $t5, $t8
	beq  $t0, $zero, exit1
	addi $t6, $t5, -1
for2tst:
	slti $t0, $t6, 0
	bne  $t0, $zero, exit2
	sll $t1, $t6, 2
	add  $t2, $t7, $t1
	lw   $t3, 0($t2)
	lw   $t4, 4($t2)
	slt  $t0, $t4, $t3
	beq  $t0, $zero, exit2
	move $s0, $t7
	move $s1, $t6
	jal swap
	addi $t6, $t6, -1
	j for2tst
exit2:
	addi $t5, $t5, 1
	j for1tst
exit1:
	lw   $t5, 0($sp)
	lw   $t6, 4($sp)
	lw   $t7, 8($sp)
	lw   $t8, 12($sp)
	lw   $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra
swap: 
	sll $t1, $s1, 2
	add $t1, $s0, $t1
	lw $t0, 0($t1)
	lw $t2, 4($t1)
	sw $t2, 0($t1)
	sw $t0, 4($t1)
	jr $ra
	

Interrupt: #中断
        sw $zero, 8($s5) #关闭定时器
        addi $s4, $s4, 1
        addi $s2, $zero, 3 #s2=3 为与操作做准备
        and $s3, $s4, $s2 #s3：取十进制第几位
        addi $t2, $zero, 15 #t2=2'b1111 为与操作做准备
        addi $t0, $zero, 0
        beq $s3, $t0, num0
        addi $t0, $zero, 1
        beq $s3, $t0, num1
        addi $t0, $zero, 2
        beq $s3, $t0, num2
        addi $t0, $zero, 3
        beq $s3, $t0, num3
        
num0:   and $t1, $s7, $t2
        addi $t4, $zero, 14 #1110
        j show
num1:   sll $t2, $t2, 4
        and $t1, $s7, $t2
        srl $t1, $t1, 4
        addi $t4, $zero, 13 #1101
        j show
num2:   sll $t2, $t2, 8
        and $t1, $s7, $t2
        srl $t1, $t1, 8
        addi $t4, $zero, 11 #1011
        j show
num3:   sll $t2, $t2, 12
        and $t1, $s7, $t2
        srl $t1, $t1, 12
        addi $t4, $zero, 7  #0111
        j show
#数码管的显示
show:   sll $t4, $t4, 8
        addi $t3, $zero, 0
        beq $t1, $t3, show0
        addi $t3, $zero, 1
        beq $t1, $t3, show1
        addi $t3, $zero, 2
        beq $t1, $t3, show2
        addi $t3, $zero, 3
        beq $t1, $t3, show3
        addi $t3, $zero, 4
        beq $t1, $t3, show4
        addi $t3, $zero, 5
        beq $t1, $t3, show5
        addi $t3, $zero, 6
        beq $t1, $t3, show6
        addi $t3, $zero, 7
        beq $t1, $t3, show7
        addi $t3, $zero, 8
        beq $t1, $t3, show8
        addi $t3, $zero, 9
        beq $t1, $t3, show9
        addi $t3, $zero, 10
        beq $t1, $t3, show10
        addi $t3, $zero, 11
        beq $t1, $t3, show11
        addi $t3, $zero, 12
        beq $t1, $t3, show12
        addi $t3, $zero, 13
        beq $t1, $t3, show13
        addi $t3, $zero, 14
        beq $t1, $t3, show14
        addi $t3, $zero, 15
        beq $t1, $t3, show15

show0:  addi $t5, $t4, 64  #1000000
        j jr26
show1:  addi $t5, $t4, 121 #1111001
        j jr26
show2:  addi $t5, $t4, 36  #0100100
        j jr26
show3:  addi $t5, $t4, 48  #0110000
        j jr26
show4:  addi $t5, $t4, 25  #0011001
        j jr26
show5:  addi $t5, $t4, 18  #0010010
        j jr26
show6:  addi $t5, $t4, 2   #0000010
        j jr26
show7:  addi $t5, $t4, 120 #1111000
        j jr26
show8:  addi $t5, $t4, 0   #0000000
        j jr26
show9:  addi $t5, $t4, 16  #0010000
        j jr26
show10: addi $t5, $t4, 8   #0001000
        j jr26
show11: addi $t5, $t4, 3   #0000011
        j jr26
show12: addi $t5, $t4, 70  #1000110
        j jr26
show13: addi $t5, $t4, 33  #0100001
        j jr26
show14: addi $t5, $t4, 6   #0000110
        j jr26
show15: addi $t5, $t4, 14  #0001110
        j jr26

jr26:   sw $t5, 16($s5)
        addi $t0, $zero, 3
        sw $t0, 8($s5) #开始定时器
        jr $26

Exception: #异常：无限循环
        j Exception 

input:   addi $t1, $zero, 0
        addi $t0, $zero, 100
        sw $t0, 0($t1)
        addi $t0, $zero, 468
        sw $t0, 4($t1)
        addi $t0, $zero, 233
        sw $t0, 8($t1)
        addi $t0, $zero, 337
        sw $t0, 12($t1)
        addi $t0, $zero, 498
        sw $t0, 16($t1)
        addi $t0, $zero, 173
        sw $t0, 20($t1)
        addi $t0, $zero, 722
        sw $t0, 24($t1)
        addi $t0, $zero, 476
        sw $t0, 28($t1)
        addi $t0, $zero, 355
        sw $t0, 32($t1)
        addi $t0, $zero, 96
        sw $t0, 36($t1)
        addi $t0, $zero, 456
        sw $t0, 40($t1)
        addi $t0, $zero, 703
        sw $t0, 44($t1)
        addi $t0, $zero, 130
        sw $t0, 48($t1)
        addi $t0, $zero, 284
        sw $t0, 52($t1)
        addi $t0, $zero, 829
        sw $t0, 56($t1)
        addi $t0, $zero, 967
        sw $t0, 60($t1)
        addi $t0, $zero, 489
        sw $t0, 64($t1)
        addi $t0, $zero, 934
        sw $t0, 68($t1)
        addi $t0, $zero, 996
        sw $t0, 72($t1)
        addi $t0, $zero, 393
        sw $t0, 76($t1)
        addi $t0, $zero, 47
        sw $t0, 80($t1)
        addi $t0, $zero, 870
        sw $t0, 84($t1)
        addi $t0, $zero, 607
        sw $t0, 88($t1)
        addi $t0, $zero, 915
        sw $t0, 92($t1)
        addi $t0, $zero, 143
        sw $t0, 96($t1)
        addi $t0, $zero, 298
        sw $t0, 100($t1)
        addi $t0, $zero, 385
        sw $t0, 104($t1)
        addi $t0, $zero, 421
        sw $t0, 108($t1)
        addi $t0, $zero, 727
        sw $t0, 112($t1)
        addi $t0, $zero, 709
        sw $t0, 116($t1)
        addi $t0, $zero, 89
        sw $t0, 120($t1)
        addi $t0, $zero, 484
        sw $t0, 124($t1)
        addi $t0, $zero, 717
        sw $t0, 128($t1)
        addi $t0, $zero, 772
        sw $t0, 132($t1)
        addi $t0, $zero, 593
        sw $t0, 136($t1)
        addi $t0, $zero, 817
        sw $t0, 140($t1)
        addi $t0, $zero, 913
        sw $t0, 144($t1)
        addi $t0, $zero, 669
        sw $t0, 148($t1)
        addi $t0, $zero, 300
        sw $t0, 152($t1)
        addi $t0, $zero, 37
        sw $t0, 156($t1)
        addi $t0, $zero, 895
        sw $t0, 160($t1)
        addi $t0, $zero, 604
        sw $t0, 164($t1)
        addi $t0, $zero, 512
        sw $t0, 168($t1)
        addi $t0, $zero, 123
        sw $t0, 172($t1)
        addi $t0, $zero, 333
        sw $t0, 176($t1)
        addi $t0, $zero, 650
        sw $t0, 180($t1)
        addi $t0, $zero, 624
        sw $t0, 184($t1)
        addi $t0, $zero, 139
        sw $t0, 188($t1)
        addi $t0, $zero, 745
        sw $t0, 192($t1)
        addi $t0, $zero, 251
        sw $t0, 196($t1)
        addi $t0, $zero, 246
        sw $t0, 200($t1)
        addi $t0, $zero, 538
        sw $t0, 204($t1)
        addi $t0, $zero, 645
        sw $t0, 208($t1)
        addi $t0, $zero, 663
        sw $t0, 212($t1)
        addi $t0, $zero, 758
        sw $t0, 216($t1)
        addi $t0, $zero, 138
        sw $t0, 220($t1)
        addi $t0, $zero, 861
        sw $t0, 224($t1)
        addi $t0, $zero, 124
        sw $t0, 228($t1)
        addi $t0, $zero, 942
        sw $t0, 232($t1)
        addi $t0, $zero, 230
        sw $t0, 236($t1)
        addi $t0, $zero, 36
        sw $t0, 240($t1)
        addi $t0, $zero, 317
        sw $t0, 244($t1)
        addi $t0, $zero, 978
        sw $t0, 248($t1)
        addi $t0, $zero, 191
        sw $t0, 252($t1)
        addi $t0, $zero, 107
        sw $t0, 256($t1)
        addi $t0, $zero, 289
        sw $t0, 260($t1)
        addi $t0, $zero, 643
        sw $t0, 264($t1)
        addi $t0, $zero, 943
        sw $t0, 268($t1)
        addi $t0, $zero, 42
        sw $t0, 272($t1)
        addi $t0, $zero, 447
        sw $t0, 276($t1)
        addi $t0, $zero, 882
        sw $t0, 280($t1)
        addi $t0, $zero, 265
        sw $t0, 284($t1)
        addi $t0, $zero, 806
        sw $t0, 288($t1)
        addi $t0, $zero, 891
        sw $t0, 292($t1)
        addi $t0, $zero, 371
        sw $t0, 296($t1)
        addi $t0, $zero, 351
        sw $t0, 300($t1)
        addi $t0, $zero, 540
        sw $t0, 304($t1)
        addi $t0, $zero, 102
        sw $t0, 308($t1)
        addi $t0, $zero, 71
        sw $t0, 312($t1)
        addi $t0, $zero, 394
        sw $t0, 316($t1)
        addi $t0, $zero, 549
        sw $t0, 320($t1)
        addi $t0, $zero, 639
        sw $t0, 324($t1)
        addi $t0, $zero, 617
        sw $t0, 328($t1)
        addi $t0, $zero, 7
        sw $t0, 332($t1)
        addi $t0, $zero, 955
        sw $t0, 336($t1)
        addi $t0, $zero, 757
        sw $t0, 340($t1)
        addi $t0, $zero, 841
        sw $t0, 344($t1)
        addi $t0, $zero, 932
        sw $t0, 348($t1)
        addi $t0, $zero, 359
        sw $t0, 352($t1)
        addi $t0, $zero, 967
        sw $t0, 356($t1)
        addi $t0, $zero, 440
        sw $t0, 360($t1)
        addi $t0, $zero, 945
        sw $t0, 364($t1)
        addi $t0, $zero, 209
        sw $t0, 368($t1)
        addi $t0, $zero, 624
        sw $t0, 372($t1)
        addi $t0, $zero, 385
        sw $t0, 376($t1)
        addi $t0, $zero, 539
        sw $t0, 380($t1)
        addi $t0, $zero, 538
        sw $t0, 384($t1)
        addi $t0, $zero, 911
        sw $t0, 388($t1)
        addi $t0, $zero, 58
        sw $t0, 392($t1)
        addi $t0, $zero, 930
        sw $t0, 396($t1)
        addi $t0, $zero, 572
        sw $t0, 400($t1)
        jr $ra

exit:
