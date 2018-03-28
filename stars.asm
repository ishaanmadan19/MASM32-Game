; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;	Ishaan Madan
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc
	;Initilzes 16 stars on 640X480 screen in position x,y
	Invoke DrawStar, 200, 200
	Invoke DrawStar, 100,100
	Invoke DrawStar, 19, 300
	Invoke DrawStar, 154, 345
	Invoke DrawStar, 4, 34
	Invoke DrawStar, 533, 111
	Invoke DrawStar, 564, 36
	Invoke DrawStar, 253, 243
	Invoke DrawStar, 54, 242
	Invoke DrawStar, 3, 33
	Invoke DrawStar, 253, 420
	Invoke DrawStar, 234, 342
	Invoke DrawStar, 187, 124
	Invoke DrawStar, 423, 234
	Invoke DrawStar, 99, 43
	Invoke DrawStar, 626, 53
	Invoke DrawStar, 250, 100

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
