; EEPROM Programmer for AT28Cxx using PIC16F62x
;
; CAT28C256 supports 64-byte page-writes, but too fast
; for serial port; byte-writes need 5ms between writes
; which is too slow for serial port.

; RB4,RB5,RB6,RB7,RA6,RA7,RA0,RA1: DATA
; RB0; /WE
; RB1: RX
; RB2: TX
; RB3: /OE
; RA2: SHIFT CLOCK
; RA3: SHIFT LATCH
; RA4: SHIFT DATA (w/ pull-up)

	include "p16f628.inc"

	PROCESSOR P16F628
	config _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_OFF & _BODEN_ON & _INTRC_OSC_NOCLKOUT

MCLK		EQU	4000000
RATE		EQU	19200
BAUD		EQU	(MCLK / 16 / RATE) - 1	; for BRGH=1

SHCLK		EQU	2	; PORT A
SHLAT		EQU	3
SHDAT		EQU	4
PAMASK		EQU	0xC3

WE		EQU	0	; PORT B
RX		EQU	1
TX		EQU	2
OE		EQU	3
PBMASK		EQU	0xF0

TEMP		EQU	0x20
COUNT		EQU	0x21
PTRH		EQU	0x22
PTRL		EQU	0x23
BYTECNT		EQU	0x24	; WriteMemory loop

ROMMASK		EQU	0x26 ; mask is (1<<ROMTYPE) 32KB=0x80, 16KB=0x40, 8KB=0x20, 4KB=0x10, 2KB=0x08, 1KB=0x04
ROM1KB		EQU	2
ROM2KB		EQU	3
ROM4KB		EQU	4
ROM8KB		EQU	5
ROM16KB		EQU	6
ROM32KB		EQU	7

	ORG	0x0000
	GOTO	main

; keep tables in the first page
; W contains nibble
hex2asc:
	ADDWF	PCL,F
	.dt	0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x41,0x42,0x43,0x44,0x45,0x46
intros:
	.dt	"AT28C64 programmer (PIC16F62x)\r\n", 0
erases:
	.dt	"Erasing...\r\n", 0
unlocks:
	.dt	"Unlocking...\r\n", 0
dones:
	.dt	"done\r\n", 0
romtypes:
	.dt	"ROM type set to ", 0
kbs:
	.dt	"KB\r\n", 0
helps:
	.dt	"H=help, :=ihex write, E=erase, D=dump, U=unlock, T=toggle ROM type\r\n", 0

main:
	CLRF	PCLATH
	CLRF	STATUS

	BANKSEL	CMCON
	MOVLW	0x07		; disable comparators
	MOVWF	CMCON
	CLRF	CCP1CON		; disable capture/compare/pwm

	BANKSEL	TRISA
	CLRF	TRISA		; for output
	CLRF	TRISB		; for output

	BANKSEL	PORTA
	CLRF	PORTA
	CLRF	PORTB
	BSF	PORTB,OE	; disable WE and OE
	BSF	PORTB,WE

	CALL	init_uart

	MOVLW	high intros
	MOVWF	PTRH
	MOVLW	low intros
	MOVWF	PTRL
	CALL	puts

	MOVLW	(1<<ROM8KB)
	MOVWF	ROMMASK
	CALL	PrintRomType

loop:
	CALL	getc
	IORLW	0x20		; convert to lowercase

	MOVWF	TEMP
1:
	MOVF	TEMP,W
	XORLW	':'
	BTFSS	STATUS,Z
	GOTO	2f
	CALL	WriteMemory
	GOTO	loop
2:
	MOVF	TEMP,W
	XORLW	'e'
	BTFSS	STATUS,Z
	GOTO	3f
	CALL	EraseMemory
	GOTO	loop
3:
	MOVF	TEMP,W
	XORLW	'd'
	BTFSS	STATUS,Z
	GOTO	4f
	CALL	DumpMemory
	GOTO	loop
4:
	MOVF	TEMP,W
	XORLW	'h'
	BTFSS	STATUS,Z
	GOTO	5f
	CALL	Help
	GOTO	loop
5:
	MOVF	TEMP,W
	XORLW	'u'
	BTFSS	STATUS,Z
	GOTO	6f
	CALL	Unlock
	GOTO	loop
6:
	MOVF	TEMP,W
	XORLW	't'
	BTFSS	STATUS,Z
	GOTO	7f
	CALL	ToggleRomType
	GOTO	loop
7:
	GOTO	loop

