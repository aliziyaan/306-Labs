;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	description: 	Connect 4 game!				;
;			EE 306 - Spring 2013			;
;			Programming Assignment #4 Solution	;
; 								;
;	file:		connect4.asm				;
;	author:		Birgi Tamersoy				;
;	date:		04/09/2013				;
;		update:	04/10/2013 -> finished & tested.	;
;		update: 04/12/2013 -> re-arranged for students.	;
;				   -> added 2nd dia. check.	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ORIG x3000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Main Program						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JSR INIT
ROUND
	JSR DISPLAY_BOARD
	JSR GET_MOVE
	JSR UPDATE_BOARD
	JSR UPDATE_STATE

	ADD R6, R6, #0
	BRz ROUND

	JSR DISPLAY_BOARD
	JSR GAME_OVER

	HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Functions & Constants!!!				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_TURN						;
;	description:	Displays the appropriate prompt.	;
;	inputs:		None!					;
;	outputs:	None!					;
;	assumptions:	TURN is set appropriately!		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_TURN
	ST R0, DT_R0
	ST R7, DT_R7

	LD R0, TURN
	ADD R0, R0, #-1
	BRp DT_P2
	LEA R0, DT_P1_PROMPT
	PUTS
	BRnzp DT_DONE
DT_P2
	LEA R0, DT_P2_PROMPT
	PUTS

DT_DONE

	LD R0, DT_R0
	LD R7, DT_R7

	RET
DT_P1_PROMPT	.stringz 	"Player 1, choose a column: "
DT_P2_PROMPT	.stringz	"Player 2, choose a column: "
DT_R0		.blkw	1
DT_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GET_MOVE						;
;	description:	gets a column from the user.		;
;			also checks whether the move is valid,	;
;			or not, by calling the CHECK_VALID 	;
;			subroutine!				;
;	inputs:		None!					;
;	outputs:	R6 has the user entered column number!	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GET_MOVE
	ST R0, GM_R0
	ST R7, GM_R7

GM_REPEAT
	JSR DISPLAY_TURN
	GETC
	OUT
	JSR CHECK_VALID
	LD R0, ASCII_NEWLINE
	OUT

	ADD R6, R6, #0
	BRp GM_VALID

	LEA R0, GM_INVALID_PROMPT
	PUTS
	LD R0, ASCII_NEWLINE
	OUT
	BRnzp GM_REPEAT

GM_VALID

	LD R0, GM_R0
	LD R7, GM_R7

	RET
GM_INVALID_PROMPT 	.stringz "Invalid move. Try again."
GM_R0			.blkw	1
GM_R7			.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_BOARD						;
;	description:	updates the game board with the last 	;
;			move!					;
;	inputs:		R6 has the column for last move.	;
;	outputs:	R5 has the row for last move.		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_BOARD
	ST R1, UP_R1
	ST R2, UP_R2
	ST R3, UP_R3
	ST R4, UP_R4
	ST R6, UP_R6
	ST R7, UP_R7

	; clear R5
	AND R5, R5, #0
	ADD R5, R5, #6

	LEA R4, ROW6
	
UB_NEXT_LEVEL
	ADD R3, R4, R6

	LDR R1, R3, #-1
	LD R2, ASCII_NEGHYP

	ADD R1, R1, R2
	BRz UB_LEVEL_FOUND

	ADD R4, R4, #-7
	ADD R5, R5, #-1
	BRnzp UB_NEXT_LEVEL

UB_LEVEL_FOUND
	LD R4, TURN
	ADD R4, R4, #-1
	BRp UB_P2

	LD R4, ASCII_O
	STR R4, R3, #-1

	BRnzp UB_DONE
UB_P2
	LD R4, ASCII_X
	STR R4, R3, #-1

UB_DONE		

	LD R1, UP_R1
	LD R2, UP_R2
	LD R3, UP_R3
	LD R4, UP_R4
	LD R6, UP_R6
	LD R7, UP_R7

	RET
ASCII_X	.fill	x0058
ASCII_O	.fill	x004f
UP_R1	.blkw	1
UP_R2	.blkw	1
UP_R3	.blkw	1
UP_R4	.blkw	1
UP_R5	.blkw	1
UP_R6	.blkw	1
UP_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHANGE_TURN						;
;	description:	changes the turn by updating TURN!	;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHANGE_TURN
	ST R0, CT_R0
	ST R1, CT_R1
	ST R7, CT_R7

	LD R0, TURN
	ADD R1, R0, #-1
	BRz CT_TURN_P2

	ST R1, TURN
	BRnzp CT_DONE

