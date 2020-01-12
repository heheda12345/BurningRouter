.set noreorder
.global __start
.section .text.init

__start:
    li $29, 0x80800000
    jal main
