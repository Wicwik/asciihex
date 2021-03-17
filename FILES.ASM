TITLE File management module

include atoh.inc
include utils.inc

public buffer
public hexstr

	.MODEL small

	.STACK 100h
	P486N

	.DATA
		estr db 'Nastala chyba$'
		fn db 'FILE.TXT',0
		file_handle dw ?

		buffer db 2 dup('$')
		hexstr db 3 dup ('$')

		charcounter dw 0
		chars_in_row dw 0
		rowscounter dw 0

		pagestr db "Press any key to continue...", "$"
	.CODE

public fileopen
public fileread
public fileread_paging
public fileclose
public endprog

;ax input
print_number PROC
	mov bx, 10
	xor cx, cx

	digsave_loop:
		xor dx, dx
		div bx
		add dx, '0'
		push dx

		inc cx
		cmp ax, 0
		jne digsave_loop

	digprint_loop:
		push ax
		push bx
		push cx
		mov ah,09h
		mov bl,06h
		mov cx, 1
		int 10h
		pop cx
		pop bx
		pop ax

		pop dx
		mov ah, 02h
		int 21h
		dec cx
		cmp cx, 0
		jne digprint_loop

		ret
print_number ENDP


print_number_noc PROC
	mov bx, 10
	xor cx, cx

	ndigsave_loop:
		xor dx, dx
		div bx
		add dx, '0'
		push dx

		inc cx
		cmp ax, 0
		jne ndigsave_loop

	ndigprint_loop:
		pop dx
		mov ah, 02h
		int 21h
		dec cx
		cmp cx, 0
		jne ndigprint_loop

		ret
print_number_noc ENDP


;ax input, cx output
n_digits PROC
	xor cx, cx
	mov bx, 10

	digit_loop:
		xor dx, dx
		div bx

		inc cx
		cmp ax, 0
		jne digit_loop

		ret
n_digits ENDP

fileopen PROC
	mov dx, offset fn
	mov al, 0
	
	mov ah, 3Dh
	int 21h

	jc error

	mov file_handle, ax

	mov charcounter, 0

	ret
fileopen ENDP

; macro for file reading
fileread PROC
mov chars_in_row, 0

read_loop:
	mov bx, file_handle
	mov cx, 1
	mov dx, offset buffer

	mov ah, 3Fh
	int 21h
	jc error

	cmp ax,0
	jz end_of_file

	call ascii_to_hex

	cmp chars_in_row, 0
	je print_charcounter

	cmp chars_in_row, 80
	jg print_charcounter

	jmp print_hexa

print_charcounter:
	modulo chars_in_row, 2
	cmp dx, 0
	je skip_nl

	print_char 10
	print_char 13

skip_nl:
	mov ax, charcounter
	call print_number

	mov ax, charcounter
	call n_digits

	mov chars_in_row, cx
	jmp addchars

print_hexa:
	print hexstr

addchars:
	inc charcounter
	add chars_in_row, 2
	jmp read_loop

end_of_file:
	ret
fileread ENDP

fileread_paging PROC
mov chars_in_row, 0
mov rowscounter, 0

pread_loop:
	mov bx, file_handle
	mov cx, 1
	mov dx, offset buffer

	mov ah, 3Fh
	int 21h
	jc error

	cmp ax,0
	jz pend_of_file

	call ascii_to_hex

	cmp chars_in_row, 0
	je pprint_charcounter

	cmp chars_in_row, 80
	jg pcheck_endpage

	jmp pprint_hexa

pcheck_endpage:
	cmp rowscounter, 24
	je pnext_page
	jmp pprint_charcounter

pnext_page:
	modulo chars_in_row, 2
	cmp dx, 0
	je no_nl
	print_char 10
	print_char 13

no_nl:
	print pagestr
	inc rowscounter

	mov ah, 08h
	mov al,0
	int 21h
	cmp al, 0
	jz pnext_page

	clscr
	mov rowscounter, 0

pprint_charcounter:
	modulo chars_in_row, 2
	cmp dx, 0
	je pskip_nl

	print_char 10
	print_char 13

pskip_nl:
	mov ax, charcounter
	call print_number 

	mov ax, charcounter
	call n_digits
	mov chars_in_row, cx

	inc rowscounter
	jmp paddchars

pprint_hexa:
	print hexstr

paddchars:
	inc charcounter
	add chars_in_row, 2
	jmp pread_loop

pend_of_file:
	ret
fileread_paging ENDP

; macro for file closing
fileclose PROC
	mov bx, file_handle

	mov ah, 3EH
	int 21h

	jc error

	ret
fileclose ENDP

error:
	print estr
	jmp endprog

endprog:
	mov ax, 4C00h		; podporgram pre navrat do DOS
	int 21h				; prerusenie na vykonanie podporogramu

END