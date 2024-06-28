[BITS 16]                   ; 16 Bit mode (in real mode)
[ORG 0x7c00]                ; supposed to run at memory location 0x7c00 -> BIOS loads code from first sector to address 0x7c00

start:
    xor ax,ax               ; set registers to 0
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00           ; init stack pointer

PrintMessage:
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

Message:    db "Hello"
MessageLen: equ $-Message

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