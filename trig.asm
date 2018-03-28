; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;	Ishaan Madan
;	ibm6989
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)
	
.CODE

FixedSin PROC USES ebx edx esi edi ecx angle:FXPT
LOCAL neg_ang:DWORD

	mov neg_ang,0		
	mov esi, angle 		;store angle in the esi register for all these calculations
	mov ebx, TWO_PI

L_Z:	
	cmp esi,0
	jge GR_TWPI			; move on if angle is greater than or equal to 0
	add esi, ebx		; otherwise add twopi to angle and loop again
	jmp L_Z;


GR_TWPI: 				
	cmp esi, ebx 	; first check if angle is greater than twopi
	jl P_TP				; jump to next part if less than twopi	
	sub esi, ebx		; otherwise, subtract twopi from angle and try again
	jmp GR_TWPI


P_TP: 					; range pi to twopi
	mov ebx, PI
	cmp ebx, esi 		; compare angle to pi 
	jg PH_P 			
	sub esi, ebx  		; subtract pi from angle 
	xor neg_ang, 1          ;adjusting neg_angle value
	jmp P_TP


PH_P: 					; for range pi/2 to pi 
	mov ebx, PI_HALF
	mov ecx, PI
	cmp ebx, esi 		; compare pi/2 to angle
	jge TBLE1 			; jump to next section if less than or equal to pi/2
	sub ecx, esi 		; subtract angle from pi
	mov esi, ecx  		; angle = angle - pi
	jmp PH_P


TBLE1:					;deals with angle value between 0 and pi/half
	mov ebx, PI_HALF
	cmp ebx, esi
	je TBLE2

	mov eax, esi 		
	mov edx, PI_INC_RECIP 
	imul edx
	movzx eax, WORD PTR[SINTAB + edx*2]
	mov edi, eax

	cmp neg_ang, 0
 	je DONE
  	neg edi 			;adjust for negative
  	mov eax, edi
  	jmp DONE
  	
TBLE2:
	mov eax, 1
	shl eax, 16
	
DONE:
	ret			; Don't delete this line!!!
FixedSin ENDP 


FixedCos PROC USES edi ecx angle:FXPT
	mov ecx, PI_HALF
	mov edi, angle
	add edi, ecx
	invoke FixedSin, edi
	
	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
