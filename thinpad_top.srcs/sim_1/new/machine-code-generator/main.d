
main.cpp.o:     file format elf32-tradlittlemips


Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	e00000fc 	sc	$0,252($0)
	...

Disassembly of section .MIPS.abiflags:

00000000 <.MIPS.abiflags>:
   0:	01200000 	0x1200000
   4:	02000101 	0x2000101
	...
  10:	00000001 	movf	$0,$0,$fcc0
  14:	00000000 	sll	$0,$0,0x0

Disassembly of section .pdr:

00000000 <.pdr>:
   0:	00000000 	sll	$0,$0,0x0
   4:	c0000000 	ll	$0,0($0)
   8:	fffffffc 	sdc3	$31,-4($31)
	...
  14:	00000048 	0x48
  18:	0000001e 	0x1e
  1c:	0000001f 	0x1f

Disassembly of section .bss.packet:

00000000 <packet>:
	...

Disassembly of section .text.main:

00000000 <main>:
   0:	27bdffb8 	addiu	$29,$29,-72
   4:	afbf0044 	sw	$31,68($29)
   8:	afbe0040 	sw	$30,64($29)
   c:	03a0f025 	or	$30,$29,$0
  10:	afc00024 	sw	$0,36($30)
  14:	27c50034 	addiu	$5,$30,52
  18:	27c4002c 	addiu	$4,$30,44
  1c:	27c2003c 	addiu	$2,$30,60
  20:	afa20018 	sw	$2,24($29)
  24:	240203e8 	addiu	$2,$0,1000
  28:	00001825 	or	$3,$0,$0
  2c:	afa20010 	sw	$2,16($29)
  30:	afa30014 	sw	$3,20($29)
  34:	00a03825 	or	$7,$5,$0
  38:	00803025 	or	$6,$4,$0
  3c:	3c020000 	lui	$2,0x0
  40:	24450000 	addiu	$5,$2,0
  44:	8fc40024 	lw	$4,36($30)
  48:	0c000000 	jal	0 <main>
  4c:	00000000 	sll	$0,$0,0x0
  50:	afc20028 	sw	$2,40($30)
  54:	8fc30028 	lw	$3,40($30)
  58:	2402fc1c 	addiu	$2,$0,-996
  5c:	14620003 	bne	$3,$2,6c <main+0x6c>
  60:	00000000 	sll	$0,$0,0x0
  64:	10000040 	beqz	$0,168 <main+0x168>
  68:	00000000 	sll	$0,$0,0x0
  6c:	8fc20028 	lw	$2,40($30)
  70:	04410004 	bgez	$2,84 <main+0x84>
  74:	00000000 	sll	$0,$0,0x0
  78:	8fc20028 	lw	$2,40($30)
  7c:	1000003a 	beqz	$0,168 <main+0x168>
  80:	00000000 	sll	$0,$0,0x0
  84:	8fc20028 	lw	$2,40($30)
  88:	10400031 	beqz	$2,150 <main+0x150>
  8c:	00000000 	sll	$0,$0,0x0
  90:	8fc20028 	lw	$2,40($30)
  94:	2c420801 	sltiu	$2,$2,2049
  98:	10400030 	beqz	$2,15c <main+0x15c>
  9c:	00000000 	sll	$0,$0,0x0
  a0:	afc00020 	sw	$0,32($30)
  a4:	8fc30020 	lw	$3,32($30)
  a8:	8fc20028 	lw	$2,40($30)
  ac:	0062102a 	slt	$2,$3,$2
  b0:	1040ffd8 	beqz	$2,14 <main+0x14>
  b4:	00000000 	sll	$0,$0,0x0
  b8:	8fc20020 	lw	$2,32($30)
  bc:	3042000f 	andi	$2,$2,0xf
  c0:	14400004 	bnez	$2,d4 <main+0xd4>
  c4:	00000000 	sll	$0,$0,0x0
  c8:	2404000a 	addiu	$4,$0,10
  cc:	0c000000 	jal	0 <main>
  d0:	00000000 	sll	$0,$0,0x0
  d4:	3c020000 	lui	$2,0x0
  d8:	24430000 	addiu	$3,$2,0
  dc:	8fc20020 	lw	$2,32($30)
  e0:	00621021 	addu	$2,$3,$2
  e4:	90420000 	lbu	$2,0($2)
  e8:	00402025 	or	$4,$2,$0
  ec:	0c000000 	jal	0 <main>
  f0:	00000000 	sll	$0,$0,0x0
  f4:	00402025 	or	$4,$2,$0
  f8:	0c000000 	jal	0 <main>
  fc:	00000000 	sll	$0,$0,0x0
 100:	3c020000 	lui	$2,0x0
 104:	24430000 	addiu	$3,$2,0
 108:	8fc20020 	lw	$2,32($30)
 10c:	00621021 	addu	$2,$3,$2
 110:	90420000 	lbu	$2,0($2)
 114:	3042ff00 	andi	$2,$2,0xff00
 118:	00402025 	or	$4,$2,$0
 11c:	0c000000 	jal	0 <main>
 120:	00000000 	sll	$0,$0,0x0
 124:	00402025 	or	$4,$2,$0
 128:	0c000000 	jal	0 <main>
 12c:	00000000 	sll	$0,$0,0x0
 130:	24040020 	addiu	$4,$0,32
 134:	0c000000 	jal	0 <main>
 138:	00000000 	sll	$0,$0,0x0
 13c:	8fc20020 	lw	$2,32($30)
 140:	24420001 	addiu	$2,$2,1
 144:	afc20020 	sw	$2,32($30)
 148:	1000ffd6 	beqz	$0,a4 <main+0xa4>
 14c:	00000000 	sll	$0,$0,0x0
 150:	00000000 	sll	$0,$0,0x0
 154:	1000ffaf 	beqz	$0,14 <main+0x14>
 158:	00000000 	sll	$0,$0,0x0
 15c:	00000000 	sll	$0,$0,0x0
 160:	1000ffac 	beqz	$0,14 <main+0x14>
 164:	00000000 	sll	$0,$0,0x0
 168:	03c0e825 	or	$29,$30,$0
 16c:	8fbf0044 	lw	$31,68($29)
 170:	8fbe0040 	lw	$30,64($29)
 174:	27bd0048 	addiu	$29,$29,72
 178:	03e00008 	jr	$31
 17c:	00000000 	sll	$0,$0,0x0

