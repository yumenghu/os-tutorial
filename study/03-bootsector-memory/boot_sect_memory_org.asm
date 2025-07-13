[org 0x7c00]
mov ah, 0x0e ; ttymdoe

;第一种方式 错误 这种写法 the_secret 不代表内存地址
mov al, '1'
int 0x10
mov al, the_secret
int 0x10

;第二种方式 正确
mov al, '2'
int 0x10
mov al, [the_secret]
int 0x10

;第三次尝试 错误  我们加上两次
;我们先将the_secret这个地址值放到bx寄存器中，然后加上0x7c00  然后把计算后地址的数据移入al
mov al, "3"
; 调用中断输出
int 0x10
mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10

;第四次尝试 正确
;我们自己口头计算好 我们知道 the_secret的位置在 0x2b
mov al, "4"
; 调用中断输出
int 0x10
mov al, [0x7c2b]
int 0x10

the_secret:
    db 'X'

times 510-($-$$) db 0
dw 0xaa55
