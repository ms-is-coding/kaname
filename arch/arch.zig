const builtin = @import("builtin");

const impl = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/x86.zig"),
    else => @compileError("unsupported architecture"),
};

pub const boot = impl.boot;
pub const idt = impl.idt;
pub const gdt = impl.gdt;
pub const multiboot2 = impl.multiboot2;
pub const vbe = impl.vbe;
pub const vga = impl.vga;
pub const ports = impl.ports;
pub const serial = impl.serial;
pub const pic = impl.pic;
pub const lapic = impl.lapic;
pub const cpuid = impl.cpuid;
pub const fpu = impl.fpu;
pub const msr = impl.msr;
pub const keyboard = impl.keyboard;