Disassembly of section .debug_info:

00000000 <.debug_info>:
   0:	00000164 	0x164
   4:	00000004 	sllv	$0,$0,$0
   8:	01040000 	0x1040000
   c:	00000015 	0x15
  10:	00017604 	0x17604
  14:	00017f00 	sll	$15,$1,0x1c
  18:	00001800 	sll	$3,$0,0x0
	...
  24:	06010200 	bgez	$16,828 <packet+0x828>
  28:	000002a1 	0x2a1
  2c:	69050202 	0x69050202
  30:	03000002 	0x3000002
  34:	6e690504 	0x6e690504
  38:	08020074 	j	801d0 <packet+0x801d0>
  3c:	00025b05 	0x25b05
  40:	02390400 	0x2390400
  44:	2e020000 	sltiu	$2,$16,0
  48:	0000004c 	syscall	0x1
  4c:	1a080102 	0x1a080102
  50:	02000001 	movf	$0,$16,$fcc0
  54:	01520702 	0x1520702
  58:	04020000 	bltzl	$0,5c <.debug_info+0x5c>
  5c:	00020d07 	0x20d07
  60:	07080200 	tgei	$24,512
  64:	00000222 	0x222
  68:	38070402 	xori	$7,$0,0x402
  6c:	04000001 	bltz	$0,74 <.debug_info+0x74>
  70:	000000e5 	0xe5
  74:	007a0403 	0x7a0403
  78:	41050000 	0x41050000
  7c:	8a000000 	lwl	$0,0($16)
  80:	06000000 	bltz	$16,84 <.debug_info+0x84>
  84:	0000005a 	0x5a
  88:	65070005 	0x65070005
  8c:	05000001 	bltz	$8,94 <.debug_info+0x94>
  90:	00003304 	0x3304
  94:	cd090300 	pref	0x9,768($8)
  98:	08000000 	j	0 <.debug_info>
  9c:	00000241 	0x241
  a0:	00087898 	0x87898
  a4:	99000000 	lwr	$0,0($8)
  a8:	02730878 	0x2730878
  ac:	789a0000 	0x789a0000
  b0:	0000f608 	0xf608
  b4:	08789b00 	j	1e26c00 <packet+0x1e26c00>
  b8:	000002bb 	0x2bb
  bc:	8b08789c 	lwl	$8,30876($24)
  c0:	9d000002 	0x9d000002
  c4:	01280878 	0x1280878
  c8:	789e0000 	0x789e0000
  cc:	00410500 	0x410500
  d0:	00de0000 	0xde0000
  d4:	5a090000 	0x5a090000
  d8:	ff000000 	sdc3	$0,0($24)
  dc:	ef0a0007 	swc3	$10,7($24)
  e0:	01000000 	0x1000000
  e4:	0000cd05 	0xcd05
  e8:	00030500 	sll	$0,$3,0x14
  ec:	0b000000 	j	c000000 <packet+0xc000000>
  f0:	00000208 	0x208
  f4:	00330701 	0x330701
  f8:	00000000 	sll	$0,$0,0x0
  fc:	01800000 	0x1800000
 100:	9c010000 	0x9c010000
 104:	0002ad0c 	syscall	0xab4
 108:	33090100 	andi	$9,$24,0x100
 10c:	02000000 	0x2000000
 110:	000d5c91 	0xd5c91
 114:	0c000000 	jal	0 <.debug_info>
 118:	0000014a 	0x14a
 11c:	006f0c01 	0x6f0c01
 120:	91020000 	lbu	$2,0($8)
 124:	021a0c64 	0x21a0c64
 128:	0d010000 	jal	4040000 <packet+0x4040000>
 12c:	0000006f 	0x6f
 130:	0c6c9102 	jal	1b24408 <packet+0x1b24408>
 134:	00000111 	0x111
 138:	00330e01 	0x330e01
 13c:	91020000 	lbu	$2,0($8)
 140:	65720e74 	0x65720e74
 144:	0f010073 	jal	c0401cc <packet+0xc0401cc>
 148:	00000033 	tltu	$0,$0
 14c:	0f609102 	jal	d824408 <packet+0xd824408>
 150:	000000a0 	0xa0
 154:	000000b0 	tge	$0,$0,0x2
 158:	0100690e 	0x100690e
 15c:	00003324 	0x3324
 160:	58910200 	0x58910200
 164:	00000000 	sll	$0,$0,0x0

