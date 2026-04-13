const std = @import("std");
const vga = @import("arch").vga;
const acpi = @import("arch").acpi;
const cpuid = @import("arch").cpuid;

var line_buf: [256]u8 = undefined;
var line_len: usize = 0;

const Command = struct {
    name: []const u8,
    description: []const u8,
    func: *const fn (args: []const u8) void,
};

const commands = [_]Command{
    .{ .name = "help", .description = "List commands", .func = cmdHelp },
    .{ .name = "uname", .description = "Print system information", .func = cmdUname },
    .{ .name = "shutdown", .description = "Shutdown system", .func = cmdShutdown },
    .{ .name = "cpuinfo", .description = "CPU information", .func = cmdCpuinfo },
    .{ .name = "clear", .description = "Clear screen", .func = cmdClear },
};

fn cmdHelp(_: []const u8) void {
    const maxlen = blk: {
        var max: usize = 0;
        for (commands) |cmd| max = @max(max, cmd.name.len);
        break :blk max;
    };
    for (commands) |cmd| {
        vga.print("{s}", .{cmd.name});
        // pad with spaces
        var i = cmd.name.len;
        while (i < maxlen + 2) : (i += 1) vga.putchar(' ');
        vga.print("{s}\n", .{cmd.description});
    }
}

fn cmdUname(_: []const u8) void {
    vga.print("KFS {s}\n", .{@import("config").version});
}

fn cmdShutdown(_: []const u8) void {
    acpi.shutdown();
}

fn printFlags(features: anytype) void {
    inline for (std.meta.fields(@TypeOf(features))) |field| {
        if (field.type == bool) {
            if (@field(features, field.name)) {
                vga.print("{s} ", .{field.name});
            }
        }
    }
}

fn cmdCpuinfo(_: []const u8) void {
    vga.print(
        \\processor     : 0
        \\vendor_id     : {s}
        \\cpu family    : {}
        \\model         : {}
        \\model name    : {s}
        \\stepping      : {}
        \\flags         : 
    , .{
        cpuid.vendorString(),
        cpuid.effectiveFamily(cpuid.familyInfo()),
        cpuid.effectiveModel(cpuid.familyInfo()),
        std.mem.trimRight(u8, &cpuid.brandString(), &.{0}),
        cpuid.familyInfo().stepping,
    });
    printFlags(cpuid.features());
    printFlags(cpuid.extFeatures());
    vga.print(
        \\
        \\address sizes : {} bits physical, {} bits virtual
        \\
    , .{
        cpuid.addressSizes().eax.physical_address_bits,
        cpuid.addressSizes().eax.linear_address_bits,
    });
}

fn cmdClear(_: []const u8) void {
    vga.clearScreen(0);
    vga.setPosition(0, 0);
}

fn dispatch(input: []const u8) void {
    for (commands) |cmd| {
        if (std.mem.eql(u8, input, cmd.name)) {
            cmd.func(input);
            vga.write("> ");
            return;
        }
    }
    vga.print("unknown command: {s}\n> ", .{input});
}

pub fn onChar(c: u8) void {
    switch (c) {
        '\n' => {
            vga.putchar('\n');
            dispatch(line_buf[0..line_len]);
            line_len = 0;
        },
        0x08 => {
            if (line_len > 0) {
                line_len -= 1;
                vga.backspace();
            }
        },
        else => {
            if (line_len < line_buf.len - 1) {
                line_buf[line_len] = c;
                line_len += 1;
                vga.putchar(c);
            }
        },
    }
}
