mov ah, 0x0e ; tty mode

mov al, [the_secret]
int 0x10

; 设置段ds寄存器为0x7c00
mov bx, 0x7c0 ; 注意 the segment is automatically <<4 for you
mov ds, bx
; 注意从现在开始所有的内存引用都将隐式的基于ds的 offset 计算 (0x7c0 + )
mov al, [the_secret] ;(0x7c0 + [the_secret])
int 0x10

mov al, [es:the_secret]
int 0x10 ; doesn't look right... isn't 'es' currently 0x000?

; 设置es寄存器为0x7c0
mov bx, 0x7c0
mov es, bx
mov al, [es:the_secret]
int 0x10


the_secret:
    db 'X'
jmp $

times 510-($-$$) db 0
dw 0xaa55
