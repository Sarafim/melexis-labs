# Test 007

.set noreorder
lui	$a3 0xFFFF
addi	$t0 $zero 0x18
addiu 	$t1 $zero 0x123
jr 	$t0
nop
add 	$v0 $t1 $t1
addu	$v1 $t1 $t1
add 	$t2 $t1 $t0
addu	$t3 $t1 $t0
beq	$t2 $t3 main
nop
sub 	$t2 $t1 $t0
subu 	$t4 $t1 $t0
main:
beq	$t2 $zero main
nop
bne	$t2 $zero main1
nop
and	$t4 $t4 $t1 
or 	$t2 $t4 $t1
main1:
bne 	$zero $zero main2
nop
xor 	$s0 $t2 $t1
nor 	$s1 $t2 $t2
slt 	$s2 $t0 $t1
sltu	$s3 $t2 $t1
j main2
nop
sllv	$s2 $t4 $t1
srlv	$s2 $t1 $t1
srav	$s5 $t4 $t1
sll	$s2 $t4 0x2
srl	$t1 $t4 0x12
sra	$t1 $t4 0x7
ori 	$k1 $t5 0x7	
main2:
xori 	$k1 $t3 0x234
sw 	$t1 0($zero)
lw 	$a2 0($zero)

sub 	$t4 $t1 $t0
subu 	$t5 $t1 $t0
and	$t6 $t4 $t1 
or 	$t7 $t4 $t1
sllv	$s4 $t4 $t1
srlv	$s5 $t1 $t1
srav	$s6 $t4 $t1
sll	$s7 $t4 0x2
srl	$t8 $t4 0x12
sra	$t9 $t4 0x7
ori 	$k0 $t5 0x7


ror $a1 $a3 0x7
ror $a0 $a3 $s2

