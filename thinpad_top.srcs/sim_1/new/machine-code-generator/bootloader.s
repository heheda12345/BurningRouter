    .org 0x0
    .section .text.init
    .global __start
    .set noat
    .set noreorder
    .abicalls
__start:
    li $sp, 0x80800000
    bal bootloader
    nop

boot:
    li $s5, 0x80000000
    jr $s5
    nop

    .org 0x380
__halt:
    li $sp, 0x80800000
    mfc0 $a0, $14
    bal halt
    nop

end:
    j end
    nop
