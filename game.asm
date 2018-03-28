; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;	Ishaan Madan ibm6989
;
; #########################################################################

;;; In this game, ths player can use the up,down,right, and left keys to dodge the sprites
;;; One of the sprites moves at a non-constant velocity
;;; Scoring increment varies based on which sprite the user avoids- if he/she avoids a faster sprite, 
;;; he/she gets more points
;;; there is also music 
;;; space bar pauses the game, and enter allows the user to re-enter the game
;;; the game ends when the user is hit by a sprite 

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc

;; Has keycodes
include keys.inc

;sound
include C:\masm32\include\windows.inc
include C:\masm32\include\winmm.inc
includelib C:\masm32\lib\winmm.lib

;print and random
include C:\masm32\include\user32.inc
includelib C:\masm32\lib\user32.lib
include C:\masm32\include\masm32.inc
includelib C:\masm32\lib\masm32.lib

	
.DATA

bradyX FXPT ? 
bradyY FXPT ? 
bradyptr DWORD ?


russX FXPT ?
russY FXPT ?
russang FXPT ?
russptr DWORD ? 
russspeed DWORD ?

fbLX FXPT ?
fbLY FXPT ?
fbLang FXPT ?
fbLptr DWORD ?
fbLspeed DWORD ?

fbMX FXPT ?
fbMY FXPT ?
fbMang FXPT ?
fbMptr DWORD ?
fbMspeed DWORD ?

wildX FXPT ? 
wildY FXPT ?
wildang FXPT ? 
wildptr DWORD ?
wildspeed DWORD ?

fbRX FXPT ?
fbRY FXPT ?
fbRang FXPT ?
fbRptr DWORD ?
fbRspeed DWORD ?


pausevar BYTE 0
gamevar BYTE 0
Gindex DWORD 0

pauseString BYTE "Game Paused Press Enter to Continue.", 0
overString BYTE "The game is over! Press the P key to play again", 0

sndPath BYTE "scuseme.wav",0

score DWORD 0

fmtStr BYTE "Score: %d",0
outStr BYTE 256 DUP (0)



.CODE

CheckIntersect PROC USES ebx ecx esi edi edx oneX: DWORD, oneY: DWORD, oneBitmap:PTR EECS205BITMAP, 
twoX: DWORD, twoY: DWORD, twoBitmap: PTR EECS205BITMAP

 	mov ebx, oneBitmap
	mov ecx, twoBitmap


	mov esi, (EECS205BITMAP PTR[ebx]).dwWidth
	sar esi, 1		;bitmap.width/2
	mov eax, oneX
	sub eax, esi  	; one.x-bitmap.width/2	--> horizontal left side of object 1

	mov edi, (EECS205BITMAP PTR[ecx]).dwWidth
	sar edi, 1
	mov edx, twoX
	add edx, edi ; two.x+bitmap.width/2	--> horizontal right side of object 2

	cmp eax, edx 
	jge No_I 


	mov esi, (EECS205BITMAP PTR[ebx]).dwWidth
	sar esi, 1		;bitmap.width/2
	mov eax, oneX
	add eax, esi  	; one.x+bitmap.width/2	--> horizontal right side of object 1

	mov edi, (EECS205BITMAP PTR[ecx]).dwWidth
	sar edi, 1
	mov edx, twoX
	sub edx, edi ; two.x-bitmap.width/2	--> horizontal left side of object 2

	cmp eax, edx 
	jle No_I 


	;; same process for vertical, check top and bottom boundaries 

	mov esi, (EECS205BITMAP PTR [ebx]).dwHeight
	sar esi, 1
	mov eax, oneY
	add eax, esi

	mov edi, (EECS205BITMAP PTR [ecx]).dwHeight
	sar edi, 1
	mov edx, twoY
	sub edx, edi

	cmp eax, edx 
	jle No_I

	mov esi,(EECS205BITMAP PTR [ebx]).dwHeight
	sar esi, 1
	mov eax, oneY
	sub eax, esi

	mov edi, (EECS205BITMAP PTR [ecx]).dwHeight
	sar edi, 1
	mov edx, twoY
	add edx, edi

	cmp eax, edx
	jge No_I


	;;intersect here
	mov eax, 1
	jmp DONE

No_I: 
	mov eax, 0 ;; if they dont intersect, return 0 

