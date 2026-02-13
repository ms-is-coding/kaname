const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const cpu_arch: std.Target.Cpu.Arch = .x86;

    const target = b.resolveTargetQuery(.{
        .cpu_arch = cpu_arch,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_features_sub = std.Target.x86.featureSet(&.{ .sse, .sse2 }),
        .cpu_features_add = std.Target.x86.featureSet(&.{ .soft_float }),
    });

    const libk = b.createModule(.{
        .root_source_file = b.path("libk/libk.zig"),
        .target = target,
        .optimize = optimize,
    });

    const arch = b.createModule(.{
        .root_source_file = b.path("arch/arch.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "libk", .module = libk }
        },
    });

    const abi = b.createModule(.{
        .root_source_file = b.path("abi/abi.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "libk", .module = libk }
        },
    });

    const kernel = b.addExecutable(.{
        .name = "kfs.kernel",
        .root_module = b.createModule(.{
            .root_source_file = b.path("kernel/kernel.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "libk", .module = libk },
                .{ .name = "arch", .module = arch },
                .{ .name = "abi", .module = abi },
            },
        }),
    });

    const git_version = b.run(&.{ "git", "describe", "--tags", "--dirty" });
    const version = std.mem.trim(u8, git_version, " \n\r");

    const options = b.addOptions();
    options.addOption([]const u8, "version", version);

    kernel.root_module.addOptions("config", options);

    const linker_script = switch (cpu_arch) {
        .x86 => b.path("arch/x86/linker.ld"),
        else => @panic("unsupported architecture"),
    };
    kernel.setLinkerScript(linker_script);

    b.installArtifact(kernel);

    const iso_step = b.step("iso", "Build bootable ISO image");

    const mkdir_cmd = b.addSystemCommand(&.{ "mkdir", "-p", "iso/boot/grub" });

    const cp_kernel_cmd = b.addSystemCommand(&.{ "cp" });
    cp_kernel_cmd.addArtifactArg(kernel);
    cp_kernel_cmd.addArg("iso/boot/kfs.kernel");
    cp_kernel_cmd.step.dependOn(&mkdir_cmd.step);

    const cp_grub_cmd = b.addSystemCommand(&.{ "cp", "meta/grub.cfg", "iso/boot/grub/grub.cfg" });
    cp_grub_cmd.step.dependOn(&mkdir_cmd.step);

    const mkrescue = b.addSystemCommand(&.{ "grub-mkrescue", "-o", "kfs.iso", "iso" });
    mkrescue.step.dependOn(&cp_kernel_cmd.step);
    mkrescue.step.dependOn(&cp_grub_cmd.step);

    iso_step.dependOn(&mkrescue.step);

    const run_step = b.step("run", "Run kernel in QEMU");

    const qemu_version = "qemu-system-" ++ switch (cpu_arch) {
        .aarch64 => "aarch64",
        .arm => "arm",
        .avr => "avr",
        .loongarch64 => "loongarch64",
        .m68k => "m68k",
        .mips => "mips",
        .mips64 => "mips64",
        .mips64el => "mips64el",
        .mipsel => "mipsel",
        .or1k => "or1k",
        .powerpc => "ppc",
        .powerpc64 => "ppc64",
        .riscv32 => "riscv32",
        .riscv64 => "riscv64",
        .s390x => "s390x",
        .sparc => "sparc",
        .sparc64 => "sparc64",
        .x86 => "i386",
        .x86_64 => "x86_64",
        .xtensa => "xtensa",
        else => @panic("unsupported CPU architecture"),
    };

    const qemu = b.addSystemCommand(&.{ qemu_version, "-cdrom", "kfs.iso" });
    qemu.step.dependOn(&mkrescue.step);

    run_step.dependOn(&qemu.step);
}
