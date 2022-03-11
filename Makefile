all:	prog.hex

clean:
	$(RM) *.hex *.cod *.lst

.SUFFIXES:	.asm .hex

.asm.hex:
	pasm-pic -F hex -o $@ $<
