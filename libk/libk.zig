const std = @import("std");

var putchar_fn: ?*const fn (u8) void = null;

pub fn init(putchar: *const fn (u8) void) void {
    putchar_fn = putchar;
}

const LibkWriter = struct {
    pub fn write(_: void, data: []const u8) error{}!usize {
        if (putchar_fn) |putchar| {
            for (data) |c| {
                putchar(c);
            }
        }
        return data.len;
    }

    pub const Writer = std.io.GenericWriter(void, error{}, LibkWriter.write);

    pub fn writer() Writer {
        return .{ .context = {} };
    }
};

pub fn printk(comptime format: []const u8, args: anytype) void {
    LibkWriter.writer().print(format, args) catch {};
}
