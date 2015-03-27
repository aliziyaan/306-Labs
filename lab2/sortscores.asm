		.ORIG x3000
		AND R1, R1, #0 ;Zero out R1
		LD R0, PTR1 ;Load pointer1 into R0
		LD R6, MASK1 ;Load mask1 into R6
		LD R7, MASK2 ;Load mask2 into R7
OUTL	LDR R2, R0, #0 ;Load contents of address in R0 into R2
		AND R4, R2, R7 ;AND R2 with R7 to check if sentinel
		BRz RANGE ;Check for sentinel
		ADD R1, R0, #1 ;Add 1 to R0 to get pointer2
INLO	LDR R3, R1, #0
		AND R4, R3, R7
		BRz PINC
		LDR R2, R0, #0
		AND R4, R2, R6
		AND R5, R3, R6
		NOT R5, R5
		ADD R5, R5, #1
		ADD R5, R5, R4
		BRzp NOSWAP
		STR R3, R0, #0
		STR R2, R1, #0
NOSWAP	ADD R1, R1, #1
		BR INLO
PINC	ADD R0, R0, #1
		BR OUTL
RANGE	ADD R1, R1, #0 ;initialize R1 to check if neg
		BRz NEG
		LDR R4, R0, #-1
		AND R4, R4, R6
		LD R5, PTR1
		LDR R5, R5, #0
		AND R5, R5, R6
		NOT R4, R4
		ADD R4, R4, #1
		ADD R5, R5, R4
		LD R2, RANG
		STR R5, R2, #0
		BR DONE
NEG		LD R2, RANG
		LD R3, RAN1
		STR R3, R2, #0
DONE	TRAP x25
PTR1	.FILL x3200
MASK1	.FILL x00FF
MASK2	.FILL xFF00
RANG 	.FILL x3300
RAN1	.FILL xFFFF
.END
