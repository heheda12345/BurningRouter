/**
 * Receive and send packet backend.
 */
.globl receive_packet
.globl send_packet
.set noreorder

.type receive_packet, @function
.type send_packet, @function

receive_packet:
    lui	    $2,0xbfd0
_LC0:
    nop
    nop
    lw	    $2,1024($2)
    nop
    nop
    beq	    $2,$4,_LC0
    nop
    sll	    $4,$4,0xb
    lui	    $2,0x8060
    jr	    $31
    addu	$2,$4,$2

send_packet:
    lui	    $2,0xbfd0
_LC1:
    nop
    nop
    lw	    $2,1028($2)
    nop
    nop
    bne	    $2,$0,_LC1
    nop
    lui	    $2,0xbfd0
    jr	    $31
    sw	    $4,1032($2)
