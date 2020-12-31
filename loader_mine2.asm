org 10000h

    jmp     Label_Start

    %include    "fat12.inc"
    BaseOfKernelFile    equ     0x00
    OffsetOfKernelFile  equ     0x100000

    BaseTmpOfKernelFile equ     0x00
    OffsetTmpOfKernelFile  equ     0x7E00

    MemoryStructBufferAddr  equ     0x7E00
    
[SECTION gdt]

LABEL_GDT:		dd	0,0
LABEL_DESC_CODE32:	dd	0x0000FFFF,0x00CF9A00
LABEL_DESC_DATA32:	dd	0x0000FFFF,0x00CF9200

GdtLen	equ	$ - LABEL_GDT
GdtPtr	dw	GdtLen - 1
	dd	LABEL_GDT

SelectorCode32	equ	LABEL_DESC_CODE32 - LABEL_GDT
SelectorData32	equ	LABEL_DESC_DATA32 - LABEL_GDT


[SECTION .s16]
[BITS 16]

Label_Start:

    mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ax,	0x00
	mov	ss,	ax
	mov	sp,	0x7c00

;======= display on screen: Start Loader......

    mov     ax,     1301h
    mov     bx,     000fh
    mov     dx,     0200h
    mov     cx,     12
    push    ax
    mov     ax,     ds
    mov     es,     ax
    pop     ax
    mov     bp,     StartLoadingMessage
    int     10h

;======= enable address A20......
    push    ax
    in      al,     92h
    or      al,     00000010b
    out     92h,    al

    cli

    db      0x66
    lgdt    [GdtPtr]

    mov     eax,    cr0
    or      eax,    1
    mov     cr0,    eax

    mov     ax,     SelectorData32
    mov     fs,     ax
    mov     eax,    cr0
    and     al,     11111110b
    mov     cr0,    eax

    sti
    jmp     $
;======= display messages......

StartLoadingMessage:       db      "Start Loader"

    