Help:
	MOVLW	high intros
	MOVWF	PTRH
	MOVLW	low intros
	MOVWF	PTRL
	CALL	puts
	MOVLW	high helps
	MOVWF	PTRH
	MOVLW	low helps
	MOVWF	PTRL
	CALL	puts
	GOTO	PrintRomType
	; no return

ToggleRomType:
	BCF	STATUS,C
	RLF	ROMMASK,F
	MOVLW	(1<<ROM1KB)
	BTFSC	STATUS,C	; check if too big
	MOVWF	ROMMASK
	; fallthru

PrintRomType:

	MOVLW	high romtypes
	MOVWF	PTRH
	MOVLW	low romtypes
	MOVWF	PTRL
	CALL	puts

	MOVF	ROMMASK,W	; check if 1,2,4,8KB
	SUBLW	(1<<ROM8KB)
	BTFSC	STATUS,C
	GOTO	2f
	BTFSC	ROMMASK,ROM16KB	; check if 16KB
	MOVLW	0x16
	BTFSC	ROMMASK,ROM32KB	; check if 32KB
	MOVLW	0x32
	CALL	puthex
	GOTO	3f
2:
	MOVF	ROMMASK,W	; shift and use puthex
	MOVWF	TEMP
	BCF	STATUS,C
	RRF	TEMP,F
	RRF	TEMP,W
	CALL	hex2asc
	CALL	putc
3:
	MOVLW	high kbs
	MOVWF	PTRH
	MOVLW	low kbs
	MOVWF	PTRL
	CALL	puts
	RETURN

; unlocks CAT28C256 chips
Unlock:
	MOVLW	high unlocks
	MOVWF	PTRH
	MOVLW	low unlocks
	MOVWF	PTRL
	CALL	puts

	BANKSEL	TRISA		; setup port A for output
	CLRF	TRISA
	MOVLW	(1<<RX)		; setup port B for output
	MOVWF	TRISB
 	BANKSEL	PORTA
 
	MOVLW	0x55
	MOVWF	PTRH
	MOVWF	PTRL
	CALL	shiftaddr
	MOVLW	0xAA
	CALL	setdata
 	BCF	PORTB,WE	; write enable
 	BSF	PORTB,WE	; write disable

	MOVLW	0x2A
	MOVWF	PTRH
	MOVLW	0xAA
	MOVWF	PTRL
	CALL	shiftaddr
	MOVLW	0x55
	CALL	setdata
 	BCF	PORTB,WE	; write enable
 	BSF	PORTB,WE	; write disable

	MOVLW	0x55
	MOVWF	PTRH
	MOVWF	PTRL
	CALL	shiftaddr
	MOVLW	0x80
	CALL	setdata
 	BCF	PORTB,WE	; write enable
 	BSF	PORTB,WE	; write disable

	MOVLW	0x55
	MOVWF	PTRH
	MOVWF	PTRL
	CALL	shiftaddr
	MOVLW	0xAA
	CALL	setdata
 	BCF	PORTB,WE	; write enable
 	BSF	PORTB,WE	; write disable

	MOVLW	0x2A
	MOVWF	PTRH
	MOVLW	0xAA
	MOVWF	PTRL
	CALL	shiftaddr
	MOVLW	0x55
	CALL	setdata
 	BCF	PORTB,WE	; write enable
 	BSF	PORTB,WE	; write disable

	MOVLW	0x55
	MOVWF	PTRH
	MOVWF	PTRL
	CALL	shiftaddr
	MOVLW	0x20
	CALL	setdata
 	BCF	PORTB,WE	; write enable
 	BSF	PORTB,WE	; write disable

	MOVLW	high dones
	MOVWF	PTRH
	MOVLW	low dones
	MOVWF	PTRL
	CALL	puts

	RETURN

DumpMemory:
 	BANKSEL	TRISA		; setup port A for input
	MOVLW	PAMASK
	MOVWF	TRISA
	MOVLW	(1<<RX)|PBMASK	; setup port B for input
	MOVWF	TRISB
 	BANKSEL	PORTA
 
	CLRF	PTRH
	CLRF	PTRL
1:
	MOVF	PTRH,W
	CALL	puthex
	MOVF	PTRL,W
	CALL	puthex

	MOVLW	':'
	CALL	putc
	MOVLW	' '
	CALL	putc
