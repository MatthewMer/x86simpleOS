[BITS 16]                   ; 16 Bit mode (in real mode)
[ORG 0x7e00]                ; supposed to run at memory location 0x7e00

start:
    mov [DriveId],dl        ; store passed drive id in DriveId

    mov eax,0x80000000
    cpuid
    cmp eax,0x80000001      ; checks if 0x80000001 (stored in eax) is supported by cpuid by comparing with result in eax
    jb NotSupported         ; jumps if result below 0x80000001

    mov eax,0x80000001
    cpuid                   ; reads cpu ident and feature info 
    test edx,(1<<29)        ; checks for long mode support
    jz NotSupported
    test edx,(1<<26)        ; checks for 1GB page support
    jz NotSupported

    mov ah,0x13             ; ah = 0x13 == print string (function code in ah)
    mov al,1                ; al = 1 (write mode -> cursor placed at end of string)
    mov bx,0xa              ; bx (bh == page number, bl == character attributes)
    xor dx,dx               ; dx (dh == rows, dl == columns)
    mov bp,Message          ; bp == address of variable to print
    mov cx,MessageLen       ; cx == number of characters to print
    int 0x10                ; call interrupt handler for vector 0x10 (print)

NotSupported:
End:
    hlt
    jmp End

DriveId:    db 0
Message:    db "Long mode supported"
MessageLen: equ $-Message