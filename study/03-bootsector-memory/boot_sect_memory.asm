mov ah, 0x0e ; 设置TTY model


;第一次尝试 错误 要使用[the_secret]
; 16位寄存器ax低位放入al
mov al, "1"
; 调用中断输出
int 0x10
;将the_secret位置的数据放入al中
mov al, the_secret
;调用BIOS 视频服务中断 输出
;  发现是失败的 什么都没输出
int 0x10


;第二次尝试 错误 需要添加地址的偏移
;bios会把我们的引导扇区(512 byte)的数据加载到内存的0x7C00(线性地址)
;0x0000:0x7C00 (段:偏移)
; 16位寄存器ax低位放入al
mov al, "2"
; 调用中断输出
int 0x10
mov al, [the_secret]
int 0x10



;第三次尝试
;我们先将the_secret这个地址值放到bx寄存器中，然后加上0x7c00  然后把计算后地址的数据移入al
mov al, "3"
; 调用中断输出
int 0x10
mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10


;第四次尝试
;我们自己口头计算好 我们知道 the_secret的位置在 0x2b
mov al, "4"
; 调用中断输出
int 0x10
mov al, [0x7c2b]
int 0x10


the_secret:
    db 'X'

; zero padding and magic bios number
times 510-($-$$) db 0
dw 0xaa55