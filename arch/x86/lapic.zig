const msr = @import("msr.zig");
const cpuid = @import("cpuid.zig");

// https://wiki.osdev.org/APIC

const IA32_APIC_BASE_MSR = 0x1B;
const IA32_APIC_BASE_MSR_ENABLE = 0x800;

pub const ReadRegister = enum(u32) {
    id = 0x20,
    version = 0x30,
    task_priority = 0x80,
    arbitration_priority = 0x90,
    processor_priority = 0xA0,
    remote_read = 0xC0,
    logical_dest = 0xD0,
    dest_format = 0xE0,
    spurious_interrupt_vector = 0xF0,
    error_status = 0x280,
    lvt_cmci = 0x2F0,
    icr1 = 0x300,
    icr2 = 0x310,
    lvt_timer = 0x320,
    lvt_thermal = 0x330,
    lvt_perf = 0x340,
    lvt_lint0 = 0x350,
    lvt_lint1 = 0x360,
    lvt_error = 0x370,
    timer_initial_count = 0x380,
    timer_current_count = 0x390,
    timer_divide = 0x3E0,
};

pub const WriteRegister = enum(u32) {
    task_priority = 0x80,
    eoi = 0xB0,
    logical_dest = 0xD0,
    dest_format = 0xE0,
    spurious_interrupt_vector = 0xF0,
    lvt_cmci = 0x2F0,
    icr1 = 0x300,
    icr2 = 0x310,
    lvt_timer = 0x320,
    lvt_thermal = 0x330,
    lvt_perf = 0x340,
    lvt_lint0 = 0x350,
    lvt_lint1 = 0x360,
    lvt_error = 0x370,
    timer_initial_count = 0x380,
    timer_divide = 0x3E0,
};

fn setBase(base: usize) void {
    msr.write(IA32_APIC_BASE_MSR, (base & 0xfffff000) | IA32_APIC_BASE_MSR_ENABLE);
}

fn getBase() usize {
    return @truncate(msr.read(IA32_APIC_BASE_MSR) & 0xfffff000);
}

fn readReg(base: usize, reg: ReadRegister) u32 {
    const ptr: *volatile u32 = @ptrFromInt(base + @intFromEnum(reg));
    return ptr.*;
}

fn writeReg(base: usize, reg: WriteRegister, value: u32) void {
    const ptr: *volatile u32 = @ptrFromInt(base + @intFromEnum(reg));
    ptr.* = value;
}

pub const ApicError = error{
    NotSupported,
};

pub fn init() ApicError!void {
    if (!cpuid.features().apic) return error.NotSupported;

    const base = getBase();
    setBase(base);
    // Enable LAPIC (bit 8) and set SIVR to 0xFF
    writeReg(base, .spurious_interrupt_vector, readReg(base, .spurious_interrupt_vector) | 0x1FF);
}