CT_TURN_P2
	ADD R0, R0, #1
	ST R0, TURN

CT_DONE
	LD R0, CT_R0
	LD R1, CT_R1
	LD R7, CT_R7

	RET
CT_R0	.blkw	1
CT_R1	.blkw	1
CT_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_WINNER						;
;	description:	checks if the last move resulted in a	;
;			win or not!				;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNER
	ST R5, CW_R5
	ST R6, CW_R6
	ST R7, CW_R7

	AND R4, R4, #0
	
	JSR CHECK_HORIZONTAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_VERTICAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_DIAGONALS

CW_DONE

	LD R5, CW_R5
	LD R6, CW_R6
	LD R7, CW_R7

	RET
CW_R5	.blkw	1
CW_R6	.blkw	1
CW_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_STATE						;
;	description:	updates the state of the game by 	;
;			checking the board. i.e. tries to figure;
;			out whether the last move ended the game;
; 			or not! if not updates the TURN! also	;
;			updates the WINNER if there is a winner!;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R6 has  1, if the game is over,		;
;				0, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_STATE
	ST R0, US_R0
	ST R1, US_R1
	ST R4, US_R4
	ST R7, US_R7
	
	; checking if the last move resulted in a win or not!
	JSR CHECK_WINNER
	
	ADD R4, R4, #0
	BRp US_OVER
	
	; checking if the board is full or not!
	AND R6, R6, #0
		
	LD R0, NBR_FILLED
	ADD R0, R0, #1
	ST R0, NBR_FILLED

	LD R1, MAX_FILLED
	ADD R1, R0, R1
	BRz US_TIE

US_NOT_OVER
	JSR CHANGE_TURN
	BRnzp US_DONE

US_OVER
	ADD R6, R6, #1
	LD R0, TURN
	ST R0, WINNER
	BRnzp US_DONE

US_TIE
	ADD R6, R6, #1

US_DONE
	LD R0, US_R0
	LD R1, US_R1
	LD R4, US_R4
	LD R7, US_R7

	RET
NBR_FILLED	.fill	#0
MAX_FILLED	.fill	#-36
US_R0		.blkw	1
US_R1		.blkw	1
US_R4		.blkw	1
US_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	INIT							;
;	description:	simply sets the BOARD_PTR appropriately!;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT
	ST R0, I_R0
	ST R7, I_R7

	LEA R0, ROW1
	ST R0, BOARD_PTR

	LD R0, I_R0
	LD R7, I_R7

	RET
I_R0	.blkw	1
I_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Global Constants!!!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCII_SPACE	.fill		x0020				;
ASCII_NEWLINE	.fill		x000A				;
TURN		.fill		1				;
WINNER		.fill		0				;
								;
ASCII_OFFSET	.fill		x-0030				;
ASCII_NEGONE	.fill		x-0031				;
ASCII_NEGSIX	.fill		x-0036				;
ASCII_NEGHYP	.fill	 	x-002d				;
								;
ROW1		.stringz	"------"			;
ROW2		.stringz	"------"			;
ROW3		.stringz	"------"			;
ROW4		.stringz	"------"			;
ROW5		.stringz	"------"			;
ROW6		.stringz	"------"			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;DO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;CHANGE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ANYTHING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ABOVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;THIS!!!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_BOARD						;
;	description:	Displays the board.			;
;	inputs:		None!					;
;	outputs:	None!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_BOARD
	
	ST R7, SAVER7
	ST R0, SAVER0
	ST R1, SAVER1
	ST R2, SAVER2

	LEA R1, ROW1
LP1	LDR R0, R1, #0
	BRz N1
	OUT
	LD R0, ASCII_SPACE
	OUT
	ADD R1, R1, #1
	BR LP1
N1	LD R0, ENT
	OUT
	BR RW2

RW2	LEA R1, ROW2
LP2	LDR R0, R1, #0
	BRz N2
	OUT
	LD R0, ASCII_SPACE
	OUT
	ADD R1, R1, #1
	BR LP2
N2	LD R0, ENT
	OUT
	BR RW3
	
RW3	LEA R1, ROW3
LP3	LDR R0, R1, #0
	BRz N3
	OUT
	LD R0, ASCII_SPACE
	OUT
	ADD R1, R1, #1
	BR LP3
N3	LD R0, ENT
	OUT
	BR RW4

