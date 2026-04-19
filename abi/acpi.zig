const std = @import("std");

pub const Rsdp = extern struct {
    signature: [8]u8,
    checksum: u8,
    oem_id: [6]u8,
    revision: u8,
    rsdt_address: u32,

    pub fn isValid(self: *const Rsdp) bool {
        if (!std.mem.eql(u8, self.signature[0..], "RSD PTR ")) return false;

        var sum: u8 = 0;
        const bytes = @as([*]const u8, @ptrCast(self))[0..20];
        for (bytes) |b| sum +%= b;
        return sum == 0;
    }
};

pub const Xsdp = extern struct {
    signature: [8]u8,
    checksum: u8,
    oem_id: [6]u8,
    revision: u8,
    rsdt_address: u32, // deprecated

    length: u32,
    xsdt_address: u64,
    extended_checksum: u8,
    reserved: [3]u8,

    pub fn isValid(self: *const Xsdp) bool {
        if (!std.mem.eql(u8, self.signature[0..], "RSD PTR ")) return false;

        var sum: u8 = 0;
        const base_bytes = @as([*]const u8, @ptrCast(self))[0..20];
        for (base_bytes) |b| sum +%= b;
        if (sum != 0) return false;

        if (self.revision >= 2) {
            var ext_sum: u8 = 0;
            const all_bytes = @as([*]const u8, @ptrCast(self))[0..self.length];
            for (all_bytes) |b| ext_sum +%= b;
            return ext_sum == 0;
        }
        return true;
    }
};
