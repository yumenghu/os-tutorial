; 设置 TTY模式
mov ah, 0x0e
; 把字符H 放到AX寄存器的低位
mov al, 'H'
; 调用 BIOS 显示中断
int 0x10
mov al, 'e'
; 调用 BIOS 显示中断
int 0x10
mov al, 'l'
; 调用 BIOS 显示中断
int 0x10
; al 的寄存器还放着l, 所以不用使用mov指令, 调用 BIOS 显示中断
int 0x10
mov al, 'o'
; 跳转到当前的内存位置
int 0x10

jmp $

times 510 -($ - $$) db 0

dw 0xaa55
