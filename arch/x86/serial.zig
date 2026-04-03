const ports = @import("ports.zig");
const std = @import("std");

const COM1: u16 = 0x3F8;

pub fn init() void {
    ports.outb(COM1 + 1, 0x00); // disable interrupts
    ports.outb(COM1 + 3, 0x80); // enable DLAB
    ports.outb(COM1 + 0, 0x03); // baud rate low: 38400
    ports.outb(COM1 + 1, 0x00); // baud rate high
    ports.outb(COM1 + 3, 0x03); // 8 bits, no parity, one stop bit
    ports.outb(COM1 + 2, 0xC7); // enable FIFO
    ports.outb(COM1 + 4, 0x0B); // enable IRQs, RTS/DSR set
}

fn isTransmitEmpty() bool {
    return ports.inb(COM1 + 5) & 0x20 != 0;
}

pub fn putchar(c: u8) void {
    while (!isTransmitEmpty()) {}
    ports.outb(COM1, c);
}

pub fn write(s: []const u8) void {
    for (s) |c| putchar(c);
}

const SerialWriter = struct {
    pub fn write(_: void, data: []const u8) error{}!usize {
        for (data) |c| {
            putchar(c);
        }
        return data.len;
    }

    pub const Writer = std.io.GenericWriter(void, error{}, SerialWriter.write);

    pub fn writer() Writer {
        return .{ .context = {} };
    }
};

pub fn print(comptime format: []const u8, args: anytype) void {
    SerialWriter.writer().print(format, args) catch {};
}
