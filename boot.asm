    org 0x7c00  ; Boot 状态, Bios 将把 Boot Sector 加载到 0:7C00 处并开始执行


BaseOfStack     equ 0x7c00  ; Boot状态下堆栈基地址(栈底, 从这个位置向低地址生长)
BaseOfLoader    equ 0x1000  ; LOADER.BIN 被加载到的位置 ----  段地址
OffsetOfLoader  equ 0x00    ; LOADER.BIN 被加载到的位置 ---- 偏移地址

RootDirSectors          equ 14  ; 根目录占用空间
SectorNumOfRootDirStart equ 19  ; Root Directory 的第一个扇区号
SectorNumofFAT1Start     equ 1   ; FAT1 的第一个扇区号 = BPB_RsvdSecCnt
SectorBalance           equ 17  ;BPB_RsvdSecCnt + (BPB_NumFATs * FATSz) - 2

    jmp short Label_Start       ;跳转到入口
    nop                         ; 这个 nop 不可少
    BS_OEMName  db 'MINEboot'   ; OEM String
    BPB_BytesPerSec  dw 512     ; 每扇区字节数
    BPB_SecPerClus  db 1        ; 每簇多少扇区
    BPB_RsvdSecCnt  dw 1        ; Boot 记录占用多少扇区
    BPB_NumFATs  db 2           ; 共有多少 FAT 表
    BPB_RootEntCnt  dw 224      ; 根目录文件数最大值
    BPB_TotSec16  dw 2880     ; 逻辑扇区总数
    BPB_Media  db 0xf0          ; 媒体描述符
    BPB_FATSz16  dw 9           ; 每FAT扇区数
    BPB_SecPerTrk  dw 18      ; 每磁道扇区数
    BPB_NumHeads  dw 2          ; 磁头数(面数)
    BPB_HiddSec  dd 0           ; 隐藏扇区数
    BS_TotSec32  dd 0           ; 如果 wTotalSectorCount 是 0 由这个值记录扇区数
    BS_DrvNum  db 0             ; 磁盘驱动号
    BS_Reserved1  db 0          ; 未使用    
    BS_BootSig  db 0x29          ; 扩展引导标记 (29h)
    BS_VolID  dd 0              ; 卷序列号
    BS_VolLab db 'boot loader'  ; 卷标
    BS_FileSysType  db  'FAT12   ' ; 文件系统类型

Label_Start:
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,BaseOfStack

;===============clear screen

    mov ax,0600h
    mov bx,0700h
    mov cx,0
    mov dx,0184fh
    int 10h

;================set focus

    mov ax,0200h
    mov bx,0000h
    mov dx,0000h
    int 10h

;================display on screen:Start Booting...

    mov ax,1301h
    mov bx,000fh
    mov dx,0000h
    mov cx,10
    push ax
    mov ax,ds
    mov es,ax
    pop ax
    mov bp,StartBootMessage
    int 10h

;================reset floppy
    xor ah,ah           
    xor dl,dl
    int 13h         ;软驱复位

;======================search loader.bin===========================
    mov     word    [SectorNo],     SectorNumOfRootDirStart

Label_Search_In_Root_Dir_Begin:
    cmp     word    [RootDirSizeForLoop],   0   ; ┓
    jz      Label_No_LoaderBin                  ; ┣ 判断根目录区是不是已经读完
    dec     word    [RootDirSizeForLoop]        ; ┛ 如果读完表示没有找到 LOADER.BIN
    mov     ax,     00h
    mov     es,     ax
    mov     bx,     8000h
    mov     ax,     [SectorNo]
    mov     cl,     1
    call    Func_ReadOneSector  ;[0x000000007c9a] 0000:7c9a (unk. ctxt): call .+53 (0x00007cd2)    ; e83500
    mov     si,     LoaderFileName
    mov     di,     8000h
    cld
    mov     dx,     10h

Label_Search_For_LoaderBin:
    cmp     dx,     0
    jz      Label_Goto_Next_Sector_In_Root_Dir
    dec     dx
    mov     cx,     11

Label_Cmp_FileName:
    cmp     cx,     0
    jz      Label_FileName_Found    ; 如果比较了 11 个字符都相等, 表示找到
    dec     cx
    lodsb                           ; ds:si -> al
    cmp     al,     byte    [es:di]
    jz      Label_Go_On
    jmp     Label_Different         ; 只要发现不一样的字符就表明本 DirectoryEntry 不是
                                    ; 要找的 LOADER.BIN
Label_Go_On:
    inc     di
    jmp     Label_Cmp_FileName

Label_Different:
    and     di,     0ffe0h          ;di &= E0 为了让它指向本条目开头
    add     di,     20h
	mov	    si,     LoaderFileName					;      ┣ di += 20h  下一个目录条目
    jmp     Label_Search_For_LoaderBin  ;di += 20h  下一个目录条目

Label_Goto_Next_Sector_In_Root_Dir:

    add     word    [SectorNo],     1
    jmp     Label_Search_In_Root_Dir_Begin

