disk_load:
    ;保持所有的寄存器的值到栈中
    pusha
    ;我们在调用的时候会先设置一下dx的值作为传入的值  但是我们不是保存的两次dx?

    ;单独保存一下dx寄存器的值
    push dx

    ; cylinder = LBA / (heads * sectors)
    ; head     = (LBA / sectors) % heads
    ; sector   = (LBA % sectors) + 1   ; 注意 BIOS 扇区号从 1 开始

    mov ah, 0x02 ; int 0x13 function. 0x02 = 'read'
    mov al, dh
    mov cl, 0x02 ; cl <- sector (0x01 .. 0x11)
                 ; 0x01 is our boot sector, 0x02 is the first 'available' sector
    mov ch, 0x00 ; 柱面设置占用了 ch寄存器(cx的高位)8位 加上  cl(寄存器的高2位) 总共10位

    ; (0 = floppy, 1 = floppy2, 0x80 = hdd, 0x81 = hdd2)
    ;在启动的时候自动设置好了 软盘 0x00  硬盘 0x80
    ; mov dl, 0x00
    ;设置磁头号码  软盘有两个磁头 硬盘16个
    mov dh, 0x00 ; dh <- head number (0x0 .. 0xF)


    ;调用中断 数据会被读入[es:bx]的内存为止
    int 0x13      ; BIOS interrupt
    jc disk_error ; if error (stored in the carry bit)

    pop dx
    cmp al, dh    ; BIOS also sets 'al' to the # of sectors read. Compare it.
    jne sectors_error
    popa
    ret

disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah ; ah = error code, dl = disk drive that dropped the error
    call print_hex ; check out the code at http://stanislavs.org/helppc/int_13-1.html
    jmp disk_loop


sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0