; clear screen
clscr MACRO
	mov ax, 0003h
	int 10h
ENDM clscr

; print single char
print_char MACRO char
	mov dl, char

	mov ah, 02h
	int 21h
ENDM print_char

; macro for string printing
print MACRO string	
	mov dx, offset string
	
	mov ah, 09h
	int 21h
ENDM print


; delenie a zaroven modulo, zvysok najdeme v registri dx a kvocient v registri ax
modulo MACRO divident, divisor
	mov ax, divident
	xor dx, dx

	mov bx, divisor
	div bx
ENDM modulo