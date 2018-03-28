; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
; 	Ishaan Madan 
;	netid: ibm6989
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE


;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD

DrawLine PROC USES eax ebx edx esi ecx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
  ;; Feel free to use local variables...declare them here
  ;; For example:
  ;;  LOCAL foo:DWORD, bar:DWORD

  LOCAL deltax:DWORD, deltay:DWORD, incx:DWORD, incy:DWORD, error:DWORD, currx:DWORD, curry:DWORD, prev_e:DWORD
  
  ;; Place your code here


 
  mov eax, x1
  mov ebx, x0
  sub eax, ebx
  cmp eax, 0             
  jge NOTNEG     	; jump if x1-x0 is greater than or equal to 0
  neg eax  	 		; if negative, negate to get abs value

  NOTNEG:
  mov deltax, eax   ; store x1-x0 in deltax

  mov eax, y1
  mov ebx, y0
  sub eax, ebx
  cmp eax, 0
  jge NOTNEG2     	; jump if y1-y0 is greater than or equal to 0
  neg eax       	; if negative, negate to get abs value

  NOTNEG2: 
  mov deltay, eax   ; store y1-y0 in deltay
  
  mov eax, x1
  mov ebx, x0
  cmp eax, ebx
  jle COND1       	; if x1 <= x0, jump to COND2
  mov incx, 1     	; x1>x0 here so store 1 in incx
  jmp AHEAD     	; jump straight to AHEAD, which is the next part of the code

  COND1: 
  mov incx, -1
  
  AHEAD:
  mov eax, y1
  mov ebx, y0
  cmp eax, ebx
  jle COND2       	; if y1<=y0, jump to COND2
  mov incy, 1     	; y1>y0 here so store 1 in incy
  jmp AHEAD2      	; jumpe straight to AHEAD2, which is the next part of the code

  COND2: 
  mov incy, -1    	; store -1 in incy
  
  AHEAD2: 
  mov esi, 2      	;both the conditions require division by 2 so we move this preemptively 
  mov ecx, deltax
  mov ebx, deltay 
  cmp ecx, ebx    	; check if ecx > ebx
  jg COND3      	; if deltax > deltay, jump to COND3
  mov eax, deltay   ; if the above statment is not true, we continue 
  div esi        	; deltay /2 
  neg eax       	; -deltay/2
  mov error, eax    ; error = -deltay/2
  jmp AHEAD3        ; jump to next part of code 


  COND3:
  mov eax, deltax   
  div esi        	; deltax/2
  mov error, eax    ; error = deltax/2

     
  AHEAD3: 
  mov eax, x0
  mov ebx, y0
  mov currx, eax    ; currx = x0
  mov curry, ebx    ; curry = y0
  
  Invoke DrawPixel, currx, curry, color  

  ; while loop starts here 
  DO: 
  mov eax, x1
  cmp currx, eax
  jne CONT      	; if currx != x1, we immediately evaluate the condition in the loop
  mov ebx, y1
  cmp curry, ebx
  je DONE       	; if they are equal, we exit 

  CONT: 
  Invoke DrawPixel, currx, curry, color
  mov eax, error
  mov prev_e, eax   ; preverror = error 

  mov ecx, deltax
  neg ecx       	; preemptively save the value of negative deltax
  cmp prev_e, ecx 
  jle IFT       	; if preverror <= -deltax, jump straight to second if statment 
  mov edx, deltay 
  sub error, edx    ; error = error- deltay
  mov esi, incx
  add currx, esi    ; currx= currx + incx

  IFT: 
  mov eax, deltay
  cmp prev_e, eax
  jge DO        	; if prev_error >= deltay, jump back to original part of whileloop
  mov esi, deltax
  add error, esi    ; error = error + deltax
  mov ebx, incy   
  add curry, ebx    ; curry= curry + incy
  jmp DO        	; iterate through whileloop again

  DONE: 
  ret         		;;  Don't delete this line...you need it

  DrawLine ENDP
  
END