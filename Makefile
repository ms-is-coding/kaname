# =========================
# Config
# =========================

ZIG_VERSION := 0.15.2
TOOLCHAIN_DIR := $(PWD)/toolchain
ZIG := $(TOOLCHAIN_DIR)/zig/zig
ZIG_FLAGS :=

# =========================
# Targets
# =========================

.PHONY: all
all: build


.PHONY: toolchain
toolchain:
	./scripts/install-zig.sh $(ZIG_VERSION) $(TOOLCHAIN_DIR)
	./scripts/install-mtools.sh $(TOOLCHAIN_DIR)


.PHONY: zig
zig:
	@if [ ! -f "$(ZIG)" ]; then \
		echo "Zig not found. Run 'make toolchain' first."; \
		exit 1; \
	fi


.PHONY: build
build: zig
	$(ZIG) build $(ZIG_FLAGS)


.PHONY: bonus
bonus: zig
	$(ZIG) build -Dfull=true $(ZIG_FLAGS)


.PHONY: run
run: zig
	PATH="$(TOOLCHAIN_DIR)/bin:$$PATH" $(ZIG) build run $(ZIG_FLAGS)


.PHONY: run-bonus
run-bonus: zig
	PATH="$(TOOLCHAIN_DIR)/bin:$$PATH" $(ZIG) build run -Dfull=true $(ZIG_FLAGS)


.PHONY: test
test: zig
	$(ZIG) build test $(ZIG_FLAGS)


.PHONY: fmt
fmt: zig
	$(ZIG) fmt kernel arch abi libk


.PHONY: clean
clean:
	rm -rf zig-out .zig-cache iso kfs.iso


.PHONY: distclean
distclean: clean
	rm -rf toolchain

