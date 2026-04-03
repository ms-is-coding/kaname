pub const VbeInfoBlock = extern struct {
    signature: [4]u8, // must be "VESA"
    version: u16,
    oem_string_off: u16,
    oem_string_seg: u16,
    capabilities: [4]u8,
    video_mode_off: u16,
    video_mode_seg: u16,
    total_memory: u16, // in 64KiB blocks
    oem_software_revision: u16,
    oem_vendor_name_off: u16,
    oem_vendor_name_seg: u16,
    oem_product_name_off: u16,
    oem_product_name_seg: u16,
    oem_product_revision_off: u16,
    oem_product_revision_seg: u16,
    reserved: [222]u8,
    oem_data: [256]u8,
};

pub const VbeModeInfoBlock = extern struct {
    attributes: u16, // deprecated, only bit 7 should be of interest to you, and it indicates the mode supports a linear frame buffer.
    window_a: u8, // deprecated
    window_b: u8, // deprecated
    granularity: u16, // deprecated; used while calculating bank numbers
    window_size: u16,
    segment_a: u16,
    segment_b: u16,
    win_func_ptr: u32, // deprecated; used to switch banks from protected mode without returning to real mode
    pitch: u16, // number of bytes per horizontal line
    width: u16, // width in pixels
    height: u16, // height in pixels
    w_char: u8, // unused...
    y_char: u8, // ...
    planes: u8,
    bpp: u8, // bits per pixel in this mode
    banks: u8, // deprecated; total number of banks in this mode
    memory_model: u8,
    bank_size: u8, // deprecated; size of a bank, almost always 64 KB but may be 16 KB...
    image_pages: u8,
    reserved0: u8,

    red_mask: u8,
    red_position: u8,
    green_mask: u8,
    green_position: u8,
    blue_mask: u8,
    blue_position: u8,
    reserved_mask: u8,
    reserved_position: u8,
    direct_color_attributes: u8,

    framebuffer: u32, // physical address of the linear frame buffer; write here to draw to the screen
    off_screen_mem_off: u32,
    off_screen_mem_size: u16, // size of memory in the framebuffer but not being displayed on the screen
    reserved1: [206]u8,
};

comptime {
    const assert = @import("std").debug.assert;

    assert(@sizeOf(VbeInfoBlock) == 512);
    assert(@sizeOf(VbeModeInfoBlock) == 256);
}
