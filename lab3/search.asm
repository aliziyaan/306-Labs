	.ORIG x3000
	LEA R0, PROMPT
	PUTS
	JSR READINPUT
	LD R1, NODE1
	LEA R2, INPUT
	JSR SEARCH
	ADD R6, R6, #0
	BRp YES
	LEA R0, NOREPLY
	PUTS
	BRnzp AHA
YES	ADD R1, R1, #2
	LDR R0, R1, #0
	PUTS
AHA	HALT
;--------------------------------------------------------------------------------
READINPUT	ST R7, SAVER7
			LD R4, ENTER
			NOT R4, R4
			ADD R4, R4, #1
			LEA R2, INPUT
AGAIN1		GETC
			OUT
			ADD R3, R0, R4
			BRz DONE1
			STR R0, R2, #0
			ADD R2, R2, #1
			BRnzp AGAIN1
DONE1		AND R1, R1, #0
			STR R1, R2, #0
			LD R7, SAVER7
			RET
;--------------------------------------------------------------------------------
SEARCH		AND R6, R6, #0
			LDR R1, R1, #0
			ADD R1, R1, #0
			BRz NOTFOUND
NEXTNODE	ADD R3, R1, #1
			LDR R4, R3, #0
			LEA R2, INPUT
AGAIN2		LDR R0, R4, #0
			BRz NULL
			LDR R5, R2, #0
			BRz NOMATCH
			NOT R0, R0
			ADD R0, R0,#1
			ADD R0, R5, R0
			BRnp NOMATCH
			ADD R4, R4, #1
			ADD R2, R2, #1
			BRnzp AGAIN2
NULL		LDR R5, R2, #0
			BRz FOUND
NOMATCH		LDR R1, R1, #0
			BRnp NEXTNODE
			ADD R1, R1, #0
			BRz NOTFOUND
FOUND		ADD R6, R6, #1
			BRnzp DONE2
NOTFOUND	AND R6, R6, #0
DONE2		RET
;--------------------------------------------------------------------------------
NODE1	.FILL X3300
INPUT	.BLKW 16
PROMPT	.STRINGZ "Type a last name and press Enter:"
NOREPLY	.STRINGZ "Not Registered"
ENTER	.FILL x000D
SAVER7	.BLKW 1
.END