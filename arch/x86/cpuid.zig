// https://en.wikipedia.org/wiki/CPUID

pub const Features = packed struct(u32) {
    fpu: bool,
    vme: bool,
    de: bool,
    pse: bool,
    tsc: bool,
    msr: bool,
    pae: bool,
    mce: bool,
    cx8: bool,
    apic: bool,
    _reserved0: u1,
    sep: bool,
    mtrr: bool,
    pge: bool,
    mca: bool,
    cmov: bool,
    pat: bool,
    pse36: bool,
    psn: bool,
    clflush: bool,
    _reserved1: u1, // NX bit (titanium only)
    ds: bool,
    acpi: bool,
    mmx: bool,
    fxsr: bool,
    sse: bool,
    sse2: bool,
    ss: bool,
    htt: bool,
    tm: bool,
    ia64: bool,
    pbe: bool,
};

pub const ExtFeatures = packed struct(u32) {
    sse3: bool,
    pclmulqdq: bool,
    dtes64: bool,
    monitor: bool,
    dscpl: bool,
    vmx: bool,
    smx: bool,
    est: bool,
    tm2: bool,
    ssse3: bool,
    cnxtid: bool,
    sdbg: bool,
    fma: bool,
    cx16: bool,
    xtpr: bool,
    pdcm: bool,
    _reserved: u1,
    pcid: bool,
    dca: bool,
    sse4_1: bool,
    sse4_2: bool,
    x2apic: bool,
    movbe: bool,
    popcnt: bool,
    tscdeadline: bool,
    aes: bool,
    xsave: bool,
    osxsave: bool,
    avx: bool,
    f16c: bool,
    rdrand: bool,
    hypervisor: bool,
};

pub const FamilyInfo = packed struct(u32) {
    stepping: u4,
    model: u4,
    family: u4,
    processor_type: u2,
    _reserved0: u2,
    extended_model: u4,
    extended_family: u8,
    _reserved1: u4,
};

pub const CpuidResult = struct {
    eax: FamilyInfo,
    edx: Features,
    ecx: ExtFeatures,
};

var processor_info_cache: ?CpuidResult = null;

fn processorInfo() CpuidResult {
    if (processor_info_cache) |c| return c;
    var edx: u32 = undefined;
    var ecx: u32 = undefined;
    var eax: u32 = undefined;
    asm volatile (
        \\pushl %%ebx
        \\cpuid
        \\popl %%ebx
        : [edx] "={edx}" (edx),
          [ecx] "={ecx}" (ecx),
          [eax] "={eax}" (eax),
        : [leaf] "{eax}" (@as(u32, 1)),
    );
    processor_info_cache = CpuidResult{
        .eax = @bitCast(eax),
        .edx = @bitCast(edx),
        .ecx = @bitCast(ecx),
    };
    return processor_info_cache.?;
}

pub fn features() Features {
    return processorInfo().edx;
}

pub fn extFeatures() ExtFeatures {
    return processorInfo().ecx;
}

pub fn familyInfo() FamilyInfo {
    return processorInfo().eax;
}

pub fn effectiveFamily(info: FamilyInfo) u12 {
    if (info.family != 0xF) return info.family;
    return @as(u12, info.extended_family) + info.family;
}

pub fn effectiveModel(info: FamilyInfo) u8 {
    if (info.family == 0x6 or info.family == 0xF)
        return (@as(u8, info.extended_model) << 4) | info.model;
    return info.model;
}

pub fn vendorString() [12]u8 {
    var ebx: u32 = undefined;
    var edx: u32 = undefined;
    var ecx: u32 = undefined;
    asm volatile (
        \\pushl %%ebx
        \\cpuid
        \\movl %%ebx, %[ebx]
        \\popl %%ebx
        : [ebx] "=r" (ebx),
          [edx] "={edx}" (edx),
          [ecx] "={ecx}" (ecx),
        : [leaf] "{eax}" (@as(u32, 0)),
    );
    var result: [12]u8 = undefined;
    @memcpy(result[0..4], @as(*const [4]u8, @ptrCast(&ebx)));
    @memcpy(result[4..8], @as(*const [4]u8, @ptrCast(&edx)));
    @memcpy(result[8..12], @as(*const [4]u8, @ptrCast(&ecx)));
    return result;
}

