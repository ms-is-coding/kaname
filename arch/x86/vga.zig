const std = @import("std");

pub const VGA_WIDTH = 80;
pub const VGA_HEIGHT = 25;
pub const VGA_MEMORY: [*]volatile u16 = @ptrFromInt(0xB8000);

pub const VgaColor = enum(u4) {
    black = 0,
    blue = 1,
    green = 2,
    cyan = 3,
    red = 4,
    magenta = 5,
    brown = 6,
    light_grey = 7,
    dark_grey = 8,
    light_blue = 9,
    light_green = 10,
    light_cyan = 11,
    light_red = 12,
    light_magenta = 13,
    light_brown = 14,
    white = 15,
};

pub fn vgaEntryColor(fg: VgaColor, bg: VgaColor) u8 {
    return @intFromEnum(fg) | (@as(u8, @intFromEnum(bg)) << 4);
}

pub fn vgaEntry(uc: u8, color: u8) u16 {
    return @as(u16, uc) | (@as(u16, color) << 8);
}

var terminal_row: usize = 0;
var terminal_column: usize = 0;
var terminal_color: u8 = 0;
var terminal_buffer: [*]volatile u16 = VGA_MEMORY;

pub fn putchar(c: u8) void {
    if (c == '\n') {
        terminal_column = 0;
        terminal_row += 1;
    } else {
        terminal_buffer[terminal_row * VGA_WIDTH + terminal_column] = vgaEntry(c, terminal_color);
        terminal_column += 1;
    }
    if (terminal_column >= VGA_WIDTH) {
        terminal_column = 0;
        terminal_row += 1;
    }
    if (terminal_row >= VGA_HEIGHT) {
        scrollScreen();
    }
    updateCursor();
}

pub fn write(data: []const u8) void {
    for (data) |c| {
        putchar(c);
    }
}

pub fn backspace() void {
    if (terminal_column > 0) {
        terminal_column -= 1;
    } else if (terminal_row > 0) {
        terminal_row -= 1;
        terminal_column = VGA_WIDTH - 1;
    }
    terminal_buffer[terminal_row * VGA_WIDTH + terminal_column] = vgaEntry(' ', terminal_color);
    updateCursor();
}

fn scroll(line: usize) void {
    for (0..VGA_WIDTH) |x| {
        terminal_buffer[(line - 1) * VGA_WIDTH + x] = terminal_buffer[line * VGA_WIDTH + x];
    }
}

fn deleteLastLine() void {
    for (0..VGA_WIDTH) |x| {
        terminal_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vgaEntry(' ', terminal_color);
    }
}

fn scrollScreen() void {
    for (1..VGA_HEIGHT) |y| {
        scroll(y);
    }
    deleteLastLine();
    terminal_row = VGA_HEIGHT - 1;
}

pub fn initialize() void {
    terminal_row = 0;
    terminal_column = 0;
    terminal_color = vgaEntryColor(.green, .black);
    terminal_buffer = VGA_MEMORY;
    clearScreen(terminal_color);
    enableCursor(14, 15);
    updateCursor();
}

pub fn setColor(color: u8) void {
    terminal_color = color;
}

pub fn getRow() usize {
    return terminal_row;
}

pub fn getColumn() usize {
    return terminal_column;
}

pub fn getColor() u8 {
    return terminal_color;
}

pub fn setPosition(row: usize, col: usize) void {
    terminal_row = row;
    terminal_column = col;
}

pub fn getEntryAt(x: usize, y: usize) u16 {
    return terminal_buffer[y * VGA_WIDTH + x];
}

pub fn putEntryAt(entry: u16, x: usize, y: usize) void {
    terminal_buffer[y * VGA_WIDTH + x] = entry;
}

pub fn clearScreen(color: u8) void {
    for (0..VGA_HEIGHT) |y| {
        for (0..VGA_WIDTH) |x| {
            terminal_buffer[y * VGA_WIDTH + x] = vgaEntry(' ', color);
        }
    }
}

pub fn enableCursor(start: u8, end: u8) void {
    _ = start;
    _ = end;
}

pub fn disableCursor() void { }

pub fn updateCursor() void {}
