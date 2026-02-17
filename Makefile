# =========================
# Config
# =========================

ZIG_VERSION := 0.15.2
TOOLCHAIN_DIR := $(PWD)/toolchain
ZIG := $(TOOLCHAIN_DIR)/zig/zig

# =========================
# Targets
# =========================

.PHONY: all build run test fmt clean distclean zig toolchain

all: build

# Install local toolchain (zig + mtools)
toolchain:
	./scripts/install-zig.sh $(ZIG_VERSION) $(TOOLCHAIN_DIR)
	./scripts/install-mtools.sh $(TOOLCHAIN_DIR)

zig:
	@if [ ! -f "$(ZIG)" ]; then \
		echo "Zig not found. Run 'make toolchain' first."; \
		exit 1; \
	fi

build: zig
	$(ZIG) build

run: zig
	PATH="$(TOOLCHAIN_DIR)/bin:$$PATH" $(ZIG) build run

test: zig
	$(ZIG) build test

fmt: zig
	$(ZIG) fmt kernel arch abi libk

clean:
	rm -rf zig-out .zig-cache

distclean: clean
	rm -rf toolchain

