.set noreorder
.global main

main:
	lui	$2,0xbfd0
	ori	$2,$2,0x0440
_LC0:
    lw $3, 0($2)
    lw $4, 4($2)
    ori $5, $0, 1000
_LC1:
    bne $5, $0, _LC1
    addiu $5, $5, -1
    j _LC0
    nop

