[org 0x7c00]

; --- 设置栈 ---
mov bp, 0x9000
mov sp, bp

; --- 实模式打印 ---
mov bx, msg_real
call print_real

; --- 切换到保护模式 ---
call switch_to_pm

; --- 保护模式打印串口 ---
mov ebx, msg_pm
call print_pm_serial

jmp $  ; 死循环停在这里

; -----------------------
; 实模式打印字符串，调用 BIOS int 0x10 teletype 输出
print_real:
    pusha
print_real_loop:
    mov al, [bx]
    cmp al, 0
    je print_real_done
    mov ah, 0x0e
    int 0x10
    inc bx
    jmp print_real_loop
print_real_done:
    popa
    ret

; 保护模式串口打印字符串
print_pm_serial:
    pusha
pm_serial_loop:
    mov al, [ebx]
    cmp al, 0
    je pm_serial_done
    mov bl, al
    call print_char_pm
    inc ebx
    jmp pm_serial_loop
pm_serial_done:
    popa
    ret

; 保护模式串口单字符打印（COM1 端口 0x3F8）
print_char_pm:
    mov dx, 0x3f8          ; COM1 端口
.wait:
    mov dx, 0x3fd   ; 端口地址 = COM1 base + 5
    in al, dx           ; 读取 Line Status Register
    test al, 0x20          ; 等待发送缓冲区空
    jz .wait
    mov al, bl
    out dx, al
    ret

; 保护模式切换
switch_to_pm:
    cli                    ; 关中断
    lgdt [gdt_descriptor]  ; 加载 GDT

    mov eax, cr0
    or eax, 1              ; 设置保护模式标志位 PE
    mov cr0, eax

    jmp CODE_SEG:init_pm   ; 跳转到保护模式代码段

; 保护模式代码段入口
[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000       ; 设置堆栈指针

    ret

; -----------------------
; GDT 段定义
[bits 16]
gdt_start:
gdt_null:
    dd 0x00000000
    dd 0x00000000

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; -----------------------
msg_real db "Hello from Real Mode!",0
msg_pm db "Hello from Protected Mode (via serial)!",0

times 510-($-$$) db 0
dw 0xaa55
