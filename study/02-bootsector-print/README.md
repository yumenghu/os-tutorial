*Concepts you may want to Google beforehand: , CPU registers*

CPU registers
-------------
### 📋 常见 x86 寄存器一览表：

| 寄存器名                    | 类型                          | 描述                                                                 |
|-----------------------------|-------------------------------|----------------------------------------------------------------------|
| `EAX`, `EBX`, `ECX`, `EDX` | 通用寄存器                   | 可用于保存任意数据，部分指令默认使用特定寄存器（如乘法用 `EAX`）  |
| `ESP`                      | 栈指针寄存器（Stack Pointer） | 指向栈顶，控制函数调用/返回的压栈出栈行为                           |
| `EBP`                      | 栈基址寄存器（Base Pointer）  | 用作函数栈帧的基地址，便于访问函数参数和局部变量                   |
| `EIP`                      | 指令指针寄存器（Instruction Pointer） | 指向下一条将要执行的指令地址                             |
| `EFLAGS`                   | 标志寄存器                    | 包含各种状态位，如零标志（ZF）、进位标志（CF）、溢出标志（OF）等   |
| `CS`, `DS`, `SS`           | 段寄存器（Segment Register）  | 用于分段管理内存，如代码段（Code Segment）、数据段、堆栈段         |


interrupts
----------

👉 定义：
-------
中断是指 CPU 在执行当前程序时，被其他设备或事件打断，转而去处理其他事务 的一种机制。
就像你在写作业时突然接到电话，你会暂时停下写作业去接电话，电话结束后再回去继续写作业。

🧩 举例：
-------
键盘敲击 → 发出中断 → CPU 响应，读取按键数据。
定时器到期 → 发出中断 → CPU 执行定时处理程序。
网卡收到数据 → 发出中断 → 操作系统读取网络包。

🧠 类型：
-------
硬件中断（例如外设发出的中断）
软件中断（例如 int 0x80 是 Linux 系统调用）

# 常用中断举例

| 中断号/类型 | 名称         | 说明                                 |
|-------------|--------------|------------------------------------|
| `int 0x10`  | BIOS 视频服务 | 控制屏幕显示，光标操作，字符输出等  |
| `int 0x13`  | BIOS 磁盘服务 | 磁盘读写相关操作                    |
| `int 0x16`  | BIOS 键盘服务 | 读取键盘输入                      |
| `int 0x80`  | Linux 系统调用| Linux 32位系统调用接口             |
| `int 3`     | 调试断点      | 程序调试时触发断点                |
| IRQ0        | 定时器中断    | 系统定时器，用于任务切换和时间管理 |
| IRQ1        | 键盘中断      | 键盘按键触发中断                  |
| IRQ14       | 硬盘中断      | 硬盘控制器中断                    |
| 异常 0      | 除零错误      | 除以零操作时 CPU 产生的异常       |
| 异常 13     | 通用保护异常  | 访问非法内存或非法操作时触发       |

语法
---
```asm
mov destination, source
mov eax, 5        ; 把立即数 5 赋值给寄存器 eax
mov ebx, eax      ; 把 eax 的值复制给 ebx
mov [esi], eax    ; 把 eax 的值写入内存地址 esi 指向的位置
mov eax, [esi]    ; 把内存地址 esi 指向的值读取到 eax 中
mov [eax], [ebx]   ; ❌ 错误，两边都是内存地址
```
mov 是复制，不是剪切，source 不会变。


ah 是 ax 寄存器的高 8 位（ax 是 16 位寄存器，拆成 ah 和 al 两个 8 位寄存器）。
将 0x0e（十六进制，等于 14）放入 ah，通常表示 BIOS 显示服务中断 INT 10h 的功能号 0Eh（TTY 输出字符）

BIOS 中断 INT 10h 功能 0Eh 介绍
功能 0Eh：TTY 模式在屏幕上显示一个字符，同时在光标位置显示，并移动光标。
需要配合设置 al 寄存器为你要显示的字符的 ASCII 码。

**Goal: Make our previously silent boot sector print some text**

We will improve a bit on our infinite-loop boot sector and print
something on the screen. We will raise an interrupt for this.

On this example we are going to write each character of the "Hello"
word into the register `al` (lower part of `ax`), the bytes `0x0e`
into `ah` (the higher part of `ax`) and raise interrupt `0x10` which
is a general interrupt for video services.

`0x0e` on `ah` tells the video interrupt that the actual function
we want to run is to 'write the contents of `al` in tty mode'.

We will set tty mode only once though in the real world we 
cannot be sure that the contents of `ah` are constant. Some other
process may run on the CPU while we are sleeping, not clean
up properly and leave garbage data on `ah`.

For this example we don't need to take care of that since we are
the only thing running on the CPU.

Our new boot sector looks like this:
```nasm
mov ah, 0x0e ; tty mode
mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
int 0x10 ; 'l' is still on al, remember?
mov al, 'o'
int 0x10

jmp $ ; jump to current address = infinite loop

; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55 
```

You can examine the binary data with `xxd file.bin`

Anyway, you know the drill:

`nasm -fbin boot_sect_hello.asm -o boot_sect_hello.bin`

`qemu boot_sect_hello.bin`

Your boot sector will say 'Hello' and hang on an infinite loop