;======================display on screen: ERROR:No LOADER Found===========================
Label_No_LoaderBin:
    mov     ax,     1301h
    mov     bx,     008ch
    mov     dx,     0100h
    mov     cx,     21
    push    ax
    mov     ax,     ds
    mov     es,     ax
    pop     ax
    mov     bp,     NoLoaderMessage
    int     10h
    jmp     $

;======= found loader.bin name in root director struct====================
Label_FileName_Found:
    mov     ax,     RootDirSectors          
    and     di,     0ffe0h                  ;di->当前条目的开始
    add     di,     01ah                    ;di->首Sector
    mov     cx,     word            [es:di]
    push    cx                              ;保存此Sector在FAT中的序号
    add     cx,     ax
    add     cx,     SectorBalance
    mov     ax,     BaseOfLoader
    mov     es,     ax
    mov     bx,     OffsetOfLoader          ;bx<-OffsetOfLoader
    mov     ax,     cx                      ;ax<-Sector号

Label_Go_On_Loading_File:
    push    ax
    push    bx
    mov     ah,      0eh
    mov     al,     '.'
    mov     bl,     0fh
    int     10h
    pop     bx
    pop     ax

    mov     cl,    1
    call    Func_ReadOneSector
    pop     ax
    call    Func_GetFATEntry
    cmp     ax,     0fffh
    jz      Label_File_Loaded
    push    ax
    mov     dx,     RootDirSectors
    add     ax,     dx
    add     ax,     SectorBalance
    add     bx,     [BPB_BytesPerSec]
    jmp     Label_Go_On_Loading_File

Label_File_Loaded:
    jmp     BaseOfLoader:OffsetOfLoader



;======================read one sector from floppy===========================
; 函数名: ReadSector
;----------------------------------------------------------------------------
; 作用:
;	从第 ax 个 Sector 开始, 将 cl 个 Sector 读入 es:bx 中
Func_ReadOneSector:

    push    bp
    mov     bp,     sp
    sub     esp,    2
    mov     byte    [bp-2],     cl
    ;xor     ah,     ah
    push    bx
    mov     bl,     [BPB_SecPerTrk]
    div     bl
    inc     ah
    mov     cl,     ah          ;起始扇区号
    mov     dh,     al          ;磁头号
    shr     al,     1           ;y >> 1 (其实是 y/BPB_NumHeads, 这里BPB_NumHeads=2)
    mov     ch,     al          ;磁道号,也称柱面号
    and     dh,     1           ;dh & 1 = 磁头号 
    pop     bx                  ;恢复 bx 
     ; 至此, "柱面号, 起始扇区, 磁头号" 全部得到
    mov     dl,     [BS_DrvNum] ;驱动器号（0表示软盘A）

Label_Go_On_Reading:
    mov     ah,     2                ; 读 
    mov     al,     byte    [bp-2]  ;读取的扇区数
    int     13h
    jc   Label_Go_On_Reading        ;如果读取错误 CF 会被置为 1, 这时就不停地读, 直到正确为止
    add     esp,    2
    pop     bp
    ret



;======================get FAT Entry===========================
; 函数名: GetFATEntry
;----------------------------------------------------------------------------
; 作用:
;	找到序号为 ax 的 Sector 在 FAT 中的条目, 结果放在 ax 中
;	需要注意的是, 中间需要读 FAT 的扇区到 es:bx 处, 所以函数一开始保存了 es 和 bx
Func_GetFATEntry:
    push    es
    push    bx
    push    ax
    mov     ax,     00
    ;mov	ax, BaseOfLoader    ;  这两句在一起等价于mov     ax,     00
	;sub	ax, 0100h	        ;  在 BaseOfLoader 后面留出 4K 空间用于存放 FAT
    mov     es,     ax
    pop     ax
    mov     byte    [Odd],     0
    mov     bx,     3
    mul     bx
    mov     bx,     2
    ;xor     dx,     dx
    div     bx                      ;
    cmp     dx,     0
    jz      Label_Even
    mov     byte    [Odd],      1

Label_Even:
    xor     dx,     dx
    mov     bx,     [BPB_BytesPerSec]
    div     bx
    push    dx
    mov     bx,     8000h                  ; bx <- 0 于是, es:bx = (BaseOfLoader - 100):00
    add     ax,     SectorNumofFAT1Start
    mov     cl,     2
    call    Func_ReadOneSector

    pop     dx
    add     bx,     dx
    mov     ax,     [es:bx]
    cmp     byte    [Odd],      1
    jnz     Label_Even_2
    shr     ax,     4

Label_Even_2:
    and     ax,     0fffh
    pop     bx
    pop     es
    ret



;======= tmp variable============
RootDirSizeForLoop  dw      RootDirSectors
SectorNo            dw      0
Odd                 db      0

;======= display  messages============
StartBootMessage    db      "Start Boot"
NoLoaderMessage     db      "ERROR:No Loader Found"
LoaderFileName      db      "LOADER  BIN",0

;================fill zero until whole sector

    times 510- ( $ - $$ ) db 0
    dw 0xaa55


