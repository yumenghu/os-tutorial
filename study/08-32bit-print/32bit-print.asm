[bits 32]
;定义一个常量  video 的内存地址
VIDEO_MEMORY equ 0xb8000
;定义一个常量 字符的颜色
WHITE_ON_BLACK equ 0x0f

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