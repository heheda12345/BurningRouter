    .org 0x0
    .section .text.init
    .global __start
    .set noat
    .set noreorder
__start:
    li $sp, 0x80800000
    bal bootloader
    nop

boot:
    bal main
    nop
    j end
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
