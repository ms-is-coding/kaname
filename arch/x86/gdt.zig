pub const KERNEL_CODE_SEG: u16 = 0x08;
pub const KERNEL_DATA_SEG: u16 = 0x10;

const GDT_ENTRIES = 7;

const GdtDescriptor = packed struct {
    size: u16,
    offset: u32,
};

const AccessByte = packed struct(u8) {
    accessed: u1 = 0,
    read_write: u1,
    direction_conforming: u1 = 0,
    executable: u1,
    descriptor_type: u1 = 1,
    privilege: u2,
    present: u1 = 1,
};

const Flags = packed struct(u4) {
    _reserved: u1 = 0,
    long_mode: u1 = 0,
    size: u1 = 1,
    granularity: u1 = 1,
};

const SegmentDescriptor = packed struct(u64) {
    limit_low: u16,
    base_low: u16,
    base_mid: u8,
    access: AccessByte,
    limit_high: u4,
    flags: Flags,
    base_high: u8,

    const nil: SegmentDescriptor = @bitCast(@as(u64, 0));

    fn make(base: u32, limit: u20, access: AccessByte, flags: Flags) SegmentDescriptor {
        return .{
            .limit_low = @truncate(limit),
            .base_low = @truncate(base),
            .base_mid = @truncate(base >> 16),
            .access = access,
            .limit_high = @truncate(limit >> 16),
            .flags = flags,
            .base_high = @truncate(base >> 24),
        };
    }
};

const gdt_entries = [GDT_ENTRIES]SegmentDescriptor{
    // 0x00 - Null descriptor
    SegmentDescriptor.nil,
    // 0x08 - Kernel code (ring 0, RWE)
    SegmentDescriptor.make(0, 0xFFFFF, .{ .read_write = 1, .executable = 1, .privilege = 0 }, .{}),
    // 0x10 - Kernel data (ring 0, RW)
    SegmentDescriptor.make(0, 0xFFFFF, .{ .read_write = 1, .executable = 0, .privilege = 0 }, .{}),
    // 0x18 - Kernel stack (ring 0, RW, expand-down)
    SegmentDescriptor.make(0, 0xFFFFF, .{ .read_write = 1, .executable = 0, .privilege = 0, .direction_conforming = 1 }, .{}),

    // 0x20 - User code (ring 3, RWE)
    SegmentDescriptor.make(0, 0xFFFFF, .{ .read_write = 1, .executable = 1, .privilege = 3 }, .{}),
    // 0x28 - User data (ring 3, RW)
    SegmentDescriptor.make(0, 0xFFFFF, .{ .read_write = 1, .executable = 0, .privilege = 3 }, .{}),
    // 0x30 - User stack (ring 3, RW, expand-down)
    SegmentDescriptor.make(0, 0xFFFFF, .{ .read_write = 1, .executable = 0, .privilege = 3, .direction_conforming = 1 }, .{}),
};

pub fn init() void {
    const descriptor = GdtDescriptor{
        .offset = @intFromPtr(&gdt_entries),
        .size = @sizeOf(@TypeOf(gdt_entries)) - 1,
    };

    asm volatile (
        \\lgdt (%[ptr])
        \\ljmp $0x08, $1f
        \\1:
        \\movw $0x10, %%ax
        \\movw %%ax, %%ds
        \\movw %%ax, %%es
        \\movw %%ax, %%fs
        \\movw %%ax, %%gs
        \\movw %%ax, %%ss
        :
        : [ptr] "r" (&descriptor),
        : .{ .ax = true });
}
