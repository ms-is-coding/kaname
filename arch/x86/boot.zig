const MAGIC: u32 = 0x1BADB002;
const FLAGS: u32 = 3;

const MultibootHeader = extern struct {
    magic: u32,
    flags: u32,
    checksum: u32,
};

export var multiboot_header: MultibootHeader align(4) linksection(".multiboot") = .{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = 0 -% (MAGIC +% FLAGS),
};

export var stack: [16384]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.naked) noreturn {
    asm volatile (
        \\movl $stack + 16384, %%esp
        \\call kmain
        \\sti
        \\.Lhalt:
        \\hlt
        \\jmp .Lhalt
    );
}
