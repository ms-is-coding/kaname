const std = @import("std");

const InformationRequestTag = extern struct {
    type: u16 = 1,
    flags: u16 = 0,
    size: u32 = @sizeOf(InformationRequestTag),
    requests: [2]u32 = .{ 1, 8 },
};

const ConsoleTag = extern struct {
    type: u16 = 4,
    flags: u16 = 1, // optional
    size: u32 = @sizeOf(ConsoleTag),
    console_flags: u32 = (1 << 1), // text mode
    _pad: u32 = 0,
};

const FramebufferTag = extern struct {
    type: u16 = 5,
    flags: u16 = 1, // optional
    size: u32 = @sizeOf(FramebufferTag),
    width: u32 = 1024,
    height: u32 = 768,
    depth: u32 = 32,
    _pad: u32 = 0,
};

const EndTag = extern struct {
    type: u16 = 0,
    flags: u16 = 0,
    size: u32 = 8,
};

const Multiboot2Header = extern struct {
    magic: u32 = 0xE85250D6,
    architecture: u32 = 0, // i386
    header_length: u32 = @sizeOf(Multiboot2Header),
    checksum: u32 = 0,
    info_req: InformationRequestTag = .{},
    console: ConsoleTag = .{},
    framebuffer: FramebufferTag = .{},
    end: EndTag = .{},
};

fn makeHeader() Multiboot2Header {
    var h = Multiboot2Header{};
    h.checksum = 0 -% (h.magic +% h.architecture +% h.header_length);
    return h;
}

comptime {
    std.debug.assert(@sizeOf(InformationRequestTag) % 8 == 0);
    std.debug.assert(@sizeOf(ConsoleTag) % 8 == 0);
    std.debug.assert(@sizeOf(FramebufferTag) % 8 == 0);
    std.debug.assert(@sizeOf(EndTag) % 8 == 0);
}

export var multiboot2_header: Multiboot2Header align(8) linksection(".multiboot2") = makeHeader();

export var stack: [16384]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.naked) noreturn {
    asm volatile (
        \\movl $stack + 16384, %%esp
        // Reset EFLAGS
        \\pushl $0
        \\popf
        // Push multiboot information structure pointer
        \\pushl %%ebx
        // Push magic value
        \\pushl %%eax

        // Enable FPU
        \\mov %%cr0, %%eax
        \\and $0xFFFFFFFB, %%eax
        \\or  $0x00000002, %%eax
        \\mov %%eax, %%cr0

        // Enable SSE
        \\mov %%cr4, %%eax
        \\or  $0x00000600, %%eax
        \\mov %%eax, %%cr4
        \\call kmain
        \\sti
        \\.Lhalt:
        \\hlt
        \\jmp .Lhalt
    );
}