DONE: 
	ret

CheckIntersect ENDP



drawScoreMethod PROC uses ebx
	rdtsc
	mov ebx, score
	push ebx
	push offset fmtStr
	push offset outStr
	call wsprintf
	add esp, 12 
	invoke DrawStr, offset outStr, 85, 350, 0ffh
	ret
drawScoreMethod endP




GameInit PROC uses esi
	mov esi, OFFSET brady2small
	mov bradyptr, esi
	mov bradyX, 320
	mov bradyY, 400
	invoke BasicBlit, bradyptr, bradyX, bradyY

	mov esi, OFFSET lynch2small
	mov fbLptr, esi
	mov fbLX, 100
	mov fbLY, 50
	mov fbLang, 0
	mov fbLspeed, 1
	invoke BasicBlit, fbLptr, fbLX, fbLY

	mov esi, OFFSET lynch2small
	mov fbMptr, esi
	mov fbMX, 330
	mov fbMY, 50
	mov fbMang, 0
	mov fbMspeed, 13
	invoke BasicBlit, fbMptr, fbMX, fbMY

	mov esi, OFFSET lynch2small
	mov fbRptr, esi
	mov fbRX, 545
	mov fbRY, 50
	mov fbRang, 0
	mov fbRspeed, 12
	invoke BasicBlit, fbRptr, fbRX, fbRY


	mov esi, OFFSET lynch2small
	mov russptr, esi
	mov russX, 70
	mov russY, 100
	mov russang, 0
	mov russspeed, 10
	invoke BasicBlit, russptr, russX, russY

	mov esi, OFFSET lynch2small
	mov wildptr, esi
	mov wildX, 600
	mov wildY, 360
	mov wildang, 0
	mov wildspeed, 8
	invoke BasicBlit, wildptr, wildX, wildY

	rdtsc
	invoke nseed, eax


	invoke PlaySound, offset sndPath, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP ;;;SOUND! 

	ret         
GameInit ENDP





GamePlay PROC uses ecx ebx

	cmp gamevar, 1
	je DONE 


	mov ebx, KeyPress
	cmp ebx, VK_SPACE
	jne checkcont
	mov pausevar, 1
	jmp checkp

checkcont:
	cmp KeyPress, 0dh ;;enter
	jne checkp
	mov pausevar, 0

checkp:
	invoke DrawStr, offset pauseString, 100, 240, 0ffh
	cmp pausevar,1
	jne START
	jmp DONE


START: 
	mov gamevar, 0
	invoke BlackStarField
	invoke DrawStarField
	invoke BasicBlit, bradyptr, bradyX, bradyY 
	invoke BasicBlit, fbLptr, fbLX, fbLY
	invoke BasicBlit, fbMptr, fbMX, fbMY
	invoke BasicBlit, fbRptr, fbRX, fbRY
	invoke BasicBlit, russptr, russX, russY
	invoke BasicBlit, wildptr, wildX, wildY 
	invoke drawScoreMethod

	mov ecx, fbLspeed	;;;;;acceleration piece
	mov eax, 2
	imul ecx
	mov fbLspeed, eax
	mov ebx, fbLspeed
	add fbLY, ebx
	invoke BasicBlit, fbLptr, fbLX, fbLY 
	cmp fbLY, 304
	je fbLfix

	mov ebx, fbMspeed
	add fbMY, ebx
	invoke BasicBlit, fbMptr, fbMX, fbMY 
	cmp fbMY, 479
	je fbMfix


	mov ebx, fbRspeed
	add fbRY, ebx
	invoke BasicBlit, fbRptr, fbRX, fbRY 
	cmp fbRY, 458
	je fbRfix


	mov ebx, russspeed
	add russX, ebx
	invoke BasicBlit, russptr, russX, russY 
	cmp russX, 640
	je russfix

	mov ebx, wildspeed
	sub wildX, ebx
	invoke BasicBlit, wildptr, wildX, wildY
	cmp wildX, 0
	je wildfix 



	invoke CheckIntersect, bradyX, bradyY, bradyptr, fbLX, fbLY, fbLptr
	cmp eax, 0
	jne gameover
	invoke CheckIntersect, bradyX, bradyY, bradyptr, fbMX, fbMY, fbMptr
	cmp eax, 0
	jne gameover
	invoke CheckIntersect, bradyX, bradyY, bradyptr, fbRX, fbRY, fbRptr
	cmp eax, 0
	jne gameover
	invoke CheckIntersect, bradyX, bradyY, bradyptr, russX, russY, russptr
	cmp eax, 0
	jne gameover
	invoke CheckIntersect, bradyX, bradyY, bradyptr, wildX, wildY, wildptr
	cmp eax, 0
	jne gameover



	mov ecx, KeyPress

	cmp ecx, VK_UP 
	je UP_B

	cmp ecx, VK_DOWN
	je DOWN_B

	cmp ecx, VK_LEFT
	je LEFT_B

	cmp ecx, VK_RIGHT
	je RIGHT_B

	jmp DONE


