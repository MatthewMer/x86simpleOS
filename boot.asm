; This is done by following a tutorial series and the main intention of comments is to make it easier for the reader to read the code 
; as well as a reminder for myself as this is a learning process for me 
; (having written an emulator makes it way more approchabele and easier to understand though as they fundamentally work similar or even the same)

[BITS 16]                   ; 16 Bit mode (in real mode)
[ORG 0x7c00]                ; supposed to run at memory location 0x7c00 -> BIOS loads code from first sector to address 0x7c00

start:
    xor ax,ax               ; set registers to 0
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00           ; init stack pointer

TestDiskExtension:
    mov [DriveId],dl
    mov ah,0x41
    mov bx,0x55aa
    int 0x13                ; sets carry flag if disk extension service not supported
    jc NotSupported         ; jump if carry
    cmp bx,0xaa55           ; compare bx -> neq -> disk extension service not supported
    jne NotSupported        ; jump not equal

LoadLoader:
    mov si,ReadPacket       ; load structure
    mov word[si],0x10       ; offset 0: size
    mov word[si+2],5        ; offset 2: num sectors
    mov word[si+4],0x7e00   ; offset 4: offset loader
    mov word[si+6],0        ; offset 6: segment
    mov dword[si+8],1       ; offset 8: address lo
    mov dword[si+0xc],0     ; offset 0xc: address hi
    mov dl,[DriveId]
    mov ah,0x42             ; use disk extension service
    int 0x13                ; read sectors -> fail: set carry flag
    jc ReadError

    mov dl,[DriveId]        ; store drive id in dl
    jmp 0x7e00              ; jump to loader at address 0x7e00

ReadError:
NotSupported:
    mov ah,0x13             ; ah = 0x13 == print string (function code in ah)
    mov al,1                ; al = 1 (write mode -> cursor placed at end of string)
    mov bx,0xa              ; bx (bh == page number, bl == character attributes)
    xor dx,dx               ; dx (dh == rows, dl == columns)
    mov bp,Message          ; bp == address of variable to print
    mov cx,MessageLen       ; cx == number of characters to print
    int 0x10

End:
    hlt
    jmp End

DriveId:    db 0
Message:    db "boot process error"
MessageLen: equ $-Message
ReadPacket: times 16 db 0   ; structure used for interrupt vector 0x13 -> read sectors of loader

times (0x1be-($-$$)) db 0   ; ($-$$) -> start of code minus end of message
    ; boot entry    -> boot USB flash drive as hard disk (not e.g. floppy disk)
    db 80h                  ; boot indicator
    db 0,2,0                ; starting CHS
    db 0f0h                 ; type
    db 0ffh,0ffh,0ffh       ; ending CHS
    dd 1                    ; starting sector
    dd (20*16*63-1)         ; size

    times (16*3) db 0

    db 0x55                 ; signature
    db 0xaa                 ; ...