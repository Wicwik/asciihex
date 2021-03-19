TITLE File management module

; include required modules
include atoh.inc
include utils.inc
include time.inc


	.MODEL small

	.STACK 100h
	P486N

	.DATA
		estr db 'Nastala chyba$'	; error string definition
		fn db 'FILE.TXT',"$" 		; filename string definition
		file_handle dw ? 			; file handle word definition

		buffer db 2 dup('$') 		; buffer containing 1 char and $ termination
		hexstr db 3 dup ('$') 		; buffer containing 2 chars and $ termination

		charcounter dw 0 			; read char counter definition
		chars_in_row dw 0			; printed chars in row counter definition
		rowscounter dw 0			; printed row counter definition

		; press any key string definition, tabbed from datetime string
		pagestr db 9,9,9,9," "," "," ","Press any key to continue...", "$"

		directory db 1024 dup('$')	; directory string definition
	.CODE

; make artefacts public, allowing them to be accessed from other files
public buffer
public hexstr
public fileopen
public fileread
public fileread_paging
public fileclose
public endprog
public print_number_noc

;print content of ax as colored number
print_number PROC
	mov bx, 10						; divisor for printing the number in decimal
	xor cx, cx						; clear cx register

	; iterate until zero and save each digit into stack
	digsave_loop:
		xor dx, dx
		div bx
		add dx, '0'
		push dx

		inc cx						; keep track on number of digits
		cmp ax, 0
		jne digsave_loop

	; pop digits from stack and print them in color
	digprint_loop:
		; save important registers to stack
		push ax
		push bx
		push cx

		mov ah,09h					; bios video color seting
		mov bl,09h					; color based on http://stackoverflow.com/q/12556973/3512216
		mov cx, 1					; single char
		int 10h 					; bios interupt
		
		; pop important registers from stack
		pop cx
		pop bx
		pop ax

		; print digits poped from stack until cx is zero
		pop dx
		mov ah, 02h
		int 21h
		dec cx
		cmp cx, 0
		jne digprint_loop

		ret
print_number ENDP


; same as print number, but no color
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


; procedure that counts digits of a number in ax as input, cx output
n_digits PROC
	xor cx, cx						; clear cx register
	mov bx, 10						; decimal digits

	; in loop increment cx until end of the number
	digit_loop:
		xor dx, dx
		div bx

		inc cx
		cmp ax, 0
		jne digit_loop

		ret
n_digits ENDP

; procedure to open a file
fileopen PROC
	mov dx, offset fn 				; set dx to filename
	mov al, 0 						; open for reading
	
	mov ah, 3Dh 					; set ah to fileopen service number
	int 21h 						; DOS interupt

	jc error 						; check if file could be opened

	mov file_handle, ax 			; save file handle

	mov charcounter, 0 				; set charcounter to zero

	ret
fileopen ENDP

; procedure that reads one byte from file, transforms gets hexadecimal value and prints it to screen
; first char of each row is replaced by distance of the current char in file from start
fileread PROC
mov chars_in_row, 0					; set chars in row counter to zero

; read chars until end of file
read_loop:
	mov bx, file_handle 			; get file handle
	mov cx, 1 						; read one byte
	mov dx, offset buffer 			; set start buffer to dx

	mov ah, 3Fh 					; set ah to fileread service number
	int 21h 						; DOS interupt
	jc error

	cmp ax,0						; check if end of file
	jz end_of_file					; if yes, go to end

	call ascii_to_hex				; else covert buffer to hexadecimal and save it to hexchar

	cmp chars_in_row, 0				; check, if printing the firs char
	je print_charcounter 			; if yes, print distance from first character

	cmp chars_in_row, 80 			; else, check, if chars in row are greater than size of the line
	jg print_charcounter 			; if yes, print distance from first character 

	jmp print_hexa 					; else print ascii character in hexadecimal

; prints charcounter - distance from first char
print_charcounter:
	modulo chars_in_row, 2 			; checks if even number of chars is printed (this is checked due to first number in line could have odd number of digits)
	cmp dx, 0 						
	je skip_nl 						; if yes, dont print new line

	print_char 13 					; else print CR, LF
	print_char 10