RW4	LEA R1, ROW4
LP4	LDR R0, R1, #0
	BRz N4
	OUT
	LD R0, ASCII_SPACE
	OUT
	ADD R1, R1, #1
	BR LP4
N4	LD R0, ENT
	OUT
	BR RW5

RW5	LEA R1, ROW5
LP5	LDR R0, R1, #0
	BRz N5
	OUT
	LD R0, ASCII_SPACE
	OUT
	ADD R1, R1, #1
	BR LP5
N5	LD R0, ENT
	OUT
	BR RW6

RW6	LEA R1, ROW6
LP6	LDR R0, R1, #0
	BRz N6
	OUT
	LD R0, ASCII_SPACE
	OUT
	ADD R1, R1, #1
	BR LP6
N6	LD R0, ENT
	OUT
	BR D1

D1	LD R7, SAVER7
	LD R0, SAVER0
	LD R1, SAVER1
	LD R2, SAVER2

	RET

SAVER7	.BLKW 1
SAVER0	.BLKW 1
SAVER2	.BLKW 1
SAVER1	.BLKW 1
ENT 	.FILL x000D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GAME_OVER						;
;	description:	checks WINNER and outputs the proper	;
;			message!				;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GAME_OVER
    ;

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VALID						;
;	description:	checks whether a move is valid or not!	;
;	inputs:		R0 has the ASCII value of the move!	;
;	outputs:	R6 has:	0, if invalid move,		;
;				decimal col. val., if valid.    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VALID

	ST R1, SVE_R1
	ST R2, SVE_R2
	ST R3, SVE_R3

	ADD R0, R0, #0
	BRz INV
	LD R1, NG30
	ADD R1, R0, R1
	BRz INV

	ADD R2, R1, #-1
	LEA R3, ROW1
	ADD R2, R3, R2
	LDR R2, R2, #0
	LD R3, ASCII_NEGHYP
	ADD R2, R3, R2
	BRnp INV
	
	LD R2, NG1
	ADD R3, R1, R2
	BRz FND
	
	LD R2, NG2
	ADD R3, R1, R2
	BRz FND

	LD R2, NG3
	ADD R3, R1, R2
	BRz FND

	LD R2, NG4
	ADD R3, R1, R2
	BRz FND
	
	LD R2, NG5
	ADD R3, R1, R2
	BRz FND

	LD R2, NG6
	ADD R3, R1, R2
	BRz FND

	BR INV

INV AND R6, R6, #0
	BR DNE

FND AND R6, R6, #0
	ADD R6, R6, R1
	BR DNE

DNE LD R1, SVE_R1
	LD R2, SVE_R2
	LD R3, SVE_R3

	RET

SVE_R1	.BLKW 1
SVE_R2	.BLKW 1
SVE_R3	.BLKW 1
NG30	.FILL x-30
NG1		.FILL x-1
NG2		.FILL x-2
NG3 	.FILL x-3
NG4		.FILL x-4
NG5		.FILL x-5
NG6		.FILL x-6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;USE THE FOLLOWING TO ACCESS THE BOARD!!!;;;;;;;;;;;;;;;;;;
;;;;;IT POINTS TO THE FIRST ELEMENT OF ROW1 (TOP-MOST ROW)!!!;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BOARD_PTR	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GIMME_OFFSET_ASCII					;
;	description:	calculates offset and fetches ascii value.	;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R2 has ascii value from the input grid.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GIMME_OFFSET_ASCII

		ST R1, S_VER1
		ST R3, S_VER3
		ST R4, S_VER4

		AND R2, R2, #0

		LD R1, NG1
		ADD R1, R5, R1
		BRnp FML1
		ADD R2, R2, #0
		ADD R3, R6, #-1
		ADD R2, R3, R2
		BR D_NE

FML1	LD R1, NG2
		ADD R1, R5, R1
		BRnp FML2
		ADD R2, R2, #7
		ADD R3, R6, #-1
		ADD R2, R3, R2
		BR D_NE

FML2	LD R1, NG3
		ADD R1, R5, R1
		BRnp FML3
		ADD R2, R2, #14
		ADD R3, R6, #-1
		ADD R2, R3, R2
		BR D_NE

FML3	LD R1, NG4
		ADD R1, R5, R1
		BRnp FML4
		LD R4, NUM21
		ADD R2, R2, R4
		ADD R3, R6, #-1
		ADD R2, R3, R2
		BR D_NE

FML4	LD R1, NG5
		ADD R1, R5, R1
		BRnp FML5
		LD R4, NUM28
		ADD R2, R2, R4
		ADD R3, R6, #-1
		ADD R2, R3, R2
		BR D_NE						

