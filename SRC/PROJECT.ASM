; Zadanie: Vypísať obsah vstupu v hexadecimálnom tvare. Na začiatku každého riadku vypísať posunutie prvej vypisovanej hodnoty od začiatku.

TITLE Project to write hexvalue of ascii chars

include files.inc ; include file management module
include utils.inc ; include utilities like print or print_char

	.MODEL small

	.STACK 100h
	P486N

	.DATA
		; help string definition
		helpstr db "ASCII TO HEX CONVERTOR PROGRAM by Robert Belanec",13,10,"Usage: PROJECT.EXE [-h | -p] file",13,10,9,"-h",9,"print this help message",13,10,9,"-p",9,"enable paging","$"
	.CODE
main:
	mov ax, @DATA 				; set datasegmet to DS register
	mov ds, ax

	lea bx, byte ptr es:[81h]	; set bx to first byte of PSP
read_args:
	inc bx						; go to next byte
	mov dl, es:[bx]				; move it to dl register
	cmp dl, '-'					; check if its '-'
	jz is_arg					; if its '-', go to argument proccesing
	jmp files 					; else go to file processing

is_arg:
	inc bx						; go to next byte
	mov dl, es:[bx]				; save it to dl register

	cmp dl, 'h'					; check if its 'h'
	jz help 					; if its 'h', go to help print

	cmp dl, 'p'					; check if its 'p'
	jz files_paging   			; if its 'p', go to file processing with paging

	jmp files					; else go to file processing

help:
	print helpstr				; print help

	jmp endprog					; go back to DOS

files:
	dec bx
	dec bx
	call read_filename		; try to read filename from args

	call fileopen				; open file
	call fileread 				; read and process file
	call fileclose 				; close file
	
	jmp endprog

files_paging:
	call read_filename		; try to read filename from args

	call fileopen				; open file
	call fileread_paging		; read and process file with paging
	call fileclose				; close file

	jmp endprog

END main