2:
	CALL	shiftaddr	; shift out the address

 	BCF	PORTB,OE	; output enable
	CALL	getdata
	BSF	PORTB,OE	; output disable
 
	CALL	puthex

	INCF	PTRL,F
	BTFSC	STATUS,Z
	INCF	PTRH,F

	MOVF	PTRL,W
	ANDLW	0x0F
	BTFSS	STATUS,Z
	GOTO	2b

	MOVLW	'\r'
	CALL	putc
	MOVLW	'\n'
	CALL	putc

	; bail on keyboard hit
	BTFSC	PIR1,RCIF	; check for RX
	RETURN

	MOVF	PTRL,W
	BTFSS	STATUS,Z
	GOTO	1b
	MOVF	ROMMASK,W
	XORWF	PTRH,W
	BTFSS	STATUS,Z	; check if done
	GOTO	1b

	RETURN

WriteMemory:
	BANKSEL	TRISA		; setup port A for output
	CLRF	TRISA
	MOVLW	(1<<RX)		; setup port B for output
	MOVWF	TRISB
 	BANKSEL	PORTA
 
 	CALL	gethex		; number of bytes
	XORLW	0x00
	BTFSC	STATUS,Z
	GOTO	9f
	MOVWF	BYTECNT

	CALL	gethex		; address high
	MOVWF	PTRH

	CALL	gethex		; address low
	MOVWF	PTRL

	CALL	gethex		; type (must be zero)
	XORLW	0x00
	BTFSS	STATUS,Z
	GOTO	9f
1:
 	CALL	shiftaddr	; shift out the address
 	CALL	gethex
	CALL	setdata		; leaves PORTA in W
 	BCF	PORTB,WE	; write enable
 	BSF	PORTB,WE	; write disable
 
	; delaying will cause the UART to overrun
	; hopefully the UART isn't running greater than 19200
	; - CAT28C256 requires 5ms...
;	CALL	delay
	CALL	wait_for_write	; W=PORTA output

	INCF	PTRL,F
	BTFSC	STATUS,Z
	INCF	PTRH,F

	DECFSZ	BYTECNT,F
	GOTO	1b
9:
	CALL	getc
	XORLW	'\r'
	BTFSS	STATUS,Z
	GOTO	9b

	MOVLW	'.'
	CALL	putc

	RETURN

EraseMemory:
	MOVLW	high erases
	MOVWF	PTRH
	MOVLW	low erases
	MOVWF	PTRL
	CALL	puts

	BANKSEL	TRISA		; setup port A for output
	CLRF	TRISA
	MOVLW	(1<<RX)		; setup port B for output
	MOVWF	TRISB
 	BANKSEL	PORTA
 
	CLRF	PTRH
	CLRF	PTRL
1:
	CALL	shiftaddr	; shift out the address

	MOVLW	(1<<OE)|(1<<WE)|(1<<RX)|PBMASK
	MOVWF	PORTB
	MOVLW	PAMASK		; write the data (0xFF)
	MOVWF	PORTA

	BCF	PORTB,WE	; write enable
	BSF	PORTB,WE	; write disable
;	CALL	delay
	CALL	wait_for_write	; W=PORTA output

	INCF	PTRL,F
	BTFSS	STATUS,Z
	GOTO	1b
	INCF	PTRH,F

	; bail on keyboard hit
	BTFSC	PIR1,RCIF	; check for RX
	RETURN

	; print progress
	MOVF	PTRH,W
	CALL	puthex
	MOVF	PTRL,W
	CALL	puthex
	MOVLW	'\r'
	CALL	putc

	MOVF	ROMMASK,W
	XORWF	PTRH,W
	BTFSS	STATUS,Z	; check if done
	GOTO	1b

	MOVLW	high dones
	MOVWF	PTRH
	MOVLW	low dones
	MOVWF	PTRL
	CALL	puts

	RETURN

; /data polling on D7 -> PA1
wait_for_write
	MOVWF	TEMP
 	BANKSEL	TRISA		; setup port A for input
	MOVLW	PAMASK
	MOVWF	TRISA
 	BANKSEL	PORTA
1:
 	BCF	PORTB,OE	; output enable
	MOVF	PORTA,W
	BSF	PORTB,OE	; output disable
	XORWF	TEMP,W
	ANDLW	2		; mask off PA1
	BTFSS	STATUS,Z
	GOTO	1b
	BANKSEL	TRISA		; setup port A for output
	CLRF	TRISA
 	BANKSEL	PORTA
	RETURN

; 1ms - AT28C64, 5ms - CAT28C256
delay:
	BTFSC	ROMMASK,ROM32KB
	GOTO	delay5
	; fall-through
; delay 1ms
delay1:						; 2
	MOVLW	MCLK / 4 / 1000 / 4 - 1		; 1
1:
	ADDLW	-1				; 1
	BTFSC	STATUS,C			; 1
	GOTO	1b				; 2
	RETURN					; 2