UP_B: 
	cmp bradyY, 0		;check if brady is running to the top of the screen
	je TOPBOUND
	cmp bradyY, 10
	je TOPBOUND
	cmp bradyY, 5
	je TOPBOUND

	sub bradyY, 15
	invoke BasicBlit, bradyptr, bradyX, bradyY
	jmp DONE


DOWN_B: 
	cmp bradyY, 475	;check if brady is running to the botoom of the screen
	je BottomBound
	cmp bradyY, 480 	;check if brady is running to the botoom of the screen
	je BottomBound
	cmp bradyY, 470 	;check if brady is running to the botoom of the screen
	je BottomBound
	add bradyY, 15
	invoke BasicBlit, bradyptr, bradyX, bradyY
	jmp DONE


LEFT_B: 
	cmp bradyX, 0
	je LeftBound
	cmp bradyX, 5
	je LeftBound
	cmp bradyX, 10
	je LeftBound

	sub bradyX, 15
	invoke BasicBlit, bradyptr, bradyX, bradyY
	jmp DONE

RIGHT_B: 
	cmp bradyX, 640
	je RightBound
	cmp bradyX, 635
	je RightBound
	cmp bradyX, 630
	je RightBound
	add bradyX, 15
	invoke BasicBlit, bradyptr, bradyX, bradyY
	jmp DONE

TOPBOUND: 
	;;make it seem like screen is round and running to top will bring him up from the bottom
	mov bradyY, 460
	invoke BasicBlit, bradyptr, bradyX, bradyY
	jmp DONE

BottomBound: 
	;;make it seem like screen is round and running to bottom will bring him down from the top
	mov bradyY, 10
	invoke BasicBlit, bradyptr, bradyX, bradyY
	jmp DONE

RightBound: 
	;;make it seem like screen is round and running to right will bring him around from the left 
	mov bradyX, 10
	invoke BasicBlit, bradyptr, bradyX, bradyY
	jmp DONE

LeftBound:
	;;make it seem like screen is round and running to left will bring him around from the right 
	mov bradyX, 620
	invoke BasicBlit, bradyptr, bradyX, bradyY

fbLfix:
	add score, 50  ;;since this piece is the accelerating piece, the score increment for this piece is the highest
	mov fbLY, 50
	mov fbLspeed, 1
	invoke BasicBlit, fbLptr, fbLX, fbLY
	jmp printscore

fbMfix:
	add score, 26		;score increment is double the velocity 
	mov fbMY, 50
	invoke BasicBlit, fbLptr, fbLX, fbLY
	jmp DONE
	jmp printscore

fbRfix:
	add score, 24		;score inncrement is double the velocity
	mov fbRY, 50
	invoke BasicBlit, fbLptr, fbLX, fbLY
	jmp DONE
	jmp printscore

russfix: 
	add score, 20		;score increment is double the veloicty 
	mov russX, 160
	invoke BasicBlit, russptr, russX, russY
	jmp printscore

wildfix: 
	add score, 16 		;score increment is double the velocity 
	mov wildX, 600
	invoke BasicBlit, wildptr, wildX, wildY
	jmp printscore

gameover:
	mov gamevar, 1
	invoke DrawStr, offset overString, 200, 200, 0ffh
	


printscore: 
	invoke drawScoreMethod
	
DONE: 
	mov ecx, KeyPress
	cmp ecx, VK_P
	jne DONEREAL
	invoke GameInit
	mov gamevar, 0
	mov score, 0

DONEREAL:

	ret    

GamePlay ENDP

END