Disassembly of section .debug_abbrev:

00000000 <.debug_abbrev>:
   0:	25011101 	addiu	$1,$8,4353
   4:	030b130e 	0x30b130e
   8:	550e1b0e 	bnel	$8,$14,6c44 <packet+0x6c44>
   c:	10011117 	beq	$0,$1,446c <packet+0x446c>
  10:	02000017 	0x2000017
  14:	0b0b0024 	j	c2c0090 <packet+0xc2c0090>
  18:	0e030b3e 	jal	80c2cf8 <packet+0x80c2cf8>
  1c:	24030000 	addiu	$3,$0,0
  20:	3e0b0b00 	0x3e0b0b00
  24:	0008030b 	0x8030b
  28:	00160400 	sll	$0,$22,0x10
  2c:	0b3a0e03 	j	ce8380c <packet+0xce8380c>
  30:	13490b3b 	beq	$26,$9,2d20 <packet+0x2d20>
  34:	01050000 	0x1050000
  38:	01134901 	0x1134901
  3c:	06000013 	bltz	$16,8c <.debug_abbrev+0x8c>
  40:	13490021 	beq	$26,$9,c8 <packet+0xc8>
  44:	00000b2f 	0xb2f
  48:	03010407 	0x3010407
  4c:	0b0b3e0e 	j	c2cf838 <packet+0xc2cf838>
  50:	3a13490b 	xori	$19,$16,0x490b
  54:	010b3b0b 	0x10b3b0b
  58:	08000013 	j	4c <.debug_abbrev+0x4c>
  5c:	0e030028 	jal	80c00a0 <packet+0x80c00a0>
  60:	00000d1c 	0xd1c
  64:	49002109 	bc2f	848c <packet+0x848c>
  68:	00052f13 	0x52f13
  6c:	00340a00 	0x340a00
  70:	0b3a0e03 	j	ce8380c <packet+0xce8380c>
  74:	13490b3b 	beq	$26,$9,2d64 <packet+0x2d64>
  78:	1802193f 	0x1802193f
  7c:	2e0b0000 	sltiu	$11,$16,0
  80:	03193f01 	0x3193f01
  84:	3b0b3a0e 	xori	$11,$24,0x3a0e
  88:	1113490b 	beq	$8,$19,124b8 <packet+0x124b8>
  8c:	40061201 	0x40061201
  90:	19429618 	0x19429618
  94:	340c0000 	ori	$12,$0,0x0
  98:	3a0e0300 	xori	$14,$16,0x300
  9c:	490b3b0b 	bc2tl	$cc2,eccc <packet+0xeccc>
  a0:	00180213 	0x180213
  a4:	010b0d00 	0x10b0d00
  a8:	00001755 	0x1755
  ac:	0300340e 	0x300340e
  b0:	3b0b3a08 	xori	$11,$24,0x3a08
  b4:	0213490b 	0x213490b
  b8:	0f000018 	jal	c000060 <packet+0xc000060>
  bc:	0111010b 	0x111010b
  c0:	00000612 	0x612
	...

