FROM archlinux AS base

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel wget git gmp libmpc mpfr gnupg  

ENV PREFIX=/usr/local
ENV TARGET=i686-elf
ENV PATH=$PREFIX/bin:$PATH

RUN mkdir /root/src
WORKDIR /root/src

# Download sources.
FROM base AS sources

RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz
RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz.sig
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-15.1.0/gcc-15.1.0.tar.xz
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-15.1.0/gcc-15.1.0.tar.xz.sig
RUN wget https://ftp.gnu.org/gnu/gdb/gdb-16.3.tar.xz
RUN wget https://ftp.gnu.org/gnu/gdb/gdb-16.3.tar.xz.sig

# Verify signatures, getting required keys.

FROM sources AS verify

# GCC Key: RSA 6C35B99309B5FA62
# Binutils Key: RSA 3A24BC1E8FB409FA9F14371813FCEF89DD9E3C4F
# GDB Key: DSA F40ADB902B24264AA42E50BF92EDB04BFF325CF3 
RUN gpg --recv-keys 6C35B99309B5FA62
RUN gpg --recv-keys 3A24BC1E8FB409FA9F14371813FCEF89DD9E3C4F
RUN gpg --recv-keys F40ADB902B24264AA42E50BF92EDB04BFF325CF3

# Verify the downloaded files.
RUN gpg --verify binutils-2.44.tar.xz.sig
RUN gpg --verify gcc-15.1.0.tar.xz.sig
RUN gpg --verify gdb-16.3.tar.xz.sig

# Extract sources.
RUN tar -xpvf binutils-2.44.tar.xz
RUN tar -xpvf gcc-15.1.0.tar.xz
RUN tar -xpvf gdb-16.3.tar.xz

FROM verify AS build

# Build and install binutils.
WORKDIR /root/src/
RUN mkdir build-binutils
WORKDIR /root/src/build-binutils
RUN ../binutils-2.44/configure --target=$TARGET --prefix=$PREFIX --disable-nls --disable-werror
RUN make -j$(nproc)
RUN make install

# Build and install GDB
WORKDIR /root/src/
RUN mkdir build-gdb
WORKDIR /root/src/build-gdb
RUN ../gdb-16.3/configure --target=$TARGET --prefix=$PREFIX --disable-werror
RUN make -j$(nproc) all-gdb
RUN make install-gdb

# Build and install GCC
WORKDIR /root/src/
RUN mkdir build-gcc
WORKDIR /root/src/build-gcc
RUN ../gcc-15.1.0/configure --target=$TARGET --prefix=$PREFIX --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
RUN make -j$(nproc) all-gcc
RUN make -j$(nproc) all-target-libgcc
RUN make -j$(nproc) all-target-libstdc++-v3
RUN make install-gcc
RUN make install-target-libgcc
RUN make install-target-libstdc++-v3

FROM build AS final

# Cleanup
WORKDIR /root/src/
RUN rm -rf binutils-2.44 gcc-15.1.0 gdb
RUN rm -rf build-binutils build-gcc build-gdb
RUN rm -rf *.tar.xz *.sig

RUN pacman -S --noconfirm bash coreutils findutils which grub mtools xorriso dosfstools

# Set the default command to run when the container starts.
WORKDIR /root
CMD ["/bin/bash"]
