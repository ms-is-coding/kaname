const FramebufferTag = @import("multiboot2.zig").FramebufferTag;
const vga = @import("vga.zig");

fn drawGradient(ptr: [*]u32, width: u32, height: u32) void {
    for (0..height) |y| {
        for (0..width) |x| {
            ptr[y * width + x] = (x * 255 / width) << 16 | (0x80 << 8) | (y * 255 / height);
        }
    }
}

pub fn init(tag: *FramebufferTag) void {
    const ptr: [*]u32 = @ptrFromInt(@as(usize, @truncate(tag.addr)));
    drawGradient(ptr, tag.width, tag.height);
}