Disassembly of section .debug_aranges:

00000000 <.debug_aranges>:
   0:	0000001c 	0x1c
   4:	00000002 	srl	$0,$0,0x0
   8:	00040000 	sll	$0,$4,0x0
	...
  14:	00000180 	sll	$0,$0,0x6
	...

Disassembly of section .debug_ranges:

00000000 <.debug_ranges>:
   0:	00000014 	0x14
   4:	00000064 	0x64
   8:	0000006c 	0x6c
   c:	00000160 	0x160
	...
  1c:	00000180 	sll	$0,$0,0x6
	...

Disassembly of section .debug_line:

00000000 <.debug_line>:
   0:	000000a6 	0xa6
   4:	00670002 	0x670002
   8:	01010000 	0x1010000
   c:	000d0efb 	0xd0efb
  10:	01010101 	0x1010101
  14:	01000000 	0x1000000
  18:	2f010000 	sltiu	$1,$24,0
  1c:	2f727375 	sltiu	$18,$27,29557
  20:	2f62696c 	sltiu	$2,$27,26988
  24:	2d636367 	sltiu	$3,$11,25447
  28:	736f7263 	0x736f7263
  2c:	696d2f73 	0x696d2f73
  30:	6c2d7370 	0x6c2d7370
  34:	78756e69 	0x78756e69
  38:	756e672d 	jalx	5b99cb4 <packet+0x5b99cb4>
  3c:	692f372f 	0x692f372f
  40:	756c636e 	jalx	5b18db8 <packet+0x5b18db8>
  44:	00006564 	0x6564
  48:	6e69616d 	0x6e69616d
  4c:	7070632e 	0x7070632e
  50:	00000000 	sll	$0,$0,0x0
  54:	69647473 	0x69647473
  58:	672d746e 	0x672d746e
  5c:	682e6363 	0x682e6363
  60:	00000100 	sll	$0,$0,0x4
  64:	685f6174 	0x685f6174
  68:	682e6c61 	0x682e6c61
  6c:	00000000 	sll	$0,$0,0x0
  70:	02050000 	0x2050000
  74:	00000000 	sll	$0,$0,0x0
  78:	0250f319 	0x250f319
  7c:	1e031440 	0x1e031440
  80:	826603f2 	lb	$6,1010($19)
  84:	f8bfbcbc 	sdc2	$31,-17220($5)
  88:	01040200 	0x1040200
  8c:	08064a06 	j	192818 <packet+0x192818>
  90:	02bcf43e 	0x2bcf43e
  94:	3002132c 	andi	$2,$0,0x132c
  98:	ba780313 	swr	$24,787($19)
  9c:	3c087803 	lui	$8,0x7803
  a0:	4a0d03bf 	c2	0xd03bf
  a4:	00180283 	sra	$0,$24,0xa
  a8:	Address 0x00000000000000a8 is out of bounds.


