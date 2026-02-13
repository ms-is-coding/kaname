const builtin = @import("builtin");

pub const boot = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/boot.zig"),
    else => @compileError("unsupported architecture"),
};

pub const vga = switch (builtin.target.cpu.arch) {
    .x86 => @import("x86/vga.zig"),
    else => @compileError("unsupported architecture"),
};
