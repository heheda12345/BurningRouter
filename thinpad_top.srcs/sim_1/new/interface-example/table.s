.set noreorder
.global main

main:
	lui	$2,0xbfd0
	ori	$2,$2,0x0410
    ori $5, $0, 1
insert1:
    lui $4,0x0a00
    ori	$4,$4,0x010b
    sw $4, 0($2)
    sw $4, 4($2)
    ori $4, $0, 0
    sw $4, 12($2)
    ori	$4,$4,0x20
    sw $4, 8($2)
tosend:
    lw $3, 16($2)
    bnez $3, tosend
    nop
    sw $5, 16($2)
    j insert1
    nop

