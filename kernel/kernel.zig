const config = @import("config");
const arch = @import("arch");
const drivers = @import("drivers");
const std = @import("std");
const shell = @import("shell.zig");
const @"42" = @import("42.zig");

comptime {
    _ = arch.boot;
}

var cpu_vendor: [12]u8 = undefined;
var cpu_brand: [48]u8 = undefined;

pub export fn kmain(magic: u32, mb_info: *arch.multiboot2.Info) void {
    drivers.serial.init() catch {};

    if (magic != arch.multiboot2.BOOTLOADER_MAGIC) {
        drivers.serial.print("bad magic: {x}\n", .{magic});
    }

    cpu_vendor = arch.cpuid.vendorString();
    cpu_brand = arch.cpuid.brandString();
    const info = arch.cpuid.familyInfo();

    drivers.serial.print("CPU vendor: {s}\n", .{cpu_vendor});
    drivers.serial.print("CPU brand:  {s}\n", .{std.mem.trimEnd(u8, &cpu_brand, &.{0})});
    drivers.serial.print("Family: {}  Model: {}  Stepping: {}\n", .{
        arch.cpuid.effectiveFamily(info),
        arch.cpuid.effectiveModel(info),
        info.stepping,
    });

    arch.gdt.init();
    arch.idt.init();
    arch.pic.init();
    drivers.keyboard.init();
    drivers.keyboard.setCharHandler(shell.onChar);
    arch.idt.enableInterrupts();

    // TODO only init apic when CPUID indicates its availability
    // arch.lapic.init() catch {
    //     arch.pic.init();
    //     drivers.serial.print("LAPIC init failed\n", .{});
    // };

    arch.multiboot2.parse(mb_info, struct {
        pub fn onFramebuffer(tag: *arch.multiboot2.FramebufferTag) void {
            const ptr: [*]u32 = @ptrFromInt(@as(usize, @truncate(tag.addr)));
            drivers.serial.print("[Framebuffer] Type: {}\n", .{tag.type});
            drivers.serial.print("[Framebuffer] Resolution: {}x{}\n", .{ tag.width, tag.height });
            drivers.serial.print("[Framebuffer] Address: 0x{X}\n", .{tag.addr});

            switch (tag.type) {
                .direct => @"42".draw42(ptr, tag.width, tag.height),
                .ega_text => {
                    drivers.vga.initialize();
                    drivers.vga.print(
                        \\KFS {s}
                        \\Hello, {d}!
                        \\
                    , .{ config.version, 42 });
                },
                else => {
                    drivers.serial.print("unsupported framebuffer type: {}\n", .{tag.type});
                },
            }
        }
        pub fn onACPIv1(tag: *arch.multiboot2.AcpiRsdpV1Tag) void {
            drivers.vga.print("ACPI v1 detected\n", .{});
            if (!tag.rsdp.isValid()) {
                drivers.vga.print("Invalid ACPI signature\n", .{});
                return;
            }
            drivers.acpi.init(tag.rsdp.rsdt_address);

            drivers.serial.print(
                \\FADT at 0x{X}
                \\Preferred PM profile: {}
                \\
            , .{
                @intFromPtr(drivers.acpi.fadt),
                drivers.acpi.fadt.preferred_pm_profile,
            });
        }

        pub fn onACPIv2(tag: *arch.multiboot2.AcpiRsdpV2Tag) void {
            drivers.vga.print("ACPI v2+ detected\n", .{});
            if (!tag.rsdp.isValid()) {
                drivers.vga.print("Invalid ACPI signature\n", .{});
                return;
            }
        }
    });

    drivers.vga.write("> ");
    // main loop
    while (true) {
        asm volatile ("hlt");
    }

    unreachable;
}

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    drivers.serial.print("PANIC: {s}\n", .{msg});
    while (true) asm volatile ("cli; hlt");
}
