use16
org 0x0000

; Hier werden konstante Variabeln definiert, die waehrend der Laufzeit undveraendert bleiben sollen
section .data
    sys_version_var db "1.0.3",0

main:
mov ax, 0x07e0
mov ds, ax
mov es, ax
call cls
call beep
mov si, welcome
call print

shell_loop:
call prompt
call read_input
mov si, input_buffer
call check_command
jmp shell_loop

print:
lodsb
cmp al, 0
je done
mov ah, 0x0E
int 0x10
jmp print
done:
ret

cls:
mov ah, 0x00
mov al, 0x03
int 0x10
ret

prompt:
mov si, prompt_msg
call print
ret

; Keyboard Treiber :D

read_input:
mov di, input_buffer
mov cx, 31              ; max 31 Zeichen + 0 Terminator

.read_char:
mov ah, 0
int 0x16

cmp al, 0x0D
je .done

cmp al, 0x08
je .backspace

cmp cx, 0               ; Buffer voll?
je .read_char           ; weitere Eingabe ignorieren

stosb
dec cx

mov ah, 0x0E
int 0x10
jmp .read_char

.backspace:
cmp di, input_buffer
je .read_char

inc cx
dec di

mov ah, 0x0E
mov al, 0x08
int 0x10
mov al, ' '
int 0x10
mov al, 0x08
int 0x10
jmp .read_char

.done:
mov al, 0
stosb

mov ah, 0x0E
mov al, 0x0D
int 0x10
mov al, 0x0A
int 0x10
ret


; Checkt ob Command existiert

check_command:
mov si, input_buffer
mov di, info_cmd
call str_eq
cmp al, 1
je do_info

mov si, input_buffer
mov di, cls_cmd
call str_eq
cmp al, 1
je do_cls

mov si, input_buffer
mov di, beep_cmd
call str_eq
cmp al, 1
je do_beep

mov si, input_buffer
mov di, why_cmd
call str_eq
cmp al, 1
je do_why

mov si, input_buffer
mov di, sys_version
call str_eq
cmp al, 1
je do_version

; Neue Zeile, wird am Ende von Commands angewendet f?r eine sch?ne, nicht verbuggte neue Zeile

mov si, unknown_msg
call print
call newline
ret


; Command functions

do_info:
mov si, info_msg
call print
call newline
ret

do_cls:
mov si, cls_msg
call cls
call newline
ret

do_beep:
call beep
;call newline
ret

do_why:
mov si, why_msg
call print
call newline
ret

do_version:
mov si, sys_version_msg
call print

mov si, sys_version_var
call print

call newline
ret

;Printet eine neue Zeile damit der Prompt nicht wie am Anfang beim why-command im Text landet und ihn damit unterbricht
newline:
mov ah, 0x0E
mov al, 0x0D
int 0x10
mov al, 0x0A
int 0x10
ret

str_eq:
.next_char:
lodsb
cmp al, [di]
jne .not_equal
cmp al, 0
je .equal
inc di
jmp .next_char
.not_equal:
mov al, 0
ret
.equal:
mov al, 1
ret

beep:
mov al, 0b10110110
out 0x43, al
mov ax, 1193
out 0x42, al
mov al, ah
out 0x42, al
in al, 0x61
mov bl, al
or al, 11b
out 0x61, al
mov cx, 0FFFFh
.b1:
nop
loop .b1
mov al, bl
out 0x61, al
ret

;Was muss f?r do_info in die Konsole geschrieben werden? Was soll geantwortet werden? Das regelt dieser Bereich hier :D

;Wichtigste Definierungen f?r die Shell
welcome: db "GSSLOS v1.0",0x0A,0
prompt_msg: db "[#] ",0
input_buffer: times 32 db 0

;Command Ein- und Ausgaben
info_cmd: db "info",0
info_msg: db "GotSSLOS written in pure ASM by @jontsgame with few tutorials from @gotssl. 2026",0x0A,0
cls_cmd: db "cls",0
cls_msg: db "Terminal cleared",0x0A,0
beep_cmd: db "beep",0
why_cmd: db "why",0
why_msg: db "Oh... you ask why? So... I don't know hehe :3",0x0A,0 ; I just do it because Low-Level coding makes fun :D or maybe it is just what programmers doing when they are depressed... learning Assembly and making an OS in it... NAHHHH just kidding I am not depressed I am just having so much fun seeing how my own OS fully written in Assembly grows :D also shoutout to that dude called @gotssl on YouTube, you are the best, thanks! Even if you are just having 2 tutorials, you helped me a lot! So... YOU ARE IN THE CREDTS YAYYYY :P",0x0A,0
sys_version: db "sys version",0
sys_version_msg: db "System Up-to-date: Version: ",0x0A,0
unknown_msg: db "Unknown command",0x0A,0