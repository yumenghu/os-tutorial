# 1.准备编译环境
## 1.1 基于docker构建编译测试环境
该环境集成了 nasm qemu gdb make gcc的交叉编译环境

### 1.1.1 构建docker 使用守护进程的方式启动，并且把当前目录挂在到容器
```shell
docker build -f ../Dockerfile -t osdev:1.0
#liunx macos
docker run -d -v $(pwd):/osdev -w /osdev --name osdev-env osdev:1.0 tail -f /dev/null
#windows
docker run -d -v ${pwd}:/osdev -w /osdev --name osdev-env osdev:1.0 tail -f /dev/null
```

### 1.1.2 验证环境
```shell
docker ps
# CONTAINER ID   IMAGE       COMMAND               CREATED          STATUS          PORTS     NAMES
# 056f7852d1e6   osdev:1.0   "tail -f /dev/null"   20 minutes ago   Up 20 minutes             osdev-env
docker exec -it 056f7852d1e6 /bin/bash

qemu-system-i386 -version
#QEMU emulator version 6.2.0 (Debian 1:6.2+dfsg-2ubuntu6.26)
#Copyright (c) 2003-2021 Fabrice Bellard and the QEMU Project developers
nasm -v
#NASM version 2.15.05
#GNU Make 4.3
#Built for x86_64-pc-linux-gnu
#Copyright (C) 1988-2020 Free Software Foundation, Inc.
#License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
#This is free software: you are free to change and redistribute it.
#There is NO WARRANTY, to the extent permitted by law.
i686-elf-gcc -v
#Using built-in specs.
#COLLECT_GCC=i686-elf-gcc
#COLLECT_LTO_WRAPPER=/usr/local/i686elfgcc/libexec/gcc/i686-elf/13.2.0/lto-wrapper
#Target: i686-elf
#Configured with: ../gcc-13.2.0/configure --target=i686-elf --prefix=/usr/local/i686elfgcc --disable-nls --enable-languages=c,c++ --without-headers
#Thread model: single
#Supported LTO compression algorithms: zlib
#gcc version 13.2.0 (GCC)
i686-elf-ld -v
#GNU ld (GNU Binutils) 2.40
```