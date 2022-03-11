;----- Register Files -----------------------------------------------------

INDF                         EQU     0x0000
TMR0                         EQU     0x0001
PCL                          EQU     0x0002
STATUS                       EQU     0x0003
FSR                          EQU     0x0004
PORTA                        EQU     0x0005
PORTB                        EQU     0x0006
PCLATH                       EQU     0x000A
INTCON                       EQU     0x000B
PIR1                         EQU     0x000C
TMR1L                        EQU     0x000E
TMR1H                        EQU     0x000F
T1CON                        EQU     0x0010
TMR2                         EQU     0x0011
T2CON                        EQU     0x0012
CCPR1L                       EQU     0x0015
CCPR1H                       EQU     0x0016
CCP1CON                      EQU     0x0017
RCSTA                        EQU     0x0018
TXREG                        EQU     0x0019
RCREG                        EQU     0x001A
CMCON                        EQU     0x001F

OPTION_REG                   EQU     0x0081
TRISA                        EQU     0x0085
TRISB                        EQU     0x0086
PIE1                         EQU     0x008C
PCON                         EQU     0x008E
PR2                          EQU     0x0092
TXSTA                        EQU     0x0098
SPBRG                        EQU     0x0099
EEDATA                       EQU     0x009A
EEADR                        EQU     0x009B
EECON1                       EQU     0x009C
EECON2                       EQU     0x009D
VRCON                        EQU     0x009F

;----- STATUS Bits --------------------------------------------------------

IRP                          EQU     0x0007
RP1                          EQU     0x0006
RP0                          EQU     0x0005
NOT_TO                       EQU     0x0004
NOT_PD                       EQU     0x0003
Z                            EQU     0x0002
DC                           EQU     0x0001
C                            EQU     0x0000

;----- INTCON Bits --------------------------------------------------------

GIE                          EQU     0x0007
PEIE                         EQU     0x0006
T0IE                         EQU     0x0005
INTE                         EQU     0x0004
RBIE                         EQU     0x0003
T0IF                         EQU     0x0002
INTF                         EQU     0x0001
RBIF                         EQU     0x0000

;----- PIR1 Bits ----------------------------------------------------------

EEIF                         EQU     0x0007
CMIF                         EQU     0x0006
RCIF                         EQU     0x0005
TXIF                         EQU     0x0004
CCP1IF                       EQU     0x0002
TMR2IF                       EQU     0x0001
TMR1IF                       EQU     0x0000

;----- T1CON Bits ---------------------------------------------------------
T1CKPS1                      EQU     0x0005
T1CKPS0                      EQU     0x0004
T1OSCEN                      EQU     0x0003
NOT_T1SYNC                   EQU     0x0002
TMR1CS                       EQU     0x0001
TMR1ON                       EQU     0x0000

;----- T2CON Bits ---------------------------------------------------------
TOUTPS3                      EQU     0x0006
TOUTPS2                      EQU     0x0005
TOUTPS1                      EQU     0x0004
TOUTPS0                      EQU     0x0003
TMR2ON                       EQU     0x0002
T2CKPS1                      EQU     0x0001
T2CKPS0                      EQU     0x0000

;----- CCP1CON Bits ---------------------------------------------------------
CCP1X                        EQU     0x0005
CCP1Y                        EQU     0x0004
CCP1M3                       EQU     0x0003
CCP1M2                       EQU     0x0002
CCP1M1                       EQU     0x0001
CCP1M0                       EQU     0x0000

;----- RCSTA Bits ---------------------------------------------------------
SPEN                         EQU     0x0007
RX9                          EQU     0x0006
SREN                         EQU     0x0005
CREN                         EQU     0x0004
ADEN                         EQU     0x0003
FERR                         EQU     0x0002
OERR                         EQU     0x0001
RX9D                         EQU     0x0000

;----- CMCON Bits ---------------------------------------------------------

C2OUT                        EQU     0x0007
C1OUT                        EQU     0x0006
C2INV                        EQU     0x0005
C1INV                        EQU     0x0004
CIS                          EQU     0x0003
CM2                          EQU     0x0002
CM1                          EQU     0x0001
CM0                          EQU     0x0000

;----- OPTION Bits --------------------------------------------------------

NOT_RBPU                     EQU     0x0007
INTEDG                       EQU     0x0006
T0CS                         EQU     0x0005
T0SE                         EQU     0x0004
PSA                          EQU     0x0003
PS2                          EQU     0x0002
PS1                          EQU     0x0001
PS0                          EQU     0x0000

;----- PIE1 Bits ----------------------------------------------------------

EEIE                         EQU     0x0007
CMIE                         EQU     0x0006
RCIE                         EQU     0x0005
TXIE                         EQU     0x0004
CCP1IE                       EQU     0x0002
TMR2IE                       EQU     0x0001
TMR1IE                       EQU     0x0000

;----- PCON Bits ----------------------------------------------------------

OSCF                         EQU     0x0003
NOT_POR                      EQU     0x0001
NOT_BO                       EQU     0x0000
NOT_BOR                      EQU     0x0000

;----- TXSTA Bits ----------------------------------------------------------
CSRC                         EQU     0x0007
TX9                          EQU     0x0006
TXEN                         EQU     0x0005
SYNC                         EQU     0x0004
BRGH                         EQU     0x0002
TRMT                         EQU     0x0001
TX9D                         EQU     0x0000

;----- EECON1 Bits ---------------------------------------------------------
WRERR                        EQU     0x0003
WREN                         EQU     0x0002
WR                           EQU     0x0001
RD                           EQU     0x0000

;----- VRCON Bits ---------------------------------------------------------

VREN                         EQU     0x0007
VROE                         EQU     0x0006
VRR                          EQU     0x0005
VR3                          EQU     0x0003
VR2                          EQU     0x0002
VR1                          EQU     0x0001
VR0                          EQU     0x0000

;----- Configuration Bits -------------------------------------------------

_BODEN_ON                    EQU     0x3FFF
_BODEN_OFF                   EQU     0x3FBF
_CP_ALL                      EQU     0x03FF
_CP_75                       EQU     0x17FF
_CP_50                       EQU     0x2BFF
_CP_OFF                      EQU     0x3FFF
_PWRTE_OFF                   EQU     0x3FFF
_PWRTE_ON                    EQU     0x3FF7
_WDT_ON                      EQU     0x3FFF
_WDT_OFF                     EQU     0x3FFB
_LVP_ON                      EQU     0x3FFF
_LVP_OFF                     EQU     0x3F7F
_MCLRE_ON                    EQU     0x3FFF
_MCLRE_OFF                   EQU     0x3FDF
_ER_OSC_CLKOUT               EQU     0x3FFF
_ER_OSC_NOCLKOUT             EQU     0x3FFE
_INTRC_OSC_CLKOUT            EQU     0x3FFD
_INTRC_OSC_NOCLKOUT          EQU     0x3FFC
_EXTCLK_OSC                  EQU     0x3FEF
_LP_OSC                      EQU     0x3FEC
_XT_OSC                      EQU     0x3FED
_HS_OSC                      EQU     0x3FEE
