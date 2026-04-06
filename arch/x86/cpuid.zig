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
    clfsh: bool,
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
    sse41: bool,
    sse42: bool,
    x2apic: bool,
    movbe: bool,
    popcnt: bool,
    tscdeadline: bool,
    aesni: bool,
    xsave: bool,
    osxsave: bool,
    avx: bool,
    f16c: bool,
    rdrnd: bool,
    hypervisor: bool,
};

pub const CpuidResult = struct {
    edx: Features,
    ecx: ExtFeatures,
};

var cpuid_cache: ?CpuidResult = null;

fn cpuid1() CpuidResult {
    if (cpuid_cache) |c| return c;
    var edx: u32 = undefined;
    var ecx: u32 = undefined;
    asm volatile (
        \\pushl %%ebx
        \\cpuid
        \\popl %%ebx
        : [edx] "={edx}" (edx),
          [ecx] "={ecx}" (ecx),
        : [leaf] "{eax}" (@as(u32, 1)),
    );
    cpuid_cache = CpuidResult{ .edx = @bitCast(edx), .ecx = @bitCast(ecx) };
    return cpuid_cache.?;
}

pub fn features() Features {
    return cpuid1().edx;
}

pub fn extFeatures() ExtFeatures {
    return cpuid1().ecx;
}
