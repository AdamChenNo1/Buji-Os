RootDirSectors          equ 14  ; 根目录占用空间
SectorNumOfRootDirStart equ 19  ; Root Directory 的第一个扇区号
SectorNumofFAT1Start     equ 1   ; FAT1 的第一个扇区号 = BPB_RsvdSecCnt
SectorBalance           equ 17  ;BPB_RsvdSecCnt + (BPB_NumFATs * FATSz) - 2

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
    BS_BootSig  db 29h          ; 扩展引导标记 (29h)
    BS_VolID  dd 0              ; 卷序列号
    BS_VolLab db 'boot loader'  ; 卷标
    BS_FileSysType  db  'FAT12   ' ; 文件系统类型
