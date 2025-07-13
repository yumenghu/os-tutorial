[org 0x7c00] ; bootloader offset
    mov bp, 0x9000 ;set the stack
    mov sp, bp

    mov bx, MSG_REAL_MODE
    call print
    call print

    call switch_to_pm

    jmp $ ; this will actually never be executed

print:
    pusha
start:
    mov al, [bx] ; 'bx' is the base address for the string
    cmp al, 0
    je done

    mov ah, 0x0e
    int 0x10 ; 'al' already contains the char

    add bx, 1
    jmp start

done:
    popa
    ret
print_nl:
    pusha

    mov ah, 0x0e
    mov al, 0x0a ; newline char
    int 0x10
    mov al, 0x0d ; carriage return
    int 0x10

    popa
    ret

gdt_start:

gdt_null:; GDT 第一个段：必须是空的
    dd 0x00000000       ; 低 4 字节 = 0
    dd 0x00000000       ; 高 4 字节 = 0

; GDT for code segment. base = 0x00000000, length = 0xfffff
; for flags, refer to os-dev.pdf document, page 36
gdt_code:
    dw 0xffff ; Limit[15:0]
    dw 0x0000 ; Base[15:0]
    db 0x00 ; segment base, bits 16-23
    db 10011010b ; flags (8 bits)
    db 11001111b ; flags (4 bits) + segment length, bits 16-19
    db 0x0       ; segment base, bits 24-31

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size (16 bit), always one less of its true size
    dd gdt_start ; address (32 bit)

; define some constants for later use
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


[bits 16]
switch_to_pm:
    cli ;1. disable interrupts
    lgdt [gdt_descriptor] ; 2. load the GDT descriptor
    mov eax, cr0
    or eax, 0x1 ; 3. set 32-bit mode bit in cr0
    mov cr0, eax
    jmp CODE_SEG:init_pm ; 4. far jump by using a different segment

[bits 32]
init_pm: ; we are now using 32-bit instructions
    mov ax, DATA_SEG ; 5. update the segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; 6. update the stack right at the top of the free space
    mov esp, ebp

    call BEGIN_PM ; 7. Call a well-known label with useful code

[bits 32]

BEGIN_PM: ; after the switch we will get here
    mov ebx, MSG_PROT_MODE
    call print_pm_serial ; Note that this will be written at the top left corner
    jmp $

;定义一个常量  video 的内存地址
VIDEO_MEMORY equ 0xb8000
;定义一个常量 字符的颜色
WHITE_ON_BLACK equ 0x0f

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

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY

print_string_pm_loop:
    mov al, [ebx]  ;[ebx] 是我们字符的地址
    mov ah, WHITE_ON_BLACK
    cmp al, 0 ;校验是否字符是 否是0如果是 就返回
    je print_string_pm_done
    mov [edx], ax ; 把字符和设置字符的属性存储到VIDEO_MEMORY
    add ebx, 1 ;开始读取下一个字符
    add edx, 2 ;开始设置下一个VIDEO_MEMORY 每一个char的占用两个byte

    jmp print_string_pm_loop

print_string_pm_done:
    popa
    ret

MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_PROT_MODE db "Loaded 32-bit protected mode", 0


; bootsector
times 510-($-$$) db 0
dw 0xaa55