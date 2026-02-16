use16
ORG 0x7C00

mov si, text_string
call print_string

jmp $

text_string db '==> Loading GSSLOS',13,10,0

print_string:
        mov ah, 0x0E ; int 10h 'print char' function
_repeat:
        lodsb
        cmp al,0
        je loadkern     ; If char is zero, end of string
        int 10h                 ; Otherwise, print it
        jmp _repeat

loadkern: 
cld                ; Clear direction flag to ensure instructions like
                   ;    lodsb use forward movement.

xor ax, ax         ; AX=0 (use for segment)
mov ss, ax
mov sp, 0x7c00     ; Set up stack to grow down from 0x0000:0x07c00
                   ;    in region below the bootloader

mov es, ax         ; Read sector starting at 0x0000:0x7e00 (ES:BX)
mov bx, 0x7e00

mov ah, 2
mov al, 1
mov ch, 0
mov cl, 2
mov dh, 0
; mov dl, 0        ; Don't force to zero. Use value in DL passed by BIOS
                   ;     to our bootloader
int 13h

jmp 0x0000:0x7e00  ; Jump to physical address 0x07e00 by setting CS
                   ;     to 0 and IP to 0x7e00

times 510 - ($-$$) db 0
dw 0xAA55