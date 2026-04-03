const config = @import("config");

const arch = @import("arch");
const libk = @import("libk");

const std = @import("std");

comptime {
    _ = arch.boot;
}

pub export fn kmain(magic: u32, mb_info: *arch.multiboot2.Info) void {
    std.debug.assert(magic == arch.multiboot2.BOOTLOADER_MAGIC);

    arch.multiboot2.parse(mb_info, struct {
        pub fn onFramebuffer(tag: *arch.multiboot2.FramebufferTag) void {
            arch.fb.init(tag);
        }
    });

    // will not print anything as framebuffer should be initialized
    arch.vga.initialize();
    libk.init(arch.vga.putchar);
    libk.printk(
        \\KFS {s}
        \\Hello, {d}!
    , .{ config.version, 42 });

    while (true) {
        asm volatile ("cli; hlt");
    }
}
