FROM ubuntu:24.10

ENV DEBIAN_FRONTEND=noninteractive
ENV TARGET=i386-elf
ENV PREFIX=/usr/local/i386elfgcc
ENV PATH=$PREFIX/bin:$PATH

# 安装构建依赖
RUN apt update
RUN apt install -y     build-essential
RUN apt install -y     bison
RUN apt install -y     flex
RUN apt install -y     libgmp3-dev
RUN apt install -y     libmpc-dev
RUN apt install -y     libmpfr-dev
RUN apt install -y     texinfo
RUN apt install -y     git
RUN apt install -y     curl
RUN apt install -y     wget
RUN apt install -y     xz-utils
RUN apt install -y     gdb
RUN apt install -y     nasm
RUN apt install -y     qemu-system-x86
RUN apt install -y     make
RUN apt install -y     ca-certificates
RUN apt install -y     grub-pc-bin
RUN apt install -y     xorriso
RUN rm -rf /var/lib/apt/lists/*

# 下载并构建 binutils（适用于交叉编译）
WORKDIR /opt
RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.xz && \
    tar xf binutils-2.40.tar.gz && \
    mkdir binutils-build && \
    cd binutils-build && \
    ../binutils-2.24/configure --target=$TARGET --enable-interwork --enable-multilib --disable-nls --disable-werror --prefix=$PREFIX 2>&1 | tee configure.log && \
    make all install 2>&1 | tee make.log

# 下载并构建 GCC（仅 C 支持）
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-4.9.4/gcc-4.9.4.tar.xz && \
    tar -xf gcc-4.9.4.tar.xz && \
    mkdir gcc-build && \
    cd gcc-build && \
    ../gcc-4.9.1/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --disable-libssp --enable-languages=c --without-headers && \
    make all-gcc && \
    make all-target-libgcc && \
    make install-gcc && \
    make install-target-libgcc 

# 设置工作目录
WORKDIR /osdev

CMD ["/bin/bash"]
