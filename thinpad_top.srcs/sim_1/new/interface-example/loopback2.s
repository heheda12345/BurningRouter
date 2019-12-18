.set noreorder
.globl main

main:
	lui $31, 0
	lui $30, 0
	lui $29, 0x8080
	addiu	$29,$29,-40
	sw	$31,36($29)
	sw	$30,32($29)
	or	$30,$29,$0
	sw	$0,16($30)
L4000a4:
	lw	$4,16($30)
	jal	receive_packet
	sll	$0,$0,0x0
	sw	$2,20($30)
	lw	$2,16($30)
	addiu	$2,$2,1
	sw	$2,16($30)
	lw	$3,16($30)
	addiu	$2,$0,128
	bne	$3,$2,L4000d4
	sll	$0,$0,0x0
	sw	$0,16($30)
L4000d4:
	lw	$2,20($30)
	lw	$2,0($2)
	sw	$2,24($30)
	lw	$2,24($30)
	slti	$2,$2,40
	beqz	$2,L4000f8
	sll	$0,$0,0x0
	beqz	$0,L400104
	sll	$0,$0,0x0
L4000f8:
	lw	$4,20($30)
	jal	send_packet
	sll	$0,$0,0x0
L400104:
	beqz	$0,L4000a4
	sll	$0,$0,0x0

receive_packet:
	addiu	$29,$29,-16
	sw	$30,12($29)
	or	$30,$29,$0
	sw	$4,16($30)
	lui	$2,0xbfd0
	ori	$2,$2,0x400
	sw	$2,0($30)
	lui	$2,0x8060
	sw	$2,4($30)
L400130:
	lw	$2,0($30)
	lw	$3,0($2)
	lw	$2,16($30)
	beq	$3,$2,L40014c
	sll	$0,$0,0x0
	beqz	$0,L400154
	sll	$0,$0,0x0
L40014c:
	beqz	$0,L400130
	sll	$0,$0,0x0
L400154:
	lw	$2,16($30)
	addiu	$3,$2,1
	sw	$3,16($30)
	sll	$2,$2,0xb
	or	$3,$2,$0
	lw	$2,4($30)
	addu	$2,$3,$2
	or	$29,$30,$0
	lw	$30,12($29)
	addiu	$29,$29,16
	jr	$31
	sll	$0,$0,0x0

send_packet:
	addiu	$29,$29,-16
	sw	$30,12($29)
	or	$30,$29,$0
	sw	$4,16($30)
	lui	$2,0xbfd0
	ori	$2,$2,0x408
	sw	$2,0($30)
	lui	$2,0xbfd0
	ori	$2,$2,0x404
	sw	$2,4($30)
L4001ac:
	lw	$2,4($30)
	lw	$2,0($2)
	bnez	$2,L4001c4
	sll	$0,$0,0x0
	beqz	$0,L4001cc
	sll	$0,$0,0x0
L4001c4:
	beqz	$0,L4001ac
	sll	$0,$0,0x0
L4001cc:
	lw	$2,0($30)
	lw	$3,16($30)
	sw	$3,0($2)
	or	$29,$30,$0
	lw	$30,12($29)
	addiu	$29,$29,16
	jr	$31
	sll	$0,$0,0x0
