TITLE asci to hex module
	.MODEL small

	.STACK 100h
	P486N

	.DATA
	hexchars db '0123456789ABCDEF'

	.CODE

		
public ascii_to_hex

extrn buffer:BYTE
extrn hexstr:BYTE

ascii_to_hex:
	mov bx, offset hexchars
	mov al, [buffer]
	mov ah, al
	and al, 00001111b
	xlat

	mov [hexstr + 1], al
	shr ax, 12
	xlat
	mov hexstr, al

	ret

end