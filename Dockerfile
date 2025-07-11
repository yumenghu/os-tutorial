FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TARGET=i686-elf
ENV PREFIX=/usr/local/i686elfgcc
ENV PATH=$PREFIX/bin:$PATH



RUN sed -i 's|http://.*.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|https://mirrors.tuna.tsinghua.edu.cn|http://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list && \
    apt update && \
    apt install -y  ca-certificates && \
    apt install -y  build-essential && \
    apt install -y  bison && \
    apt install -y  flex && \
    apt install -y  libgmp3-dev && \
    apt install -y  libmpc-dev && \
    apt install -y  libmpfr-dev && \
    apt install -y  texinfo && \
    apt install -y  git && \
    apt install -y  curl && \
    apt install -y  wget && \
    apt install -y  xz-utils && \
    apt install -y  gdb && \
    apt install -y  nasm && \
    apt install -y  gcc && \
    apt install -y  qemu-system-x86 && \
    apt install -y  make && \
    apt install -y  grub-pc-bin && \
    apt install -y  xorriso && \
    rm -rf /var/lib/apt/lists/*

# 下载并构建 binutils（适用于交叉编译）
WORKDIR /opt
RUN wget https://mirrors.tuna.tsinghua.edu.cn/gnu/binutils/binutils-2.40.tar.xz && \
    tar xf binutils-2.40.tar.xz && \
    mkdir binutils-build && \
    cd binutils-build && \
    ../binutils-2.40/configure --target=$TARGET --enable-interwork --enable-multilib --disable-nls --disable-werror --prefix=$PREFIX 2>&1 | tee configure.log && \
    make all install 2>&1 | tee make.log



# 构建 gcc（只启用 c/c++，无头文件）
RUN wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz && \
    tar -xf gcc-13.2.0.tar.xz && \
    mkdir gcc-build && cd gcc-build && \
    ../gcc-13.2.0/configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --disable-nls \
        --enable-languages=c,c++ \
        --without-headers && \
        make all-gcc -j$(nproc) && \
        make install-gcc && \
        make all-target-libgcc -j$(nproc) && \
        make install-target-libgcc

RUN i686-elf-gcc --version


# 设置工作目录
WORKDIR /osdev

CMD ["/bin/bash"]
