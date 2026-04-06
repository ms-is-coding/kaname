const ports = @import("ports.zig");

// https://wiki.osdev.org/8259_PIC

const PIC1_CMD = 0x20;
const PIC1_DATA = 0x21;
const PIC2_CMD = 0xA0;
const PIC2_DATA = 0xA1;

const PIC_EOI = 0x20;

const ICW1_ICW4 = 0x01;
const ICW1_SINGLE = 0x02;
const ICW1_INTERVAL4 = 0x04;
const ICW1_LEVEL = 0x08;
const ICW1_INIT = 0x10;

const ICW4_8086 = 0x01;
const ICW4_AUTO = 0x02;
const ICW4_BUF_SLAVE = 0x04;
const ICW4_BUF_MASTER = 0x08;
const ICW4_SFNM = 0x10;

const CASCADE_IRQ = 2;

pub const PIC1_OFFSET = 0x20;
pub const PIC2_OFFSET = 0x28;

pub fn init() void {
    // ICW1: begin init sequence
    ports.outb(PIC1_CMD, ICW1_INIT | ICW1_ICW4);
    ports.ioWait();
    ports.outb(PIC2_CMD, ICW1_INIT | ICW1_ICW4);
    ports.ioWait();

    // ICW2: vector offsets
    ports.outb(PIC1_CMD, PIC1_OFFSET);
    ports.ioWait();
    ports.outb(PIC2_CMD, PIC2_OFFSET);
    ports.ioWait();

    // ICW3: master/slave wiring
    ports.outb(PIC1_CMD, 1 << CASCADE_IRQ); // slave on IRQ2
    ports.ioWait();
    ports.outb(PIC2_CMD, 0x02); // slave cascade identity
    ports.ioWait();

    // ICW4: 8086 mode
    ports.outb(PIC1_CMD, ICW4_8086);
    ports.ioWait();
    ports.outb(PIC2_CMD, ICW4_8086);
    ports.ioWait();

    maskAll();
}

pub fn sendEoi(vector: u8) void {
    if (vector >= PIC2_OFFSET) {
        ports.outb(PIC2_CMD, PIC_EOI);
    }
    ports.outb(PIC1_CMD, PIC_EOI);
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

pub fn unMaskAll() void {
    ports.outb(PIC1_DATA, 0);
    ports.outb(PIC2_DATA, 0);
}
