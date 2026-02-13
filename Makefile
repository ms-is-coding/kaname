ZIG_VERSION := 0.15.2

# Use system zig if available, otherwise download a local copy
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

  ZIG_TARBALL := zig-$(ZIG_OS)-$(ZIG_ARCH)-$(ZIG_VERSION).tar.xz
  ZIG_URL := https://ziglang.org/download/$(ZIG_VERSION)/$(ZIG_TARBALL)
  ZIG_DIR := zig-$(ZIG_OS)-$(ZIG_ARCH)-$(ZIG_VERSION)
  ZIG := $(ZIG_DIR)/zig
  ZIG_TARGET := $(ZIG)
endif

.PHONY: all build run test fmt clean distclean zig

all: build

$(ZIG_TARBALL):
	curl -LO $(ZIG_URL)

$(ZIG_DIR)/zig: $(ZIG_TARBALL)
	tar xf $(ZIG_TARBALL)
	touch $(ZIG_DIR)/zig

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
ifdef ZIG_DIR
	rm -rf $(ZIG_DIR) $(ZIG_TARBALL)
endif
