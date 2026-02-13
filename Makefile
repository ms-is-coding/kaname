ZIG_VERSION := 0.15.2
ZIG_SIG := $(ZIG_TARBALL).minisig
MIRROR_LIST := zig-mirrors.txt

# =========================
# System zig detection
# =========================

SYSTEM_ZIG := $(shell command -v zig 2>/dev/null)

ifdef SYSTEM_ZIG
  ZIG := $(SYSTEM_ZIG)
  ZIG_TARGET :=
else
  UNAME_S := $(shell uname -s)
  UNAME_M := $(shell uname -m)

  ifeq ($(UNAME_S),Linux)
    ZIG_OS := linux
  else ifeq ($(UNAME_S),Darwin)
    ZIG_OS := macos
  else
    $(error Unsupported OS: $(UNAME_S))
  endif

  ifeq ($(UNAME_M),x86_64)
    ZIG_ARCH := x86_64
  else ifeq ($(UNAME_M),aarch64)
    ZIG_ARCH := aarch64
  else ifeq ($(UNAME_M),arm64)
    ZIG_ARCH := aarch64
  else
    $(error Unsupported architecture: $(UNAME_M))
  endif

  ZIG_TARBALL := zig-$(ZIG_ARCH)-$(ZIG_OS)-$(ZIG_VERSION).tar.xz
  ZIG_SIG := $(ZIG_TARBALL).minisig
  ZIG_DIR := zig-$(ZIG_ARCH)-$(ZIG_OS)-$(ZIG_VERSION)
  ZIG := $(ZIG_DIR)/zig
  ZIG_TARGET := $(ZIG)
endif

# =========================
# Public key (REQUIRED)
# =========================

# Copy the official minisign public key from:
# https://ziglang.org/download
ZIG_PUBKEY := <PASTE_OFFICIAL_MINISIGN_PUBLIC_KEY_HERE>

# =========================
# Targets
# =========================

.PHONY: all build run test fmt clean distclean zig

all: build

# Fetch and shuffle community mirrors
$(MIRROR_LIST):
	curl -fsSL https://ziglang.org/download/community-mirrors.txt -o $@
	shuf $@ -o $@

# Download + verify Zig (only if not using system zig)
ifndef SYSTEM_ZIG

$(ZIG_TARBALL): $(MIRROR_LIST)
	@set -e; \
	for mirror in $$(cat $(MIRROR_LIST)); do \
		echo "Trying $$mirror/$(ZIG_TARBALL)"; \
		if wget -O $(ZIG_TARBALL) "$$mirror/$(ZIG_TARBALL)?source=makefile"; then \
			wget -O $(ZIG_SIG) "$$mirror/$(ZIG_SIG)?source=makefile"; \
			exit 0; \
		fi; \
		rm -f $(ZIG_TARBALL) $(ZIG_SIG); \
	done; \
	echo "All mirrors failed."; \
	exit 1
				# echo "Verifying signature..."; \
				# if minisign -Vm $(ZIG_TARBALL) -P "$(ZIG_PUBKEY)"; then \
				# 	echo "Successfully fetched Zig $(ZIG_VERSION)!"; \
				# 	exit 0; \
				# else \
				# 	echo "Signature verification failed."; \
				# fi; \


$(ZIG_DIR)/zig: $(ZIG_TARBALL)
	tar -xf $(ZIG_TARBALL)

endif

zig: $(ZIG_TARGET)

build: $(ZIG_TARGET)
	$(ZIG) build

run: $(ZIG_TARGET)
	$(ZIG) build run

test: $(ZIG_TARGET)
	$(ZIG) build test

fmt: $(ZIG_TARGET)
	$(ZIG) fmt src

clean:
	rm -rf zig-out .zig-cache

distclean: clean
ifndef SYSTEM_ZIG
	rm -rf $(ZIG_DIR) $(ZIG_TARBALL) $(ZIG_SIG) $(MIRROR_LIST)
endif