Disassembly of section .debug_str:

00000000 <.debug_str>:
   0:	5f4c4148 	0x5f4c4148
   4:	5f525245 	0x5f525245
   8:	4e5f5049 	c3	0x5f5049
   c:	455f544f 	0x455f544f
  10:	54534958 	bnel	$2,$19,12574 <packet+0x12574>
  14:	554e4700 	bnel	$10,$14,11c18 <packet+0x11c18>
  18:	2b2b4320 	slti	$11,$25,17184
  1c:	37203131 	ori	$0,$25,0x3131
  20:	302e342e 	andi	$14,$1,0x342e
  24:	656d2d20 	0x656d2d20
  28:	6d2d206c 	0x6d2d206c
  2c:	676e6973 	0x676e6973
  30:	662d656c 	0x662d656c
  34:	74616f6c 	jalx	185bdb0 <packet+0x185bdb0>
  38:	786d2d20 	0x786d2d20
  3c:	20746f67 	addi	$20,$3,28519
  40:	6f6e6d2d 	0x6f6e6d2d
  44:	6962612d 	0x6962612d
  48:	6c6c6163 	0x6c6c6163
  4c:	6d2d2073 	0x6d2d2073
  50:	64726168 	0x64726168
  54:	6f6c662d 	0x6f6c662d
  58:	2d207461 	sltiu	$0,$9,29793
  5c:	7370696d 	0x7370696d
  60:	2d203233 	sltiu	$0,$9,12851
  64:	736c6c6d 	0x736c6c6d
  68:	6d2d2063 	0x6d2d2063
  6c:	6c2d6f6e 	0x6c2d6f6e
  70:	2d316378 	sltiu	$17,$9,25464
  74:	31637873 	andi	$3,$11,0x7873
  78:	6e6d2d20 	0x6e6d2d20
  7c:	68732d6f 	0x68732d6f
  80:	64657261 	0x64657261
  84:	616d2d20 	0x616d2d20
  88:	333d6962 	andi	$29,$25,0x6962
  8c:	672d2032 	0x672d2032
  90:	74732d20 	jalx	1ccb480 <packet+0x1ccb480>
  94:	2b633d64 	slti	$3,$27,15716
  98:	2031312b 	addi	$17,$1,12587
  9c:	7566662d 	jalx	59998b4 <packet+0x59998b4>
  a0:	6974636e 	0x6974636e
  a4:	732d6e6f 	0x732d6e6f
  a8:	69746365 	0x69746365
  ac:	20736e6f 	addi	$19,$3,28271
  b0:	6164662d 	0x6164662d
  b4:	732d6174 	0x732d6174
  b8:	69746365 	0x69746365
  bc:	20736e6f 	addi	$19,$3,28271
  c0:	7266662d 	0x7266662d
  c4:	74736565 	jalx	1cd9594 <packet+0x1cd9594>
  c8:	69646e61 	0x69646e61
  cc:	2d20676e 	sltiu	$0,$9,26478
  d0:	2d6f6e66 	sltiu	$15,$11,28262
  d4:	6c697562 	0x6c697562
  d8:	206e6974 	addi	$14,$3,26996
  dc:	6f6e662d 	0x6f6e662d
  e0:	4549502d 	0x4549502d
  e4:	63616d00 	0x63616d00
  e8:	72646461 	0x72646461
  ec:	7000745f 	0x7000745f
  f0:	656b6361 	0x656b6361
  f4:	41480074 	0x41480074
  f8:	52455f4c 	beql	$18,$5,17e2c <packet+0x17e2c>
  fc:	41435f52 	0x41435f52
 100:	44454c4c 	0x44454c4c
 104:	4645425f 	c1	0x45425f
 108:	5f45524f 	0x5f45524f
 10c:	54494e49 	bnel	$2,$9,13a34 <packet+0x13a34>
 110:	5f666900 	0x5f666900
 114:	65646e69 	0x65646e69
 118:	6e750078 	0x6e750078
 11c:	6e676973 	0x6e676973
 120:	63206465 	0x63206465
 124:	00726168 	0x726168
 128:	5f4c4148 	0x5f4c4148
 12c:	5f525245 	0x5f525245
 130:	4e4b4e55 	c3	0x4b4e55
 134:	004e574f 	0x4e574f
 138:	676e6f6c 	0x676e6f6c
 13c:	736e7520 	0x736e7520
 140:	656e6769 	0x656e6769
 144:	6e692064 	0x6e692064
 148:	72730074 	0x72730074
 14c:	616d5f63 	0x616d5f63
 150:	68730063 	0x68730063
 154:	2074726f 	addi	$20,$3,29295
 158:	69736e75 	0x69736e75
 15c:	64656e67 	0x64656e67
 160:	746e6920 	jalx	1b9a480 <packet+0x1b9a480>
 164:	4c414800 	cfc3	$1,$9
 168:	5252455f 	beql	$18,$18,116e8 <packet+0x116e8>
 16c:	4e5f524f 	c3	0x5f524f
 170:	45424d55 	0x45424d55
 174:	616d0052 	0x616d0052
 178:	632e6e69 	0x632e6e69
 17c:	2f007070 	sltiu	$0,$24,28784
 180:	2f746e6d 	sltiu	$20,$27,28269
 184:	73552f63 	0x73552f63
 188:	2f737265 	sltiu	$19,$27,29285
 18c:	616d616e 	0x616d616e
 190:	6f442f73 	0x6f442f73
 194:	656d7563 	0x656d7563
 198:	2f73746e 	sltiu	$19,$27,29806
 19c:	72756f43 	0x72756f43
 1a0:	322f6573 	andi	$15,$17,0x6573
 1a4:	41393130 	0x41393130
 1a8:	6d757475 	0x6d757475
 1ac:	724f2f6e 	0x724f2f6e
 1b0:	696e6167 	0x696e6167
 1b4:	6974617a 	0x6974617a
 1b8:	654e6e6f 	0x654e6e6f
 1bc:	726f7774 	0x726f7774
 1c0:	7078456b 	0x7078456b
 1c4:	6d697265 	0x6d697265
 1c8:	2f746e65 	sltiu	$20,$27,28261
 1cc:	31646f63 	andi	$4,$11,0x6f63
 1d0:	70726739 	0x70726739
 1d4:	68742f32 	0x68742f32
 1d8:	61706e69 	0x61706e69
 1dc:	6f745f64 	0x6f745f64
 1e0:	72732e70 	0x72732e70
 1e4:	732f7363 	0x732f7363
 1e8:	315f6d69 	andi	$31,$10,0x6d69
 1ec:	77656e2f 	jalx	d95b8bc <packet+0xd95b8bc>
 1f0:	63616d2f 	0x63616d2f
 1f4:	656e6968 	0x656e6968
 1f8:	646f632d 	0x646f632d
 1fc:	65672d65 	0x65672d65
 200:	6172656e 	0x6172656e
 204:	00726f74 	teq	$3,$18,0x1bd
 208:	6e69616d 	0x6e69616d
 20c:	736e7500 	0x736e7500
 210:	656e6769 	0x656e6769
 214:	6e692064 	0x6e692064
 218:	73640074 	0x73640074
 21c:	616d5f74 	0x616d5f74
 220:	6f6c0063 	0x6f6c0063
 224:	6c20676e 	0x6c20676e
 228:	20676e6f 	addi	$7,$3,28271
 22c:	69736e75 	0x69736e75
 230:	64656e67 	0x64656e67
 234:	746e6920 	jalx	1b9a480 <packet+0x1b9a480>
 238:	6e697500 	0x6e697500
 23c:	745f3874 	jalx	17ce1d0 <packet+0x17ce1d0>
 240:	4c414800 	cfc3	$1,$9
 244:	5252455f 	beql	$18,$18,117c4 <packet+0x117c4>
 248:	564e495f 	bnel	$18,$14,127c8 <packet+0x127c8>
 24c:	44494c41 	0x44494c41
 250:	5241505f 	beql	$18,$1,143d0 <packet+0x143d0>
 254:	54454d41 	bnel	$2,$5,1375c <packet+0x1375c>
 258:	6c005245 	0x6c005245
 25c:	20676e6f 	addi	$7,$3,28271
 260:	676e6f6c 	0x676e6f6c
 264:	746e6920 	jalx	1b9a480 <packet+0x1b9a480>
 268:	6f687300 	0x6f687300
 26c:	69207472 	0x69207472
 270:	4800746e 	0x4800746e
 274:	455f4c41 	0x455f4c41
 278:	495f5252 	0x495f5252
 27c:	45434146 	0x45434146
 280:	544f4e5f 	bnel	$2,$15,13c00 <packet+0x13c00>
 284:	4958455f 	0x4958455f
 288:	48005453 	0x48005453
 28c:	455f4c41 	0x455f4c41
 290:	4e5f5252 	c3	0x5f5252
 294:	535f544f 	beql	$26,$31,153d4 <packet+0x153d4>
 298:	4f505055 	c3	0x1505055
 29c:	44455452 	0x44455452
 2a0:	67697300 	0x67697300
 2a4:	2064656e 	addi	$4,$3,25966
 2a8:	72616863 	0x72616863
 2ac:	66756200 	0x66756200
 2b0:	5f726566 	0x5f726566
 2b4:	64616568 	0x64616568
 2b8:	48007265 	0x48007265
 2bc:	455f4c41 	0x455f4c41
 2c0:	455f5252 	0x455f5252
 2c4:	Address 0x00000000000002c4 is out of bounds.


