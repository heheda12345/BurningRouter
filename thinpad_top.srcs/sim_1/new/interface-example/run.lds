SECTIONS {
    . = 0x80000000;
    .text : {
        *(.text.init)
        *(.text.startup)
        *(.text)
    }
    . = 0x80400000;
    .data : { *(.data) }
    _bss_start = .;
    .bss : { *(.bss) }
    _bss_end = .;
}