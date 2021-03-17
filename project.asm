; Vypísať obsah vstupu v hexadecimálnom tvare. Na začiatku každého riadku vypísať posunutie prvej vypisovanej hodnoty od začiatku.

TITLE Project to write hexvalue of ascii chars

include files.inc
include utils.inc

	.MODEL small

	.STACK 100h
	P486N

	.DATA
	helpstr db "ASCII TO HEX CONVERTOR PROGRAM by Robert Belanec",10,13,"Usage: PROJECT.EXE [options]",10,13,9,"-h",9,"print this help message",10,13,9,"-p",9,"enable paging","$"

	.CODE
main:
	lea bx, byte ptr ds:[81h]
read_args:
	inc bx
	mov dl, ds:[bx]
	cmp dl, '-'
	jz is_arg
	jmp files

is_arg:
	inc bx
	mov dl, ds:[bx]

	cmp dl, 'h'
	jz help

	cmp dl, 'p'
	jz files_paging

	jmp files	

help:
	mov ax, @DATA
	mov ds, ax
	print helpstr

	jmp endprog

files:
	mov ax, @DATA
	mov ds, ax
	call fileopen
	call fileread
	call fileclose
	
	jmp endprog

files_paging:
	mov ax, @DATA
	mov ds, ax
	call fileopen
	call fileread_paging
	call fileclose

	jmp endprog

END main