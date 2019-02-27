            TTL Minesweeper
;****************************************************************
; Create a minesweeper clone using terminal over UART
;Name:  Andy Belle-Isle
;Date:  12-04-2018
;Class:  CMPE-250
;Section:  2 - Tuesdays @ 14:00
;---------------------------------------------------------------
;Keil Template for KL46 Assembly with Keil C startup
;R. W. Melton
;November 13, 2017
;****************************************************************
;Assembler directives
            THUMB
            GBLL  MIXED_ASM_C
MIXED_ASM_C SETL  {TRUE}
            OPT   64  ;Turn on listing macro expansions
;****************************************************************
;Include files
            GET  MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;****************************************************************
;EQUates

;---------------------------------------------------------------
;PORTx_PCRn (Port x pin control register n [for pin n])
;___->10-08:Pin mux control (select 0 to 8)
;Use provided PORT_PCR_MUX_SELECT_2_MASK
;---------------------------------------------------------------
;Port A
PORT_PCR_SET_PTA1_UART0_RX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
PORT_PCR_SET_PTA2_UART0_TX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
;---------------------------------------------------------------
;SIM_SCGC4
;1->10:UART0 clock gate control (enabled)
;Use provided SIM_SCGC4_UART0_MASK
;---------------------------------------------------------------
;SIM_SCGC5
;1->09:Port A clock gate control (enabled)
;Use provided SIM_SCGC5_PORTA_MASK
;---------------------------------------------------------------
;SIM_SOPT2
;01=27-26:UART0SRC=UART0 clock source select
;         (PLLFLLSEL determines MCGFLLCLK' or MCGPLLCLK/2)
; 1=   16:PLLFLLSEL=PLL/FLL clock select (MCGPLLCLK/2)
;---------------------------------------------------------------
SIM_SOPT2_UART0SRC_MCGPLLCLK  EQU  \
                                 (1 << SIM_SOPT2_UART0SRC_SHIFT)
SIM_SOPT2_UART0_MCGPLLCLK_DIV2 EQU \
    (SIM_SOPT2_UART0SRC_MCGPLLCLK :OR: SIM_SOPT2_PLLFLLSEL_MASK)
;---------------------------------------------------------------
;SIM_SOPT5
; 0->   16:UART0 open drain enable (disabled)
; 0->   02:UART0 receive data select (UART0_RX)
;00->01-00:UART0 transmit data select source (UART0_TX)
SIM_SOPT5_UART0_EXTERN_MASK_CLEAR  EQU  \
                               (SIM_SOPT5_UART0ODE_MASK :OR: \
                                SIM_SOPT5_UART0RXSRC_MASK :OR: \
                                SIM_SOPT5_UART0TXSRC_MASK)
;---------------------------------------------------------------
;UART0_BDH
;    0->  7:LIN break detect IE (disabled)
;    0->  6:RxD input active edge IE (disabled)
;    0->  5:Stop bit number select (1)
;00001->4-0:SBR[12:0] (UART0CLK / [9600 * (OSR + 1)]) 
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDH_9600  EQU  0x01
;---------------------------------------------------------------
;UART0_BDL
;26->7-0:SBR[7:0] (UART0CLK / [9600 * (OSR + 1)])
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDL_9600  EQU  0x38
;---------------------------------------------------------------
;UART0_C1
;0-->7:LOOPS=loops select (normal)
;0-->6:DOZEEN=doze enable (disabled)
;0-->5:RSRC=receiver source select (internal--no effect LOOPS=0)
;0-->4:M=9- or 8-bit mode select 
;        (1 start, 8 data [lsb first], 1 stop)
;0-->3:WAKE=receiver wakeup method select (idle)
;0-->2:IDLE=idle line type select (idle begins after start bit)
;0-->1:PE=parity enable (disabled)
;0-->0:PT=parity type (even parity--no effect PE=0)
UART0_C1_8N1  EQU  0x00
;---------------------------------------------------------------
;UART0_C2
;0-->7:TIE=transmit IE for TDRE (disabled)
;0-->6:TCIE=transmission complete IE for TC (disabled)
;0-->5:RIE=receiver IE for RDRF (disabled)
;0-->4:ILIE=idle line IE for IDLE (disabled)
;1-->3:TE=transmitter enable (enabled)
;1-->2:RE=receiver enable (enabled)
;0-->1:RWU=receiver wakeup control (normal)
;0-->0:SBK=send break (disabled, normal)
UART0_C2_T_R  EQU  (UART0_C2_TE_MASK :OR: UART0_C2_RE_MASK)
;---------------------------------------------------------------
;UART0_C3
;0-->7:R8T9=9th data bit for receiver (not used M=0)
;           10th data bit for transmitter (not used M10=0)
;0-->6:R9T8=9th data bit for transmitter (not used M=0)
;           10th data bit for receiver (not used M10=0)
;0-->5:TXDIR=UART_TX pin direction in single-wire mode
;            (no effect LOOPS=0)
;0-->4:TXINV=transmit data inversion (not inverted)
;0-->3:ORIE=overrun IE for OR (disabled)
;0-->2:NEIE=noise error IE for NF (disabled)
;0-->1:FEIE=framing error IE for FE (disabled)
;0-->0:PEIE=parity error IE for PF (disabled)
UART0_C3_NO_TXINV  EQU  0x00
;---------------------------------------------------------------
;UART0_C4
;    0-->  7:MAEN1=match address mode enable 1 (disabled)
;    0-->  6:MAEN2=match address mode enable 2 (disabled)
;    0-->  5:M10=10-bit mode select (not selected)
;01111-->4-0:OSR=over sampling ratio (16)
;               = 1 + OSR for 3 <= OSR <= 31
;               = 16 for 0 <= OSR <= 2 (invalid values)
UART0_C4_OSR_16           EQU  0x0F
UART0_C4_NO_MATCH_OSR_16  EQU  UART0_C4_OSR_16
;---------------------------------------------------------------
;UART0_C5
;  0-->  7:TDMAE=transmitter DMA enable (disabled)
;  0-->  6:Reserved; read-only; always 0
;  0-->  5:RDMAE=receiver full DMA enable (disabled)
;000-->4-2:Reserved; read-only; always 0
;  0-->  1:BOTHEDGE=both edge sampling (rising edge only)
;  0-->  0:RESYNCDIS=resynchronization disable (enabled)
UART0_C5_NO_DMA_SSR_SYNC  EQU  0x00
;---------------------------------------------------------------
;UART0_S1
;0-->7:TDRE=transmit data register empty flag; read-only
;0-->6:TC=transmission complete flag; read-only
;0-->5:RDRF=receive data register full flag; read-only
;1-->4:IDLE=idle line flag; write 1 to clear (clear)
;1-->3:OR=receiver overrun flag; write 1 to clear (clear)
;1-->2:NF=noise flag; write 1 to clear (clear)
;1-->1:FE=framing error flag; write 1 to clear (clear)
;1-->0:PF=parity error flag; write 1 to clear (clear)
UART0_S1_CLEAR_FLAGS  EQU  (UART0_S1_IDLE_MASK :OR: \
                            UART0_S1_OR_MASK :OR: \
                            UART0_S1_NF_MASK :OR: \
                            UART0_S1_FE_MASK :OR: \
                            UART0_S1_PF_MASK)
;---------------------------------------------------------------
;UART0_S2
;1-->7:LBKDIF=LIN break detect interrupt flag (clear)
;             write 1 to clear
;1-->6:RXEDGIF=RxD pin active edge interrupt flag (clear)
;              write 1 to clear
;0-->5:(reserved); read-only; always 0
;0-->4:RXINV=receive data inversion (disabled)
;0-->3:RWUID=receive wake-up idle detect
;0-->2:BRK13=break character generation length (10)
;0-->1:LBKDE=LIN break detect enable (disabled)
;0-->0:RAF=receiver active flag; read-only
UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS  EQU  \
        (UART0_S2_LBKDIF_MASK :OR: UART0_S2_RXEDGIF_MASK)
;---------------------------------------------------------------
UART0_IRQ_PRIORITY_3    EQU 3
    
UART0_C2_T_RI           EQU (UART0_C2_RIE_MASK :OR: UART0_C2_T_R)
UART0_C2_TI_RI          EQU (UART0_C2_TIE_MASK :OR: UART0_C2_T_RI)
;---------------------------------------------------------------
;---------------------------------------------------------------
;NVIC_ICER
;31-00:CLRENA=masks for HW IRQ sources;
;             read:   0 = unmasked;   1 = masked
;             write:  0 = no effect;  1 = mask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ICER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_ICPR
;31-00:CLRPEND=pending status for HW IRQ sources;
;             read:   0 = not pending;  1 = pending
;             write:  0 = no effect;
;                     1 = change status to not pending
;22:PIT IRQ pending status
;12:UART0 IRQ pending status
NVIC_ICPR_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICPR_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_IPR0-NVIC_IPR7
;2-bit priority:  00 = highest; 11 = lowest
;--PIT
PIT_IRQ_PRIORITY    EQU  0
NVIC_IPR_PIT_MASK   EQU  (3 << PIT_PRI_POS)
NVIC_IPR_PIT_PRI_0  EQU  (PIT_IRQ_PRIORITY << UART0_PRI_POS)
;--UART0
UART0_IRQ_PRIORITY    EQU  3
NVIC_IPR_UART0_MASK   EQU  (3 << UART0_PRI_POS)
NVIC_IPR_UART0_PRI_3  EQU  (UART0_IRQ_PRIORITY << UART0_PRI_POS)
;---------------------------------------------------------------
;NVIC_ISER
;31-00:SETENA=masks for HW IRQ sources;
;             read:   0 = masked;     1 = unmasked
;             write:  0 = no effect;  1 = unmask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ISER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ISER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;PIT_LDVALn:  PIT load value register n
;31-00:TSV=timer start value (period in clock cycles - 1)
;Clock ticks for 0.01 s at 24 MHz count rate
;1 s * 24,000,000 Hz = 24,000,000
;TSV = 24,000,000 - 1
;PIT_LDVAL  EQU  23999999
PIT_LDVAL  EQU  2399999
;---------------------------------------------------------------
;PIT_MCR:  PIT module control register
;1-->    0:FRZ=freeze (continue'/stop in debug mode)
;0-->    1:MDIS=module disable (PIT section)
;               RTI timer not affected
;               must be enabled before any other PIT setup
PIT_MCR_EN_FRZ  EQU  PIT_MCR_FRZ_MASK
;---------------------------------------------------------------
;PIT_TCTRLn:  PIT timer control register n
;0-->   2:CHN=chain mode (enable)
;1-->   1:TIE=timer interrupt enable
;1-->   0:TEN=timer enable
PIT_TCTRL_CH_IE  EQU  (PIT_TCTRL_TEN_MASK :OR: PIT_TCTRL_TIE_MASK)
PIT_TCTRL_CH_I   EQU   PIT_TCTRL_TEN_MASK
;---------------------------------------------------------------

; the amount of values the dac can hold (12 bit dac)
DAC0_STEPS		EQU		4096

; how many different positions the servo can be set to
SERVO_POSITIONS	EQU		5
	
; duty values for 2_ms and 1_ms duty cycles
TPM_CnV_PWM_DUTY_2ms	EQU	6000
TPM_CnV_PWM_DUTY_1ms	EQU	3000
PWM_2ms			EQU		TPM_CnV_PWM_DUTY_2ms
PWM_1ms			EQU		TPM_CnV_PWM_DUTY_1ms

SERIAL_Q_BUF_SZ EQU     16			; queue can be a max of 16 characters long
SERIAL_Q_HDR_SZ EQU     20			; queue record is 18 bytes long (with padding)

; byte offsets of the queue record data
IN_PTR			EQU		0
OUT_PTR			EQU		4
BUF_STRT		EQU		8
BUF_PAST		EQU		12
BUF_SIZE		EQU		16
NUM_ENQD		EQU		17

;****************************************************************
;MACROs
;****************************************************************
;Program
;C source will contain main ()
;Only subroutines and ISRs in this assembly source
            AREA    MyCode,CODE,READONLY

            IMPORT ToBCD
            IMPORT LCD_PutHex
            IMPORT InitLCD
                
            EXPORT PIT_IRQHandler
			EXPORT UART0_IRQHandler
			EXPORT Init_UART0_IRQ
			EXPORT Init_PIT_IRQ
			EXPORT PutStringSB
			EXPORT GetChar
			EXPORT PutChar
;>>>>> begin subroutine code <<<<<

Init_PIT_IRQ    PROC {R0-R14}
;---------------------------------------------------------------
; Initializes PIT timer for interrupts every 0.1s
;

            PUSH{R0-R4, LR}
            
            ;BL      Init_LCD

        ;Enable clock for PIT module 
            LDR     R0,=SIM_SCGC6 
            LDR     R1,=SIM_SCGC6_PIT_MASK 
            LDR     R2,[R0,#0] 
            ORRS    R2,R2,R1
            STR     R2,[R0,#0] 

        ;Disable PIT timer 0 
            LDR     R0,=PIT_CH0_BASE
            LDR     R1,=PIT_TCTRL_TEN_MASK 
            LDR     R2,[R0,#PIT_TCTRL_OFFSET] 
            BICS    R2,R2,R1
            STR     R2,[R0,#PIT_TCTRL_OFFSET] 

        ; Set PIT interrupt priority
            LDR     R0,=PIT_IPR 
            LDR     R1,=NVIC_IPR_PIT_MASK 
            ;LDR     R2,=NVIC_IPR_PIT_PRI_0 
            LDR     R4,[R0,#0] 
            BICS    R4,R4,R1
            ;ORRS    R4,R4,R2
            STR     R4,[R0,#0] 

        ;Clear any pending PIT interrupts 
            LDR     R0,=NVIC_ICPR 
            LDR     R1,=NVIC_ICPR_PIT_MASK 
            STR     R1,[R0,#0] 

        ;Unmask PIT interrupts 
            LDR     R0,=NVIC_ISER 
            LDR     R1,=NVIC_ISER_PIT_MASK 
            STR     R1,[R0,#0] 

        ;Enable PIT module 
            LDR     R0,=PIT_BASE 
            LDR     R1,=PIT_MCR_EN_FRZ 
            STR     R1,[R0,#PIT_MCR_OFFSET] 

        ;Set PIT timer 0 period for 0.01 s 
            LDR     R0,=PIT_CH0_BASE 
            LDR     R1,=PIT_LDVAL 
            STR     R1,[R0,#PIT_LDVAL_OFFSET]

        ;Enable PIT timer 0 interrupt 
            LDR     R1,=PIT_TCTRL_CH_IE 
            STR     R1,[R0,#PIT_TCTRL_OFFSET] 

            POP{R0-R4, PC}
            ENDP

PIT_IRQHandler
PIT_ISR     PROC {R0-R14}
;---------------------------------------------------------------
; ISR that triggers every 0.01 seconds which acts as a stopwatch.
; If the "stopwatch" is running, it will add to our counting variable every
;   time it is triggered.
;

            PUSH{R0-R1, R4-R7, LR}
            CPSID   I

        ; Take the loop down counter from memory for subtracting
            LDR     R7, =RunStopWatch
            LDRB    R7, [R7, #0]

            LDR     R5, =Seconds
            LDR     R3, [R5, #0]

        ; Take the loop up counter from memory
            LDR     R6, =Count
            LDR     R4, [R6, #0]

            CMP     R7, #0              ; if the down counter is 0 or less, then
            BLE     PIT_ISR_SKIPADD     ;   skip adding to up counter

            ADDS    R3, R3, #1          ; add to second counter

            CMP     R3, #10
            BLE     PIT_ISR_SKIPADD

            MOVS    R3, #0
            ADDS    R4, R4, #1

            MOVS    R0, R4              ; put counter value in R0
            BL      ToBCD               ; convert r0 value to BCD
            BL      LCD_PutHex          ; Use the PutHex subroutine from the
                                        ;   hard fault code. Since the BCD only
                                        ;   has values from 0-9, only those will
                                        ;   print, not any of the numbers

PIT_ISR_SKIPADD

            LDR     R0, =Seeder
            LDR     R1, [R0, #0]
            ADDS    R1, R1, #1
            STR     R1, [R0, #0]

            STR     R4, [R6, #0]        ; Store count back in memory
            STR     R3, [R5, #0]        ; Store seconds back in memory
            
        ; Clear pending timer interrupts
            LDR     R0, =PIT_TFLG0
            LDR     R1, =PIT_TCTRL_CH_IE
            STR     R1, [R0, #0]

            CPSIE   I
            POP{R0-R1, R4-R7, PC}
            ENDP

UART0_IRQHandler
UART0_ISR   PROC {R0-R14}
;****************************************************************
; Called when either a TX or RX interrupt request is triggered.
;
        ; push registers and disable interrupts
            CPSID I
            PUSH {R5-R7, LR}

            LDR     R7, =UART0_BASE				; base memory addr of uart
            LDRB    R6, [R7, #UART0_S1_OFFSET]  ; uart0 s1 register
            LDRB    R5, [R7, #UART0_C2_OFFSET]  ; uart0 c2 register

UART0_ISR_TX
            LDR     R1, =TX_QUEUE_HDR
        ; test if TIE is set
            MOVS    R3, #UART0_C2_TIE_MASK
            TST     R5, R3
            BEQ     UART0_ISR_RX                ; if its not set, try recieving
                                                ; if it is, test if tx port is
                                                ;   open for sending

        ; if TDRE is set, we can send a character
            MOVS    R3, #UART0_S1_TDRE_MASK
            TST     R6, R3
            BEQ     UART0_ISR_RX                ; if its not set, test if we can
                                                ;   recieve a charcter

        ; dequeue a character from the tx queue to send over serial
            BL      Dequeue
            BCS     UART0_ISR_TX_DISABLE
            ; if dequeue failed, disable tx
            ;   interrupt

        ; send the charcter over tx
            STRB    R0, [R7, #UART0_D_OFFSET]            
            B       UART0_ISR_RX

UART0_ISR_TX_DISABLE
        ; disable tx interrupts from happening
            MOVS     R3, #UART0_C2_T_RI
            STRB     R3, [R7, #UART0_C2_OFFSET]

UART0_ISR_RX
            LDR     R1, =RX_QUEUE_HDR
        ; if there is a character waiting in RX port enqueue it into the rx
        ;   queue for writing later
            MOVS    R3, #UART0_S1_RDRF_MASK
            TST     R6, R3
            BEQ     UART0_ISR_END               ; if its not set, test if we can
            
            LDRB    R0, [R7, #UART0_D_OFFSET]
            BL      Enqueue                     ; if the queue is full, we lose
                                                ;   the char

UART0_ISR_END

        ; pop registers and enable interrupts
            CPSIE I
            POP {R5-R7, PC}
            ENDP

InitQueue	PROC {R3-R14}
;****************************************************************
; Initialize the queue structure
; Input: R0 - The queue buffer address in memory
;		 R1 - The memory location of the queue header
;		 R2 - The size of the queue buffer located in the address in R0
;
			PUSH{R0-R3, LR}

            ADDS    R3, R0, R2                  ; get the location of the end of
                                                ;   the buffer
			
			STR		R0, [R1, #IN_PTR]	        ; store in ptr to byte 0
		    STR   	R0, [R1, #OUT_PTR]			; store out ptr to byte 4
            STR    	R0, [R1, #BUF_STRT]         ; store buffer start to byte 8
            STR    	R3, [R1, #BUF_PAST]         ; store byte past buffer in 12
            STRB    R2, [R1, #BUF_SIZE]         ; and store size of buffer in 16

            MOVS    R3, #0                      ; move 0 into the total elements
            STRB    R3, [R1, #NUM_ENQD]         ;   counter at byte 17

			POP{R0-R3, PC}
			ENDP

Dequeue     PROC {R2-R14}
;****************************************************************
; Attempts to remove a character from the queue
; Input: R1 - The location of the queue header
; Output : R0 - The dequeued character
;
            PUSH{R2-R5, LR}

            LDR     R3, [R1, #OUT_PTR]    ; location of out_ptr
            LDR     R5, [R1, #BUF_PAST]   ; location of the byte past the buffer

            LDRB    R2, [R1, #NUM_ENQD]   ; how many items are queued, if zero, skip
            CMP     R2, #0          ;   everything
            BNE     Dequeue_Queue

            BL		SetCFlag		; set c flag to show something went wrong
			
            B       Dequeue_SkipAll

Dequeue_Queue

            LDRB    R0, [R3, #0]    ; put value in out_ptr into R0
            ADDS    R3, R3, #1

            CMP     R3, R5          ; if out_ptr is too big, wrap it to start of
            BLO     Dequeue_SkipWrap;   buffer
            LDR     R3, [R1, #8]    ; start of queue

Dequeue_SkipWrap
            STR     R3, [R1, #4]    ; place out_ptr back into header
            SUBS    R2, R2, #1      ; remove number of enqueue items
            STRB    R2, [R1, #17]
			
			BL		ClearCFlag

Dequeue_SkipAll

            POP{R2-R5, PC}
            BX LR
            ENDP
				
Enqueue     PROC {R2-R14}
;****************************************************************
; Attempts to add a charcter to the queue
; Input: R1 - The location of the queue header
;        R0 - The character to enqueue
;

            ; R2 = size of queue
            ; R3 = location of in_ptr
            ; R5 = byte past buffer

            PUSH{R2-R6, LR}

            LDR     R3, [R1, #IN_PTR]
            LDR     R5, [R1, #BUF_PAST]	; the byte past the 
            LDRB    R6, [R1, #BUF_SIZE]	; size of buffer
			LDRB	R2, [R1, #NUM_ENQD]	; how many items are in the queue

            CMP     R2, R6          ; if there is no space left, don't queue
            BLO     Enqueue_queue   ;   anything

            BL		SetCFlag        ; set c flag to show something went wrong
            B       Enqueue_SkipAll


Enqueue_queue
            STRB    R0, [R3, #IN_PTR]    ; store character at in_ptr
            ADDS    R3, R3, #1      ; increase in_ptr by 1 byte and store this

            CMP     R3, R5          ; test if location pointer is past end of
            BLO     Enqueue_SkipWrap;   queue buffer. If it is, reset it back to
            LDR     R3, [R1, #BUF_STRT]    ;   start of queue

Enqueue_SkipWrap

            STR     R3, [R1, #IN_PTR]    ; place new in_ptr back into header
            ADDS    R2, R2, #1      ; increase size of queue pointer and store
            STRB    R2, [R1, #NUM_ENQD]   ;   back in queue header
			
			BL		ClearCFlag

Enqueue_SkipAll

            POP{R2-R6, PC}
            BX LR
            ENDP
				
SetCFlag	PROC {R0-R14}
;****************************************************************
; Sets the C flag without modifying any other registers
	
			PUSH {R2, R3, LR}
	
			MRS     R2, APSR    ;place APSR into R2
            MOVS    R3, #0x20   ;set c flag
            LSLS    R3, R3, #24 ;shift over to 29th bit
            ORRS    R2, R2, R3  ;set c bit using mask
            MSR     APSR, R2    ;move R2 back into APSR
			
			POP {R2, R3, PC}
			BX LR
			ENDP
				
ClearCFlag	PROC {R0-R14}
;****************************************************************
; Clears the C flag without modifying any other registers
	
			PUSH {R2, R3, LR}
	
			MRS     R2, APSR    ;place APSR into R2
            MOVS    R3, #0x20   ;set c flag
            LSLS    R3, R3, #24 ;shift over to 29th bit
            BICS    R2, R2, R3  ;set c bit using mask
            MSR     APSR, R2    ;move R2 back into APSR
			
			POP {R2, R3, PC}
			BX LR
			ENDP
				
GetChar     PROC {R2-R14}
;****************************************************************
; Gets a character from the rx queue
; Output: R0 - The recieved character
;
            PUSH {R1, LR}

            LDR     R1, =RX_QUEUE_HDR
            MOVS    R0, #0
GetChar_LOOP
            CPSID I
            BL      Dequeue
            CPSIE I

            BCS       GetChar_LOOP

            POP {R1, PC}
            ENDP

PutChar     PROC {R2-R14}
;****************************************************************
; Places a character into the tx queue
; Input: R0 - The character to enqueue
;
            PUSH {R0, R1, LR}

            LDR     R1, =TX_QUEUE_HDR
PutChar_LOOP            
            CPSID I         ; disable interrupts
            BL      Enqueue ; enqueue the character
            CPSIE I         ; enable interrupts

            BCS     PutChar_LOOP    ; loop until this is successful

        ; enable tx interrupt
            LDR      R0, =UART0_BASE
            MOVS     R1, #UART0_C2_TI_RI
            STRB     R1, [R0, #UART0_C2_OFFSET]

            POP {R0, R1, PC}
            ENDP
				
PutStringSB PROC {R2-R14}
;****************************************************************
; Prints a string to the screen
; Input: R0 - The memory address to read the string from
;        R1 - The maximum length of the string buffer zone pointed to in R0
;
            PUSH {R2, R6, LR}

        ;R0 = Memory address in R0 that stores string info
        ;R1 = Length of string

        ;R6 = Backup memory address
        ;R2 = Current counter

            MOVS    R6, R0          ; move address of string to R2
            MOVS    R2, #0          ; make sure counter is clear

        ;print character until we run out of string
PrintCharacter
            LDRB    R0, [R6, R2]    ; load current character into R0
            ADDS    R2, R2, #1      ; increase character count

            BL      PutChar         ; print character at current pos

			CMP		R0, #0x0
			BEQ		PrintNull

            CMP     R2, R1          ; is our string still within size limits
            BLO     PrintCharacter  ;   if it is, loop again

PrintNull
			;MOVS	R0, #0x0
			;BL		PutChar			; print null termination

            POP {R2, R6, PC}
            BX      LR
            ENDP
				
Init_UART0_IRQ      PROC {R6-R14}
;****************************************************************
; Initializes UART0 to use hardware interrupts.
;
            PUSH{R0-R5, LR}

		; init rx queue
            LDR     R0, =RX_QUEUE_BFR
            LDR     R1, =RX_QUEUE_HDR
            LDR     R2, =SERIAL_Q_BUF_SZ
            BL      InitQueue
		; init tx queue
            LDR     R0, =TX_QUEUE_BFR
            LDR     R1, =TX_QUEUE_HDR
            LDR     R2, =SERIAL_Q_BUF_SZ
            BL      InitQueue

		;Select MCGPLLCLK / 2 as UART0 clock source
			LDR   	R3,=SIM_SOPT2     
			LDR   	R4,=SIM_SOPT2_UART0SRC_MASK     
			LDR   	R5,[R3,#0]     
			BICS  	R5,R5,R4    
			LDR   	R4,=SIM_SOPT2_UART0_MCGPLLCLK_DIV2     
			ORRS  	R5,R5,R4
			STR   	R5,[R3,#0] 
		;Enable external connection for UART0
			LDR   	R3,=SIM_SOPT5
			LDR   	R4,=SIM_SOPT5_UART0_EXTERN_MASK_CLEAR
			LDR  	R5,[R3,#0]
			BICS  	R5,R5,R4
			STR   	R5,[R3,#0] 
		;Enable clock for UART0 module
			LDR   	R3,=SIM_SCGC4
			LDR   	R4,=SIM_SCGC4_UART0_MASK
			LDR   	R5,[R3,#0]
			ORRS  	R5,R5,R4
			STR   	R5,[R3,#0] 
		;Enable clock for Port A module
			LDR   	R3,=SIM_SCGC5
			LDR   	R4,=SIM_SCGC5_PORTA_MASK
			LDR   	R5,[R3,#0]
			ORRS  	R5,R5,R4
			STR   	R5,[R3,#0] 
		;Connect PORT A Pin 1 (PTA1) to UART0 Rx (J1 Pin 02)
			LDR     R3,=PORTA_PCR1
			LDR     R4,=PORT_PCR_SET_PTA1_UART0_RX
			STR     R4,[R3,#0] 
		;Connect PORT A Pin 2 (PTA2) to UART0 Tx (J1 Pin 04)
			LDR     R3,=PORTA_PCR2
			LDR     R4,=PORT_PCR_SET_PTA2_UART0_TX
			STR     R4,[R3,#0]

        ;R0 = i
        ;R1 = j
        ;R2 = k

		; load base address for UART0
            LDR     R0, =UART0_BASE

        ; disable uart0
            MOVS    R1, #UART0_C2_T_R
            LDRB    R2, [R0, #UART0_C2_OFFSET]
            BICS    R2, R2, R1
            STRB    R2, [R0, #UART0_C2_OFFSET]

        ; init NVIC for UART0 interrupts
            LDR     R0, =UART0_IPR
            LDR     R2, =NVIC_IPR_UART0_PRI_3
            LDR     R3, [R0, #0]
            ORRS    R3, R3, R2
            STR     R3, [R0, #0]

        ; clear pending uart0 interrupts
            LDR     R0, =NVIC_ICPR
            LDR     R1, =NVIC_ICPR_UART0_MASK
            STR     R1, [R0, #0]

        ; unmask interrupts
            LDR     R0, =NVIC_ISER
            LDR     R1, =NVIC_ISER_UART0_MASK
            STR     R1, [R0, #0]
            
            LDR      R0, =UART0_BASE
            MOVS     R1, #UART0_C2_T_RI
            STRB     R1, [R0, #UART0_C2_OFFSET] 

        ; set uart0 baud rate, set bdh before bdl. Using 9600 baud
            MOVS    R1, #UART0_BDH_9600
            STRB    R1, [R0, #UART0_BDH_OFFSET]
            MOVS    R1, #UART0_BDL_9600
            STRB    R1, [R0, #UART0_BDL_OFFSET]

        ; set uart0 char format and clear all set flags
            MOVS    R1, #UART0_C1_8N1
            STRB    R1, [R0, #UART0_C1_OFFSET]
            MOVS    R1, #UART0_C3_NO_TXINV
            STRB    R1, [R0, #UART0_C3_OFFSET]
            MOVS    R1, #UART0_C4_NO_MATCH_OSR_16
            STRB    R1, [R0, #UART0_C4_OFFSET]
            MOVS    R1, #UART0_C5_NO_DMA_SSR_SYNC
            STRB    R1, [R0, #UART0_C5_OFFSET]
            MOVS    R1, #UART0_S1_CLEAR_FLAGS
            STRB    R1, [R0, #UART0_S1_OFFSET]
            MOVS    R1, #UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS
            STRB    R1, [R0, #UART0_S2_OFFSET]

        ; enable uart0
            MOVS    R1, #UART0_C2_T_R
            STRB    R1, [R0, #UART0_C2_OFFSET]

            POP{R0-R5, PC}
            ENDP
;>>>>>   end subroutine code <<<<<
            ALIGN
;**********************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<

;>>>>>   end constants here <<<<<
;**********************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
			EXPORT Count
			EXPORT RunStopWatch
            EXPORT Seeder
;>>>>> begin variables here <<<<<
; queue for the recieve characters
RX_QUEUE_HDR    SPACE   SERIAL_Q_HDR_SZ
RX_QUEUE_BFR    SPACE   SERIAL_Q_BUF_SZ

; queue for the transmit data
TX_QUEUE_HDR    SPACE   SERIAL_Q_HDR_SZ
TX_QUEUE_BFR    SPACE   SERIAL_Q_BUF_SZ
	
Count			SPACE	4
Seconds         SPACE   4
Seeder          SPACE   4
RunStopWatch	SPACE	1
;>>>>>   end variables here <<<<<
            END
