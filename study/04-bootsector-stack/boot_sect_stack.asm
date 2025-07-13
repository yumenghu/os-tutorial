mov ah, 0x0e ;tty mode

;bios 加载数据到内存的0x7c00 +512 = 0x7E00 到了文件的末尾
;我们设置为0x8000 sp会向下增在变小  但是大概率不会碰到 0x7E00 除非我们一直压栈
; 每次 push 会执行：SP := SP - 2，然后将 16 位的数据写入 [SS:SP]
; 所以栈以字为单位压栈（每次 2 字节）
mov bp, 0x8000
; 如果栈是空的, sp寄存器指向bp
mov sp, bp

;压栈操作
push 'A'
push 'B'
push 'C'

;A
mov al, [0x8000 - 2]
int 0x10
;B
mov al, [0x8000 - 4]
int 0x10
;C
mov al, [0x8000 - 6]
int 0x10

;我们只能访问栈职中的其他值  不允许访问0x8000  错误
mov al, [0x8000]
int 0x10

;从栈中弹出一个数据(栈顶)到bx寄存器中,本例子中是C  C是最后push的
pop bx
mov al, bl
int 0x10

;从栈中弹出一个数据(栈顶)到bx寄存器中,本例子中是B  C已经弹出了 B就是最后的了
pop bx
mov al, bl
int 0x10

;从栈中弹出一个数据(栈顶)到bx寄存器中,本例子中是A  B已经弹出了 A就是最后的了
pop bx
mov al, bl
int 0x10

; 所有的数据都已经被弹出了栈就回收了
mov al, [0x8000]
int 0x10


th_secret:
    db 'X'


times 510-($-$$) db 0
dw 0xaa55