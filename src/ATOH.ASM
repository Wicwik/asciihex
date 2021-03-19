TITLE Asci to hex module
	.MODEL small

	.STACK 100h
	P486N

	.DATA
	hexchars db '0123456789ABCDEF'

	.CODE

; buffer and hexstr is from another file
extrn buffer: byte
extrn hexstr: byte

; make artefacts public, allowing them to be accesed from other files
public ascii_to_hex

; convers ascii char to hexadecimal number
; and store it to hexstring
ascii_to_hex:
	mov bx, offset hexchars			; set bx to begining of hexchars string
	mov al, [buffer] 				; set al, to address of buffer
	mov ah, al 						; ah == al
	and al, 00001111b 				; zero out the top 4 bits
	xlat 							; set al to next char DS:[BX + AL]
	mov [hexstr + 1], al 			; set hexstr to al value
	
	shr ax, 12 						; shift right for the upper 4 bits
	xlat 							; set al to next char DS:[BX + AL]
	mov hexstr, al 					; set hexstr to al value

	ret

end