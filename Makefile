# =========================
# Config
# =========================

ZIG_VERSION := 0.16.0
ZIG_FLAGS :=
ZIG := zig

# =========================
# Targets
# =========================

.PHONY: all
all: build


.PHONY: build
build:
	$(ZIG) build $(ZIG_FLAGS)


.PHONY: bonus
bonus:
	$(ZIG) build -Dfull=true $(ZIG_FLAGS)


.PHONY: iso
iso:
	$(ZIG) build iso


.PHONY: iso-limine
iso-limine:
	$(ZIG) build iso-limine


.PHONY: run
run:
	$(ZIG) build run $(ZIG_FLAGS)


.PHONY: run-limine
run-limine:
	$(ZIG) build run-limine $(ZIG_FLAGS)


.PHONY: run-bonus
run-bonus:
	$(ZIG) build run -Dfull=true $(ZIG_FLAGS)


.PHONY: test
test:
	$(ZIG) build test $(ZIG_FLAGS)


.PHONY: fmt
fmt:
	$(ZIG) fmt kernel arch abi drivers


.PHONY: clean
clean:
	rm -rf zig-out .zig-cache iso kfs.iso iso-limine kfs-limine.iso


.PHONY: distclean
distclean: clean
	rm -rf toolchain