; delay (more than) 5ms
delay5:
	CALL delay1
	CALL delay1
	CALL delay1
	CALL delay1
	CALL delay1	; CAT28C256 seem to need more
	CALL delay1
	CALL delay1
	CALL delay1
	RETURN

; W contains byte
shiftbyte:
	MOVWF	TEMP
	MOVLW	0x08
	MOVWF	COUNT
1:
	RLF	TEMP,F
	BTFSC	STATUS,C
	BSF	PORTA,SHDAT		; set bit
	BTFSS	STATUS,C
	BCF	PORTA,SHDAT		; or clear bit
	BSF	PORTA,SHCLK		; strobe clock
	BCF	PORTA,SHCLK	
	DECFSZ	COUNT,F
	GOTO	1b
	RETURN

; PTRH:PTRL contains address
shiftaddr:
	MOVF	PTRH,W
	CALL	shiftbyte
	MOVF	PTRL,W
	CALL	shiftbyte
	BSF	PORTA,SHLAT		; latch
	BCF	PORTA,SHLAT
	RETURN

init_uart:
	BANKSEL	TRISB
	BSF	TRISB,RX		; RX for input
	BCF	TRISB,TX		; TX for output

	MOVLW	BAUD
	MOVWF	SPBRG

	; enable UART tx, 8-bit, async, high-speed internal baud-rate generator
	MOVLW	(1<<TXEN)|(1<<BRGH)
	MOVWF	TXSTA

	BANKSEL	RCSTA
	; enable UART rx, 8-bit, continuous-receive mode
	MOVLW	(1<<SPEN) | (1<<CREN)
	MOVWF	RCSTA
	RETURN

setdata:
	MOVWF	TEMP
	SWAPF	TEMP,W
	ANDLW	PBMASK
	IORLW	(1<<RX)|(1<<OE)|(1<<WE)
	MOVWF	PORTB		; write the low nibble
	RRF	TEMP,F
	RRF	TEMP,F
	SWAPF	TEMP,W
	ANDLW	PAMASK
	MOVWF	PORTA		; write the high nibble
	RETURN

getdata:
	SWAPF	PORTA,W		; read data on PORT A
	ANDLW	(~PAMASK&0xFF)
	MOVWF	TEMP
	BCF	STATUS,C
	RLF	TEMP,F
	RLF	TEMP,F
	SWAPF	PORTB,W		; read data on PORT B
	ANDLW	(~PBMASK&0xFF)
	IORWF	TEMP,W
	RETURN
 
getc:
	BTFSS	PIR1,RCIF	; check for RX
	GOTO	getc
	MOVF	RCREG,W		; receive byte
	BTFSS	RCSTA,OERR	; check if overrun
	RETURN
	BCF	RCSTA,CREN	; clear overrun
	BSF	RCSTA,CREN	; enable continuous
	RETURN

putc:
	BTFSS	PIR1,TXIF	; wait for previous transmit to complete
	GOTO	putc
	MOVWF	TXREG		; transmit byte
	RETURN

; PTRH:PTRL contains pointer to table entry
lookupTBL:
	MOVF	PTRH,W
	MOVWF	PCLATH
	MOVF	PTRL,W
	MOVWF	PCL

; PTRH:PTRL contains pointer to string
puts:
	CALL	lookupTBL
	XORLW	0x00
	BTFSC	STATUS,Z	; Z=1, if the two values are equal
	RETURN
	CALL	putc
	INCF	PTRL,F
	BTFSC	STATUS,Z
	INCF	PTRH,F
	GOTO	puts

; W contains byte value
; retains W (useful for debugging)
puthex:
	MOVWF	TEMP
	SWAPF	TEMP,W
	ANDLW	0x0F
	CALL	hex2asc
	CALL	putc
	MOVF	TEMP,W
	ANDLW	0x0F
	CALL	hex2asc
	CALL	putc
	MOVF	TEMP,W
	RETURN

; W contains byte value
gethex:
	CALL	getc
	IORLW	0x20			; convert to lowercase
	SUBLW	('a' - 1)		; 'a' - 1 - W
	BTFSS	STATUS,C
	ADDLW	('a' - '0' - 10)	; correct
	SUBLW	('a' - 1 - '0')
	MOVWF	TEMP

	CALL	getc
	IORLW	0x20
	SUBLW	('a' - 1)
	BTFSS	STATUS,C
	ADDLW	('a' - '0' - 10)
	SUBLW	('a' - 1 - '0')

	SWAPF	TEMP,F
	IORWF	TEMP,W
	RETURN

	END
