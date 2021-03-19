TITLE Time management module
	.MODEL small

	.STACK 100h
	P486N

	.DATA
		date db "00/00/0000","$"	; date pattern string definition
		time db "00:00:00","$"		; time pattern string definition

	.CODE
; simple macro calling get date service
get_date MACRO
	mov ah, 04h						; set ah to date service number
	int 1Ah							; interupt to call the service

ENDM get_date

; simple macro calling get time service
get_time MACRO
	mov ah, 02h						; set ah to time service number
	int 1Ah							; interupt to call the service

ENDM get_time

; make artefacts public, allowing them to be accesed from other files
public prepare_datetime
public time
public date

; date and time string preparation
prepare_datetime:
	get_date						; date service call
	mov bx, offset date  			; set bx to the beggining of date string
	mov al, dl						; move day number to al register
	call to_string					; move the number to the date string

	inc bx							; move to next byte
	mov al, dh						; move month to al register
	call to_string					; move the number to the date string

	inc bx							; move to next byte
	mov al, ch						; move decade to al register
	call to_string					; move the number to the date string
	mov al, cl 						; move year to al register
	call to_string 					; move the number to the date string

	get_time						; time service call
	mov bx, offset time 			; set bx to the beggining of time string
	mov al, ch 						; move hour number to al register 
	call to_string 					; move the number to the time string

	inc bx							; move to next byte
	mov al, cl 						; move hour minute to al register
	call to_string 					; move the number to the time string

	inc bx 							; move to next byte
	mov al, dh 						; move hour second to al register
	call to_string  				; move the number to the time string

	ret 							; return to call

; add content of al, to string
to_string:
	push ax							; save ax to stack
	shr ax, 4						; shift ax 4 bits to right
	and ax, 0Fh 					; get only the lower bits
	add ax, '0' 					; add 0 char number to it
	mov [bx], al 					; move it to the string at bx position
	inc bx 							; move to next position
	pop ax 							; get back ax from stack

	and ax, 0Fh 					; get number without shifting
	add ax, '0' 					; add 0 char number to it
	mov [bx], al 					; move it to the string at bx position

	inc bx 							; skip : or / chars, or move to next byte

	ret

END