FML5	LD R1, NG6
		ADD R1, R5, R1
		LD R4, NUM35
		ADD R2, R2, R4
		ADD R3, R6, #-1
		ADD R2, R3, R2
		BR D_NE

D_NE 	LD R3, BOARD_PTR
		ADD R2, R3, R2
		LDR R2, R2, #0

		LD R1, S_VER1
		LD R3, S_VER3
		LD R4, S_VER4

	RET

S_VER1	.BLKW 1
S_VER3 	.BLKW 1
S_VER4	.BLKW 1
NUM21	.FILL #21
NUM28	.FILL #28
NUM35	.FILL #35

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_HORIZONTAL					;
;	description:	horizontal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_HORIZONTAL

		ST R7, SAV_R7
		ST R0, SAV_R0
		ST R1, SAV_R1
		ST R2, SAV_R2
		ST R3, SAV_R3
		ST R5, SAV_R5
		ST R6, SAV_R6

		JSR GIMME_OFFSET_ASCII
		AND R0, R0, #0
		AND R3, R3, #0
		ADD R3, R3, R2
		NOT R3, R3
		ADD R3, R3, #1
		ADD R0, R0, #1
		AND R1, R1, #0
		ADD R1, R1, R6
		AND R4, R4, #0

GAB		ADD R6, R6, #1
		AND R7, R7, #0
		ADD R7, R7, #-7
		ADD R7, R6, R7
		BRzp LEFT
		JSR GIMME_OFFSET_ASCII
		ADD R2, R3, R2
		BRnp LEFT
		ADD R0, R0, #1
		AND R7, R7, #0
		ADD R7, R7, #-4
		ADD R7, R0, R7
		BRz WM
		BR GAB

LEFT	ADD R1, R1, #-1
		BRz NM
		ADD R6, R1, #0
		JSR GIMME_OFFSET_ASCII
		ADD R2, R3, R2
		BRnp NM
		ADD R0, R0, #1
		AND R7, R7, #0
		ADD R7, R7, #-4
		ADD R7, R0, R7
		BRz WM
		BR LEFT

WM		ADD R4, R4, #1
		BR WOO

NM		AND R4, R4, #0
		BR WOO

WOO		LD R7, SAV_R7
		LD R0, SAV_R0
		LD R1, SAV_R1
		LD R2, SAV_R2
		LD R3, SAV_R3
		LD R5, SAV_R5
		LD R6, SAV_R6			

		RET

SAV_R7	.BLKW 1
SAV_R0	.BLKW 1
SAV_R1	.BLKW 1
SAV_R2	.BLKW 1
SAV_R3	.BLKW 1		
SAV_R5	.BLKW 1
SAV_R6	.BLKW 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VERTICAL						;
;	description:	vertical check.				;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VERTICAL

		ST R7, SAV_R7
		ST R0, SAV_R0
		ST R1, SAV_R1
		ST R2, SAV_R2
		ST R3, SAV_R3
		ST R5, SAV_R5
		ST R6, SAV_R6

		JSR GIMME_OFFSET_ASCII
		ADD R3, R2, #0
		NOT R3, R3
		ADD R3, R3, #1
		AND R0, R0, #0
		AND R7, R7, #0
		AND R1, R1, #0
		ADD R0, R0, #1
		ADD R1, R1, R7

GRB		ADD R5, R5, #1
		AND R7, R7, #0
		ADD R7, R7, #-7
		ADD R7, R5, R7
		BRzp NFM
		JSR GIMME_OFFSET_ASCII
		ADD R2, R3, R2
		BRnp NFM
		ADD R0, R0, #1
		AND R7, R7, #0
		ADD R7, R7, #-4
		ADD R7, R0, R7
		BRz WFM
		BR GRB

NFM		AND R4, R4, #0
		BR HOO

WFM		AND R4, R4, #0
		ADD R4, R4, #1
		BR HOO

HOO		LD R7, SAV_R7
		LD R0, SAV_R0
		LD R1, SAV_R1
		LD R2, SAV_R2
		LD R3, SAV_R3
		LD R5, SAV_R5
		LD R6, SAV_R6	
	
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_DIAGONALS						;
;	description:	checks diagonals by calling 		;
;			CHECK_D1 & CHECK_D2.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DIAGONALS

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D1						;
;	description:	1st diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D1	

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D2						;
;	description:	2nd diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D2	

	RET


.END