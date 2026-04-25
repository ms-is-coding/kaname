const symbols = @import("symbols.zig");
const serial = @import("drivers").serial;
const terminal = @import("drivers").terminal;
const STACK_SIZE = @import("arch").boot.STACK_SIZE;

const StackFrame = extern struct {
    prev: ?*StackFrame,
    ret: usize,
};

pub fn printStack() void {
    var esp: usize = undefined;
    var ebp: usize = undefined;

    asm volatile (
        \\mov %%esp, %[esp]
        \\mov %%ebp, %[ebp]
        : [esp] "=r" (esp),
          [ebp] "=r" (ebp),
    );

    var frame: ?*StackFrame = @ptrFromInt(ebp);
    var i: usize = 0;
    while (frame) |f| : (i += 1) {
        const stack_start = esp;
        const stack_end = stack_start + STACK_SIZE;
        const frame_addr = @intFromPtr(f);

        if (frame_addr < stack_start or frame_addr >= stack_end) break;
        if (!symbols.isKernelAddress(f.ret)) break;

        terminal.print("  #{d}: 0x{x} - {s}\n", .{ i, f.ret, symbols.resolve(f.ret) });
        serial.print("  #{d}: 0x{x} - {s}\n", .{ i, f.ret, symbols.resolve(f.ret) });
        frame = f.prev;
    }
}
