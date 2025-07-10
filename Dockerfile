FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TARGET=i686-elf
ENV PREFIX=/usr/local/i686elfgcc
ENV CC_FOR_TARGET=i686-elf-gcc
ENV CFLAGS_FOR_TARGET="-g -O2"
ENV ac_cv_prog_cc_g=yes
ENV ac_cv_prog_cc_works=yes
ENV ac_cv_prog_cc_cross=yes
ENV ac_cv_file__dev_zero=yes
ENV ac_cv_func_mmap_fixed_mapped=yes
ENV PATH=$PREFIX/bin:$PATH

## 根据参数替换镜像源
#RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//https:\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//g' /etc/apt/sources.list && \
#    sed -i 's/http:\/\/security.ubuntu.com\/ubuntu\//https:\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//g' /etc/apt/sources.list
#RUN apt update && \
#    apt install -y --no-install-recommends ca-certificates

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

# 下载并构建 GCC（仅 C 支持）
#RUN wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-5.5.0/gcc-5.5.0.tar.xz && \
#    tar -xf gcc-5.5.0.tar.xz && \
#    mkdir gcc-build && \
#    cd gcc-build && \
#    ../gcc-5.5.0/configure \
#      --target=$TARGET \
#      --prefix=$PREFIX \
#      --disable-nls \
#      --disable-shared \
#      --disable-threads \
#      --enable-languages=c \
#      --without-headers && \
#    make -j$(nproc) all-gcc && \
#    make -j$(nproc) all-target-libgcc && \
#    make install-gcc && \
#    make install-target-libgcc
#RUN i386-elf-gcc --version && \
#    rm -rf /opt/gcc-5.5.0* /opt/gcc-build

# 构建 gcc（只启用 c/c++，无头文件）
RUN wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-11.4.0/gcc-11.4.0.tar.xz && \
    tar -xf gcc-11.4.0.tar.xz && \
    mkdir gcc-build && cd gcc-build && \
    ../gcc-11.4.0/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers && \
    make -j$(nproc) all-gcc && make -j$(nproc) all-target-libgcc && \
    make install-gcc && make install-target-libgcc

RUN i686-elf-gcc --version


# 设置工作目录
WORKDIR /osdev

CMD ["/bin/bash"]
