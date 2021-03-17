TITLE ASCII to HEX conversion

ascii_to_hex MACRO char, hexstr
	local hexchars

	.DATA
		hexchars db '0123456789ABCDEF'

	.CODE

	mov bx, offset hexchars
	mov al, char
	mov ah, al
	and al, 00001111b
	xlat

	mov [hexstr + 1], al
	shr ax, 12
	xlat
	mov hexstr, al
ENDM ascii_to_hex

	.MODEL small

	.STACK 100h
	P486N

	.DATA
		hexstr db 3 dup ('$')
	.CODE

main:
	mov ax, @DATA
	mov ds, ax

	ascii_to_hex 'A', hexstr

	mov dx, offset hexstr 

	mov ah, 09h
	int 21h

endprog:
	mov ax, 4C00h		; podporgram pre navrat do DOS
	int 21h				; prerusenie na vykonanie podporogramu

END main