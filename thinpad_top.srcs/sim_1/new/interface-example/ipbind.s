.set noreorder
.global main

main:
	lui	$2,0xbfd0
	ori	$2,$2,0x0410
    ori $5, $0, 2 
    lui $4,0x0102
    ori	$4,$4,0x0304
    sw $4, 0($2)
    ori $4, $0, 3
    sw $4, 12($2)
    sw $5, 16($2)
wait:
    j wait
    nop