pub fn maxExtLeaf() u32 {
    var eax: u32 = undefined;
    asm volatile (
        \\pushl %%ebx
        \\cpuid
        \\popl %%ebx
        : [eax] "={eax}" (eax),
        : [leaf] "{eax}" (@as(u32, 0x80000000)),
    );
    return eax;
}

pub fn brandString() [48]u8 {
    @setRuntimeSafety(false);
    var result: [48]u8 = undefined;
    if (maxExtLeaf() < 0x80000004) {
        @memset(&result, 0);
        return result;
    }
    inline for (0..3) |i| {
        var eax: u32 = undefined;
        var ebx: u32 = undefined;
        var ecx: u32 = undefined;
        var edx: u32 = undefined;
        asm volatile (
            \\pushl %%ebx
            \\cpuid
            \\movl %%ebx, %[ebx]
            \\popl %%ebx
            : [eax] "={eax}" (eax),
              [ebx] "=r" (ebx),
              [ecx] "={ecx}" (ecx),
              [edx] "={edx}" (edx),
            : [leaf] "{eax}" (@as(u32, 0x80000002) + i),
        );
        const off = i * 16;
        @memcpy(result[off..][0..4], @as(*const [4]u8, @ptrCast(&eax)));
        @memcpy(result[off + 4 ..][0..4], @as(*const [4]u8, @ptrCast(&ebx)));
        @memcpy(result[off + 8 ..][0..4], @as(*const [4]u8, @ptrCast(&ecx)));
        @memcpy(result[off + 12 ..][0..4], @as(*const [4]u8, @ptrCast(&edx)));
    }
    return result;
}

pub const ProcessorFeatureBits = packed struct(u32) {
    clzero: bool,
    retired_instr: bool,
    xrstor_fp_err: bool,
    invlpgb: bool,
    rdpru: bool,
    xotext: bool,
    mbe: bool,
    _reserved0: u1,
    mcummit: bool,
    wbnoinvd: bool,
    _reserved1: u2,
    ibpb: bool,
    wbinvd_int: bool,
    ibrs: bool,
    stibp: bool,
    ibrs_always_on: bool,
    stibp_always_on: bool,
    ibrs_preferred: bool,
    ibrs_same_mode_protection: bool,
    no_efer_lmsle: bool,
    invlpgb_nested: bool,
    _reserved2: u1,
    ppin: bool,
    ssbd: bool,
    ssbd_legacy: bool,
    ssbd_no: bool,
    cppc: bool,
    psfd: bool,
    btc_no: bool,
    ibpb_ret: bool,
    branch_sampling: bool,
};

pub const AddressSizes = struct {
    eax: packed struct(u32) {
        physical_address_bits: u8,
        linear_address_bits: u8,
        guest_physical_address_size: u8,
        _reserved: u8,
    },
    ebx: ProcessorFeatureBits,
    ecx: packed struct(u32) {
        physical_threads_minus1: u8,
        _reserved0: u4,
        apic_id_size: u4,
        perf_tsc_size: u2,
        _reserved1: u14,
    },
    edx: packed struct(u32) {
        max_invlpgb_page_count: u16,
        _reserved0: u2,
        max_rdpru_ecx: u6,
        _reserved1: u8,
    },
};

pub fn addressSizes() AddressSizes {
    var eax: u32 = undefined;
    var ebx: u32 = undefined;
    var ecx: u32 = undefined;
    var edx: u32 = undefined;
    asm volatile (
        \\pushl %%ebx
        \\cpuid
        \\movl %%ebx, %[ebx]
        \\popl %%ebx
        : [eax] "={eax}" (eax),
          [ebx] "=r" (ebx),
          [ecx] "={ecx}" (ecx),
          [edx] "={edx}" (edx),
        : [leaf] "{eax}" (@as(u32, 0x80000008)),
    );
    return .{
        .eax = @bitCast(eax),
        .ebx = @bitCast(ebx),
        .ecx = @bitCast(ecx),
        .edx = @bitCast(edx),
    };
}