skip_nl:
	mov ax, charcounter 			; print colored number
	call print_number

	mov ax, charcounter 			; count digits of printed number
	call n_digits

	mov chars_in_row, cx 			; set this number of digits to char_in_row counter
	jmp addchars 					; don't print hexstr this time

print_hexa:
	print hexstr 					; print hexstring on line

addchars:
	inc charcounter 				; increment charcounter
	add chars_in_row, 2 			; add chars in row the number of cols printed
	jmp read_loop  					; go back to the start of the loop

end_of_file:
	ret
fileread ENDP

; procedure that reads one byte from file, transforms gets hexadecimal value and prints it to screen
; first char of each row is replaced by distance of the current char in file from start
; also waits for user input on full screen and shows datetime and full path to file
fileread_paging PROC
mov chars_in_row, 0 				; set chars in row counter to zero
mov rowscounter, 0 					; we also need to count number of rows printed

call get_cwd 						; get the current working directory
call add_slash 						; add backslash to end

; this part is the same as the non paging procedure
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
	cmp rowscounter, 23 			; check if rowcounter is 23 (we leave 2 rows for the time and filepath)
	je pnext_page 					; if we aleready printed 23 rows, we go to the next page handling
	jmp pprint_charcounter 			; else we continue to printing characters

pnext_page:
	modulo chars_in_row, 2 			; same checking if we printet odd or even number of chars
	cmp dx, 0 						
	je no_nl 						; if even, dont print CR, LF
	print_char 13
	print_char 10

no_nl:
	mov ax, offset directory 		; get cwd string len
	call strlen
	
	push bx 						; save it for later

	mov ax, offset fn 				; get filename string len
	call strlen

	pop dx 							; pop cwd len to dx
	add bx, dx 						; get full length full file path
	dec bx 							; its also counted with $, so dec 1

	cmp bx, 80 						; if full file path is longer than 80 chars
	jg filename_only 				; print only filename

	print directory 				; print directory
	print_char 8 					; backpace 1 char

filename_only:
	print fn 						; print filename
	print_char 13 					; print CR LF
	print_char 10
	inc rowscounter 				; increment rowcounter

	call prepare_datetime 			; get current datetime
	print date 						; print date and delimiters
	print_char ' '
	print_char '-'
	print_char '-'
	print_char ' '
	print time 						; print time
	print pagestr 					; print press any key string
	inc rowscounter 				; increment rowscounter

	mov ah, 08h 					; set ah to get key from keyboard service call
	mov al,0 						; zero out al
	int 21h 						; dos interupt
	cmp al, 0
	jz pnext_page 					; if al is zero no key was pressed, go to top of the loop

	clscr 							; else clear screen
	mov rowscounter, 0 				; set rowscounter to 0

pprint_charcounter:
	modulo chars_in_row, 2 			; after this its the same as no paging procedure
	cmp dx, 0
	je pskip_nl

	print_char 13
	print_char 10

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

; procedure for closing the file
fileclose PROC
	mov bx, file_handle 			; set bx to file handle

	mov ah, 3EH 					; set ah to file close service number
	int 21h 						; DOS interupt

	jc error 						; check for errors

	ret
fileclose ENDP


get_cwd:
	mov ah, 47h 					; set ah to get cwd service call number
	mov dl, 0 						; set dl to 0 (device 0)
	mov si, offset directory 		; set si to directory string begining
	int 21h 						; DOS interupt

	ret

add_slash:
	mov si, offset directory 		; set si to directory string begining
	xor bx, bx 						; clear bx
	findend:
		mov al, byte [si + bx] 		; add current byte to al

		inc bx 						; increment byte counter
		cmp al, 36 					; check if al is $
		jne findend 				; if not go to begining of the loop

	dec bx 							; go back by one byte
	mov [si + bx], 92 				; replace space with backslash

	ret

; get length of string, ax - input string, bx - output string length
strlen:
	mov si, ax 						; move ax to si
	xor bx, bx 						; clear bx
	next_byte:
		mov al, byte [si + bx] 		; iterate trough string
		inc bx

		cmp al, 36 					
		jne next_byte 				; if not end of string continue looping

	ret

error:
	print estr 						; print error string and end the program
	jmp endprog

endprog:
	mov ax, 4C00h		; go back to DOS service call number
	int 21h				; DOS interupt

END