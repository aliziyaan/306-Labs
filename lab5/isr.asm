.orig x2000
st r0, saver0
st r1, saver1
st r2, saver2
st r3, saver3

add r3, r3, #10
ld r0, bdr
ldr r0, r0, #0

poll	ldi r1, dsr
brzp poll
sti r0, ddr
add r3, r3, #-1
brnp poll

ld r0, saver0
ld r1, saver1
ld r2, saver2
ld r3, saver3

rti

bdr	.fill xfe02
dsr	.fill xfe04
ddr	.fill xfe06
saver0	.blkw 1
saver1	.blkw 1
saver2	.blkw 1
saver3	.blkw 1

.end
