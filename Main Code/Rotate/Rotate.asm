;*******************************************************************************
;		Amirkabir University of Technology		*
;							*
;	Written by:			Reza Hedayati	*
;							*
;	Student Number: 			94123026	*	
;							*		
;	Date:				21/02/2009	*
;*******************************************************************************
;		 Main.asm
;		-main boot loader
;		- this code is loaded into memory from 0x500
;**************************************************
;User memory space: 0x500 - 0xA0000(638.75KB)
;stack memory: 0x9F000-0xA0000 (4KB)-SS=0x9F00,SP=0x1000
;image buffer space: > 0x10000	:ES=0x1000,Bx=0x00
bits	16
org		0x500
%define new_line 10
%define cret 13
start:	jmp 	main
bootdevice		db 0
ImageName   	db "GRAPHIC1BMP";"PICTURE BMP"
RM_msg1			db	new_line,cret," Operating mode: Real",new_line,cret,0
RM_msg2			db	" Preparing to load image file (Picture.bmp)...",new_line,cret,0
RM_msg3			db	new_line,cret," Press 'P' key to switch to protected mode.",new_line,cret,0
Load_Segment	dw 0x1000	;File will be loaded into 0x10000
Load_Offset		dw 0		;
%define			VIDMEM	0xB8000			; video memory
vector			dd	0x33333333
				dd  0x33333333
%define GRAPHIC_MEM 0xa0000
%define IMAGE_BASE 0x10000


IMG_offset dd 0
IMG_width dd 0
IMG_height dd 0
;*********************************************
;	included parts
;*********************************************
%include "stdio.inc"
%include "stdio16.inc"
%include "Floppy16.inc"
%include "Load_File.inc"
%include "Gdt.inc"
%include "A20.inc"
%include "common.inc"
%include "set_vga.inc"
;*********************************************
;	Bootloader Entry Point
;*********************************************
main:
;---------------------------------------------
;adjust segment registers
;---------------------------------------------   
		cli	
		push	cs		;CS=0x500
		pop		ax
        mov     ds, ax	;DS=0x500
        mov     es, ax	;ES=0x500
;---------------------------------------------
; create stack
;---------------------------------------------
        mov     ax, 0x9F00
        mov     ss, ax
        mov     sp, 0x1000
		
		mov		ah,0
		mov		al,0x3
		int		10h
;---------------------------------------------
;
;---------------------------------------------
		call	_EnableA20
		call	InstallGDT
        sti
        mov  [bootdevice], dl
;---------------------------------------------
;show welcome message
;---------------------------------------------
		call	Init_Text
		call	ShowWellcome
		;call	Real_Mode_Message
		mov		si,RM_msg1
		call	Print16
		mov		si,RM_msg2
		call	Print16
		mov		word [Load_Segment],0x1000
		mov		word [Load_Offset],0x00
		call	Load_File
		mov		si,RM_msg3
		call	Print16	
;----------------------------
;wait for key press
		mov		ah,0x00
PM_wait_loop:
		int		16h
		cmp		al,'p'
		jne		PM_wait_loop
		mov		al,03h	;initializes graphical mode
		mov		ah,00h	;
		int		10h		;
		;----------------------
EnterStage3:
	xor		ax, ax             ; null segments
	mov		ds, ax
	cli	                           ; clear interrupts
	mov	eax, cr0                   ; set bit 0 in cr0--enter pmode
	or	eax, 1
	mov	cr0, eax

	jmp	CODE_DESC:Stage3                ; far jump to fix CS. Remember that the code selector is 0x8!


;******************************************************
;	ENTRY POINT FOR STAGE 3
;******************************************************

bits 32

BadImage db "Welcome to protected mode!", 0

Stage3:
	mov	ax, DATA_DESC		; set data segments to data selector (0x10)
	mov	ds, ax
	mov	ss, ax
	mov	es, ax
	mov	esp, 0x1000000		; stack begins from 90000h
;*******************************************
; Main Function()
;*******************************************
inverse:

 ;get BMP information
        mov esi, IMAGE_BASE
        mov eax, DWORD[esi+10]
        mov DWORD[IMG_offset],eax

        mov eax, DWORD[esi+18]
        mov DWORD[IMG_width],eax

		mov eax, DWORD[esi+22]
        mov DWORD[IMG_height],eax

	  
	    ;write color pallete in VGA
		mov esi, IMAGE_BASE
		mov eax, DWORD[esi+14]       ;eax contains size of DIB header		
		add eax, 14                  ;14 is the size of main header
		add esi, eax                 ;esi points to the beginning of color palette
		
		mov al, 0                    ;send index of the color to port 0x3c8
		mov dx, 0x3c8
		out dx,al
		
		inc dx                       ;color components must be sent to port 0x3c9 (with the order: R G B)
		
		mov cx, 256                  ;cx (loop controller) contains number of colors in the palette
		
write_pal3:
		mov al, BYTE[esi+2]
		shr al, 2
		out dx, al
		
		mov al, BYTE[esi+1]
		shr al, 2
		out dx, al
		
		mov al, BYTE[esi]
		shr al, 2
		out dx, al
		
		add esi, 4
		loop write_pal3
       
    
   
	call write_vga_reg
    mov esi, IMAGE_BASE               ;esi points to the beginning of BMP image (0x10000)
	mov eax, DWORD[IMG_offset]        ;offset of beginning of pure image data stored in eax
	add esi, eax                      ;esi points to the beginning of pure image data
   
    mov edi, GRAPHIC_MEM

	mov eax, DWORD[IMG_width]
	mul DWORD[IMG_height]
	shr eax, 3
	mov ecx, eax                      ;ecx contains (total number of pixels/8)
	

next2:	
	MOVQ mm0, [esi]
	MOVQ [edi], mm0
	add esi, 8
	add edi, 8
    loop next2
	
	;ret

here:	
		jmp		here
%include "ShowBMP.inc"