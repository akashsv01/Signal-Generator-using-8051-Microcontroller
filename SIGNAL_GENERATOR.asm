;DAC INTERFACING IN 8051
;MICROCONTROLLER PROJECT
;SIGNAL GENERATOR USING DAC
;"SIGNAL GENERATOR" IS DISPLAYED
;ON THE 16*2 LCD DISPLAY
;NEXT IS THE MENU PROGRAM
;IF USER ENTERS 1 - A TRIANGULAR
;WAVE IS GENERATED
;IF USER ENTERS 2 - A SQUARE WAVE
;IS GENERATED
;IF USER ENTERS 3 - A SINE WAVE
;IS GENERATED 
    MOV 30H, #'S'
 	MOV 31H, #'I'
	MOV 32H, #'G'
	MOV 33H, #'N'
	MOV 34H, #'A'
	MOV 35H, #'L'
	MOV 36H, #' '
	MOV 37H, #'G'
	MOV 38H, #'E'
	MOV 39H, #'N'
	MOV 3AH, #'E'
	MOV 3BH, #'R'
    MOV 3CH, #'A'
    MOV 3DH, #'T'
    MOV 3EH, #'O'
    MOV 3FH, #'R'
    MOV 40H, #0  ;END OF DATA MARKER

   ;INITIALIZE THE DISPLAY
	CLR P1.3 ;CLEAR RS - INDICATES
   ;THAT THE INSTRUCTIONS ARE BEING
   ;SENT TO THE MODULE

	;FUNCTION SET
	CLR P1.7		
	CLR P1.6		
	SETB P1.5		
	CLR P1.4		
	SETB P1.2	
	CLR P1.2		
	;WAIT FOR BF TO CLEAR
	CALL delay		

	SETB P1.2		
	CLR P1.2		
	SETB P1.7	 
	SETB P1.2		
	CLR P1.2					
	CALL delay		

	;ENTRY MODE SET
	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4	

	SETB P1.2		
	CLR P1.2		
	SETB P1.6		
	SETB P1.5	

	SETB P1.2	
	CLR P1.2 

	;WAIT FOR BF TO CLEAR
	CALL delay

	;DISPLAY ON/OFF CONTROL
    ;THE DISPLAY IS TURNED ON, 
	;THE CURSOR IS TURNED ON AND 
	;BLINKING IS TURNED ON
	CLR P1.7		
	CLR P1.6	
	CLR P1.5		
	CLR P1.4	

	SETB P1.2		
	CLR P1.2

	SETB P1.7		
	SETB P1.6		
	SETB P1.5		
	SETB P1.4	

	SETB P1.2		
	CLR P1.2		

	;WAIT FOR BF TO CLEAR
	CALL delay	
    ;SEND DATA
	SETB P1.3	
	;DATA TO BE SENT TO LCD
	;IS STORED IN 8051 RAM,
	;STARTING AT LOCATION 30H
	MOV R1, #30H	

loop:
	;MOVE DATA POINTED BY R1 TO A
	MOV A, @R1	    
	JZ finish
    ;IF A IS 0, 
	;THEN END OF DATA HAS BEEN
	;reached - JUMP OUT OF LOOP
	CALL sendCharacter
	;SEND DATA IN A TO LCD MODULE
	INC R1	 
	JMP loop	
	;REPEAT

finish:
	JMP START

sendCharacter:
	MOV C, ACC.7		
	MOV P1.7, C		
	MOV C, ACC.6		
	MOV P1.6, C		
	MOV C, ACC.5		
	MOV P1.5, C		
	MOV C, ACC.4		
	MOV P1.4, C	

	SETB P1.2		
	CLR P1.2		

	MOV C, ACC.3		
	MOV P1.7, C	
	MOV C, ACC.2		
	MOV P1.6, C		
	MOV C, ACC.1		
	MOV P1.5, C		
	MOV C, ACC.0		
	MOV P1.4, C		

	SETB P1.2		
	CLR P1.2		

	CALL delay	

delay:
	MOV R0, #50
	DJNZ R0, $
	RET

SINE:
DB 127,160,191,217,237,250,255,250,237,217,191,160,127,94,63,37,17,4,0,4,17,37,63,94,127
TRIANGULAR:
    CLR A     ;CLR ACCUMULATOR
    CLR P0.7  ;CLR DAC WR
    LOOP2:
      MOV P1,A 
      ADD A,#3 ;ADD 3 TO A
      ;COMPARE A AND #OFFH
	  ;IF NOT EQUAL, JUMP TO LOOP2
      CJNE A,#0FFH,LOOP2
    LOOP1: 
      MOV P1,A
      SUBB A,#3 ;SUBB FROM A
      ;COMPARE A AND #00H
      ;IF NOT EQUAL, JUMP TO LOOP1
      CJNE A,#00H,LOOP1
      JMP LOOP2 ;JUMP TO LOOP2
      RET       ;RETURN

SQUARE:
   	 CLR A       ;CLR ACCUMULATOR
     CLR P0.7    ;CLR DAC WR
    BACK: 
      MOV A,#00H ;MOV #00H TO A
      MOV P1,A  
      CALL B1
      MOV A,#0FFH 
      MOV P1,A
      CALL B1
      LJMP BACK ;TRANSFERS PROGRAM EXECUTION TO BACK
     B1: MOV R2,#02FH ;MOV #02FH TO R2
     B2: DJNZ R0,B2 
     RET

SINWAVE:
	CLR A     ;CLR ACCUMULATOR
    UP:
    MOV DPTR,#SINE 
    MOV R0,#24  ;MOV 24 TO R0
	CLR P0.7  ;CLR DAC WR
	LABEL: 
      MOVC A,@A+DPTR 
      ;MOVES A BYTE FROM 
      ;PROGRAM MEMORY 
      ;TO ACCUMULATOR
      MOV P1,A
      CLR A
      INC DPTR
      DJNZ R0,LABEL ;DECREMENTS R0
      ;IF R0 IS NOT ZERO, JUMP BACK TO LABEL
      SJMP UP

colScan:
	JNB P0.4,THREE
	JNB P0.5,TWO
	JNB P0.6,ONE
    RET
gotKey:
	SETB F0
    RET
ONE:
	SETB P3.3
    SETB P3.4
    MOV P1, #11111001B
    CALL TRIANGULAR
    JMP gotKey
TWO:
	SETB P3.3
    SETB P3.4
    MOV P1, #10100100B
    CALL SQUARE
    JMP gotKey
THREE:
	SETB P3.3
    SETB P3.4
    MOV P1, #10110000B
	CALL SINWAVE
    JMP gotKey
START:
	CLR P0.3 ;MAKING TOP ROW
	CALL colScan
JNB F0,START
END