Disassembly of section .comment:

00000000 <.comment>:
   0:	43434700 	c0	0x1434700
   4:	5528203a 	bnel	$9,$8,80f0 <packet+0x80f0>
   8:	746e7562 	jalx	1b9d588 <packet+0x1b9d588>
   c:	2e372075 	sltiu	$23,$17,8309
  10:	2d302e34 	sltiu	$16,$9,11828
  14:	75627531 	jalx	589d4c4 <packet+0x589d4c4>
  18:	3175746e 	andi	$21,$11,0x746e
  1c:	2e38317e 	sltiu	$24,$17,12670
  20:	312e3430 	andi	$14,$9,0x3430
  24:	2e372029 	sltiu	$23,$17,8233
  28:	00302e34 	teq	$1,$16,0xb8

Disassembly of section .eh_frame:

00000000 <.eh_frame>:
   0:	00000010 	mfhi	$0
   4:	00000000 	sll	$0,$0,0x0
   8:	00527a01 	0x527a01
   c:	011f7c01 	0x11f7c01
  10:	001d0d0b 	0x1d0d0b
  14:	00000024 	and	$0,$0,$0
  18:	00000018 	mult	$0,$0
  1c:	00000000 	sll	$0,$0,0x0
  20:	00000180 	sll	$0,$0,0x6
  24:	480e4400 	0x480e4400
  28:	9e019f48 	0x9e019f48
  2c:	1e0d4402 	0x1e0d4402
  30:	0d015c03 	jal	405700c <packet+0x405700c>
  34:	dfde4c1d 	ldc3	$30,19485($30)
  38:	0000000e 	0xe

Disassembly of section .gnu.attributes:

00000000 <.gnu.attributes>:
   0:	00000f41 	0xf41
   4:	756e6700 	jalx	5b99c00 <packet+0x5b99c00>
   8:	00070100 	sll	$0,$7,0x4
   c:	02040000 	0x2040000
