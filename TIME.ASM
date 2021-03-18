TITLE Time management module
	.MODEL small

	.STACK 100h
	P486N

	.DATA
		date db "00/00/0000","$"
		time db "00:00:00","$"

	.CODE
get_date MACRO
	mov ah, 04h
	int 1Ah

ENDM get_date

get_time MACRO
	mov ah, 02h
	int 1Ah

ENDM get_time

public prepare_datetime
public time
public date

prepare_datetime:
	get_date
	mov bx, offset date
	mov al, dl
	call to_string

	inc bx
	mov al, dh
	call to_string

	inc bx
	mov al, ch
	call to_string
	mov al, cl
	call to_string

	get_time
	mov bx, offset time
	mov al, ch
	call to_string

	inc bx
	mov al, cl
	call to_string

	inc bx
	mov al, dh
	call to_string

	ret

to_string:
	push ax
	shr ax, 4
	and ax, 0Fh
	add ax, '0'
	mov [bx], al
	inc bx
	pop ax

	and ax, 0Fh
	add ax, '0'
	mov [bx], al

	inc bx

	ret

END