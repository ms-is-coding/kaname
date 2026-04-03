const ports = @import("ports.zig");

const PIC1_CMD = 0x20;
const PIC1_DATA = 0x21;
const PIC2_CMD = 0xA0;
const PIC2_DATA = 0xA1;

const ICW1_INIT = 0x11;
const ICW4_8086 = 0x01;

pub const PIC1_OFFSET = 0x20;
pub const PIC2_OFFSET = 0x28;

pub fn init() void {
    // ICW1: begin init sequence
    ports.outb(PIC1_CMD, ICW1_INIT);
    ports.ioWait();
    ports.outb(PIC2_CMD, ICW1_INIT);
    ports.ioWait();

    // ICW2: vector offsets
    ports.outb(PIC1_CMD, PIC1_OFFSET);
    ports.ioWait();
    ports.outb(PIC2_CMD, PIC2_OFFSET);
    ports.ioWait();

    // ICW3: master/slave wiring
    ports.outb(PIC1_CMD, 0x04); // slave on IRQ2
    ports.ioWait();
    ports.outb(PIC2_CMD, 0x02); // slave cascade identity
    ports.ioWait();

    // ICW4: 8086 mode
    ports.outb(PIC1_CMD, ICW4_8086);
    ports.ioWait();
    ports.outb(PIC2_CMD, ICW4_8086);
    ports.ioWait();

    ports.maskAll();
}

pub fn sendEoi(vector: u8) void {
    if (vector >= PIC2_OFFSET) {
        ports.outb(PIC2_CMD, 0x20);
    }
    ports.outb(PIC1_CMD, 0x20);
}

pub fn maskIrq(irq: u4) void {
    if (irq < 8) {
        const val = ports.inb(PIC1_DATA);
        ports.outb(PIC1_DATA, val | (@as(u8, 1) << @truncate(irq)));
    } else {
        const val = ports.inb(PIC2_DATA);
        ports.outb(PIC2_DATA, val | (@as(u8, 1) << @truncate(irq - 8)));
    }
}

pub fn unMaskIrq(irq: u4) void {
    if (irq < 8) {
        const val = ports.inb(PIC1_DATA);
        ports.outb(PIC1_DATA, val & ~(@as(u8, 1) << @truncate(irq)));
    } else {
        // Unmask cascade on master (IRQ2)
        const master_val = ports.inb(PIC1_DATA);
        ports.outb(PIC1_DATA, master_val & ~(@as(u8, 1) << 2));
        const val = ports.inb(PIC2_DATA);
        ports.outb(PIC2_DATA, val & ~(@as(u8, 1) << @truncate(irq - 8)));
        ports.outb(PIC2_DATA, val | (@as(u8, 1) << @truncate(irq - 8)));
    }
}

pub fn maskAll() void {
    ports.outb(PIC1_DATA, 0xFF);
    ports.outb(PIC2_DATA, 0xFF);
}
