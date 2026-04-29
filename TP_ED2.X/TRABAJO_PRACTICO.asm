LIST p=16F887
    RADIX HEX
#include "p16f887.inc"

 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;========================
; Variables
;========================
 ; holaaaaaaaaaaaaaa
W_TEMP      EQU 0x70
STATUS_TEMP EQU 0x71

INDEX EQU 0x20
NUM0  EQU 0x21
NUM1  EQU 0x22
NUM2  EQU 0x23
NUM3  EQU 0x24

    ORG 0x00
    GOTO INICIO

    ORG 0x04
    GOTO ISR

;========================
; Inicio
;========================
INICIO:

    ; Mostrar F123
    MOVLW 0x0F
    MOVWF NUM0

    MOVLW 0x01
    MOVWF NUM1

    MOVLW 0x02
    MOVWF NUM2

    MOVLW 0x03
    MOVWF NUM3

    ; Todo digital
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH

    ; PORTD = segmentos
    BANKSEL TRISD
    CLRF TRISD

    ; RC0-RC3 salidas
    BANKSEL TRISC
    MOVLW B'11110000'
    MOVWF TRISC

    ; Inicializa puertos
    BANKSEL PORTD
    MOVLW 0xFF
    MOVWF PORTD

    BANKSEL PORTC
    MOVLW 0x0F
    MOVWF PORTC

    ;========================
    ; Timer0
    ;========================
    BANKSEL OPTION_REG
    MOVLW B'00000111'
    MOVWF OPTION_REG

    BANKSEL TMR0
    MOVLW D'237'
    MOVWF TMR0

    ;========================
    ; Interrupciones
    ;========================
    BANKSEL INTCON
    BCF INTCON,TMR0IF
    BSF INTCON,TMR0IE
    BSF INTCON,GIE

    CLRF INDEX

LOOP:
    GOTO LOOP

;========================
; Tabla 7 segmentos
; Ánodo común
;========================
TABLA_DISPLAY:
    ADDWF PCL,F
    RETLW 0xC0 ;0
    RETLW 0xF9 ;1
    RETLW 0xA4 ;2
    RETLW 0xB0 ;3
    RETLW 0x99 ;4
    RETLW 0x92 ;5
    RETLW 0x82 ;6
    RETLW 0xF8 ;7
    RETLW 0x80 ;8
    RETLW 0x90 ;9
    RETLW 0x88 ;A
    RETLW 0x83 ;B
    RETLW 0xC6 ;C
    RETLW 0xA1 ;D
    RETLW 0x86 ;E
    RETLW 0x8E ;F

;========================
; ISR
;========================
ISR:
    ; Guardar contexto
    MOVWF W_TEMP
    SWAPF STATUS,W
    MOVWF STATUS_TEMP

    ; Timer0
    BCF INTCON,TMR0IF
    MOVLW D'237'
    MOVWF TMR0

    ; Apagar todos los displays
    MOVLW B'00001111'
    MOVWF PORTC

    ; Seleccionar número
    MOVLW NUM0
    ADDWF INDEX,W
    MOVWF FSR
    MOVF INDF,W

    ANDLW 0x0F
    CALL TABLA_DISPLAY
    MOVWF PORTD

    ; Habilitar display
    MOVF INDEX,W
    CALL HABILITACION_DISPLAY
    MOVWF PORTC

    ; Siguiente display
    INCF INDEX,F

    MOVF INDEX,W
    XORLW 0x04
    BTFSC STATUS,Z
    CLRF INDEX

    ; Restaurar contexto
    SWAPF STATUS_TEMP,W
    MOVWF STATUS
    SWAPF W_TEMP,F
    SWAPF W_TEMP,W
    RETFIE

;========================
; Habilitación displays
; Ánodo común activo en 0
;========================
HABILITACION_DISPLAY:
    ADDWF PCL,F
    RETLW B'00001110' ; Display 0 -> RC0
    RETLW B'00001101' ; Display 2 -> RC1
    RETLW B'00001011' ; Display 1 -> RC2
    RETLW B'00000111' ; Display 3 -> RC3

    END

