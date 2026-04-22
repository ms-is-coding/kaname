FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
        gcc make curl xz \
        bison flex python git \
        lib32-glibc \
        qemu-full \
        grub \
        mtools xorriso \
        binutils file && \
    pacman -Scc --noconfirm

WORKDIR /os

CMD ["/bin/bash"]
