const builtin = @import("builtin");

pub const boot = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/boot.zig"),
    else => @compileError("unsupported architecture"),
};

pub const multiboot2 = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/multiboot2.zig"),
    else => @compileError("unsupported architecture"),
};

pub const vbe = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/vbe.zig"),
    else => @compileError("unsupported architecture"),
};

pub const fb = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/fb.zig"),
    else => @compileError("unsupported architecture"),
};

pub const vga = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/vga.zig"),
    else => @compileError("unsupported architecture"),
};

pub const ports = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/ports.zig"),
    else => @compileError("unsupported architecture"),
};
