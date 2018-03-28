; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;	Ishaan Madan
;	ibm6989
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE


DrawPixel PROC uses eax ebx edx x:DWORD, y:DWORD, color:DWORD

	cmp x, 0
	jl DONE
	cmp x, 640
	jge DONE
	cmp y,0
	jl DONE 
	cmp y, 480
	jge DONE 		;all these conditions check the whether we can draw on the screen at all

	mov eax, y 
	mov ebx, color 	;store color in ebx
	mov edx, 640
	mul edx 		; multiply y by 640 
	add eax, x 		; add x to y*640
	add eax, ScreenBitsPtr
	mov BYTE PTR[eax], bl

DONE:
	ret 			; Don't delete this line!!!
DrawPixel ENDP




BasicBlit PROC USES eax ebx ecx edx esi ptrBitmap:PTR EECS205BITMAP ,xcenter:DWORD, ycenter:DWORD
LOCAL ind: DWORD, x0: DWORD, x1: DWORD, y0: DWORD, y1: DWORD, tran_c: BYTE 

	mov edx, ptrBitmap 		;eax holds start adress of bitmap
	mov ind, 0

	mov cl, (EECS205BITMAP PTR [edx]).bTransparent
	mov tran_c, cl			; tran_c stores the transparent color 

	mov ebx, xcenter
	mov x0, ebx				;xcenter value stored in x0 and x1 for now
	mov x1, ebx
	mov ebx, (EECS205BITMAP PTR[edx]).dwWidth
	sar ebx, 1				; divide width by 2 
	add x1, ebx 			; xcenter + halfofwidth to find x1
	sub x0, ebx    			; xcenter - halfofwidth to find x0


	mov ebx, ycenter		
	mov y0, ebx				;ycenter value stored in y0 and y1 for now
	mov y1, ebx
	mov ebx, (EECS205BITMAP PTR[edx]).dwHeight
	sar ebx, 1				; divide height by 2 
	add y1, ebx 			; ycenter + halfofheight to find y1
	sub y0, ebx    			; ycenter - halfofheight to find y0

it_x: 
	mov ebx, x1
	mov ecx, x0
	cmp ebx, ecx 
	jle it_y  						;if x1<= x0, jump to it_y 

	mov ecx, (EECS205BITMAP PTR [edx]).lpBytes
	mov esi, ind
	mov al, tran_c
	mov bl, BYTE PTR [ecx + esi]
	movzx ebx, bl 
	cmp al, bl 			; compare the transcolor to the color
	je BREAK
	Invoke DrawPixel, x0, y0, ebx

BREAK: 
	inc x0 
	inc ind 
	jmp it_x

it_y:
	mov ebx, y1
	inc y0
	mov ecx, y0
	cmp ebx, ecx
	jle DONE 		; if y1<=y0, done

	mov ebx, (EECS205BITMAP PTR [edx]).dwWidth
	sub x0, ebx 		; reset x0
	jmp it_x			; return to loop

DONE: 
	ret 			; Don't delete this line!!!	
BasicBlit ENDP



RotateBlit PROC USES eax ebx edx esi ecx edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
LOCAL cosa: DWORD, sina: DWORD, ind: DWORD, shiftx:DWORD, shifty: DWORD, dst_w:DWORD, dst_h:DWORD, dst_x: DWORD, dst_y:DWORD, srcx:DWORD, srcy:DWORD, tran_c: BYTE, drawx:DWORD, drawy:DWORD

	Invoke FixedCos, angle
	mov cosa, eax
	Invoke FixedSin, angle
	mov sina, eax
	mov ind, 0

	mov esi, lpBmp

	mov bl, (EECS205BITMAP PTR [esi]).bTransparent
	mov tran_c, bl				;store trans color

	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	sal eax, 16
	mov ebx, cosa
	imul ebx				;dwWidth*cosa
	mov shiftx, edx
	sar shiftx, 1 				;divided by 2


	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	sal eax, 16
	mov ebx, sina			
	imul ebx 				;dwHeight*sina
	sar edx, 1 				;divided by 2
	sub shiftx, edx
	;sar shiftx, 16 			; convert shiftx to int


	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	sal eax, 16
	mov ebx, cosa
	imul ebx
	mov shifty, edx
	sar shifty, 1			;divided by 2

	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	sal eax, 16
	mov ebx, sina
	imul ebx
	sar edx, 1
	add shifty, edx	
	;sar shifty, 16 

	mov eax, (EECS205BITMAP PTR [esi]).dwWidth	
	mov ebx, (EECS205BITMAP PTR [esi]).dwHeight	
	add eax, ebx 
	mov dst_w, eax 				; dst_w= dwWidth+dwHeight
	mov dst_h, eax				; dst_h= dwWidth+dwHeight

	neg eax
	mov dst_x, eax 				;set dst_x to negative dst_w
	mov dst_y, eax				;set dst_y to negative dst_h

	jmp O_LOOP

R_LOOP:

	mov eax, dst_x
	sal eax, 16
	mov ebx, cosa
	imul ebx 		;dst_x*cosa 
	mov srcx, edx
	mov eax, dst_y
	sal eax, 16
	mov ebx, sina
	imul ebx 		;dst_y*sina
	add srcx, edx 
	;sar srcx, 16 	; make int

	mov eax, dst_y
	sal eax, 16
	mov ebx, cosa
	imul ebx 		;dsty*cosa 
	mov srcy, edx

	mov eax, dst_x
	sal eax, 16
	mov ebx, sina
	imul ebx
	sub srcy, edx
	;sar srcy, 16


 
    mov eax, srcx
	cmp eax, 0
	jl YPLUS
	cmp eax, (EECS205BITMAP PTR [esi]).dwWidth	
	jg YPLUS

	mov eax, srcy
	cmp eax, 0
	jl YPLUS
	cmp eax, (EECS205BITMAP PTR [esi]).dwHeight
    jg YPLUS

 
	mov eax, dst_x
	mov ebx, xcenter 
	add eax, ebx
	mov ecx, shiftx
	sub eax, ecx
	cmp eax, 0
	jl YPLUS			;if xcenter + dstx-shiftx isnt g/e to 0, skip ahead
	cmp eax, 639
	jge YPLUS


	mov eax, ycenter
	mov ebx, dst_y
	add eax, ebx
	mov ecx, shifty
	sub eax, ecx
	cmp eax, 0
	jl YPLUS
	cmp eax, 479
	jge YPLUS


	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	mul srcy
	mov edi, eax
	add edi, srcx 			;finding color by dwWidth*y + x
	add edi, (EECS205BITMAP PTR [esi]).lpBytes
	mov eax, edi

	mov dl, BYTE PTR [eax]
	mov cl, tran_c
	cmp dl, cl 
	je YPLUS			;checks if transparent 

	mov ebx, xcenter
	mov ecx, dst_x
	add ebx, ecx 
	mov ecx, shiftx 
	sub ebx, ecx
	mov drawx, ebx

	mov ebx, ycenter
	mov ecx, dst_y
	add ebx, ecx
	mov ecx, shifty
	sub ebx, ecx 
	mov drawy, ebx
	invoke DrawPixel, drawx, drawy, BYTE PTR [eax]


YPLUS: 
	inc dst_y

I_LOOP:

	mov eax, dst_y
	mov ebx, dst_h
	cmp eax, ebx
	jl R_LOOP
	inc dst_x


O_LOOP: 
	mov eax, dst_h
	neg eax
	mov dst_y, eax
	mov eax, dst_x
	mov ebx, dst_w
	cmp eax, ebx
	jl I_LOOP

	
	ret 			; Don't delete this line!!!		
RotateBlit ENDP

END





