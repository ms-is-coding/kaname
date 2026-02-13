const arch = @import("arch");
const libk = @import("libk");

comptime {
    _ = arch.boot;
}

pub export fn kmain() void {
    arch.vga.initialize();
    libk.init(arch.vga.putchar);

    libk.printk("Hello, {d}!", .{42});

    while (true) {
        asm volatile ("cli; hlt");
    }
}
