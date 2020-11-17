name = myhello

sources = $(name).c
objects = $(name).o

# Build output

build_dir = ./build
max_object = $(name).mxo
bundle = $(build_dir)/$(max_object)

# Dependencies

max_sdk = ../../../../max-sdk

jit_includes = $(max_sdk)/source/c74support/jit-includes
max_includes = $(max_sdk)/source/c74support/max-includes
msp_includes = $(max_sdk)/source/c74support/msp-includes

# Compiler

macosx_sdk := $(shell xcrun --sdk macosx --show-sdk-path)

cc := $(shell xcrun --sdk macosx --find clang) -isysroot $(macosx_sdk)

includes_flags = -I$(jit_includes) -I$(max_includes) -I$(msp_includes) \
-I$(macosx_sdk)/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Headers

frameworks_flags = -F$(jit_includes) -F$(max_includes) -F$(msp_includes) \
-framework JitterAPI -framework MaxAPI -framework MaxAudioAPI -framework MaxLua

# Recipes

.PHONY: all
all: $(bundle)/Contents/MacOS/$(name)

.PHONY: clean
clean:
	rm -f $(objects)
	rm -rf $(build_dir)

.PHONY: install
install: $(bundle) $(max_sdk)/externals
	cp -R $(bundle) $(max_sdk)/externals

.PHONY: uninstall
uninstall: $(max_sdk)/externals/$(max_object)
	rm -rf $(max_sdk)/externals/$(max_object)

$(max_sdk)/externals:
	mkdir $(max_sdk)/externals

$(bundle)/Contents/MacOS/$(name): $(bundle) $(objects)
	$(cc) -bundle $(includes_flags) $(frameworks_flags) -o $(bundle)/Contents/MacOS/$(name) $(objects)

$(bundle):
	mkdir -p $(bundle)/Contents/MacOS

$(objects): %.o: %.c
	$(cc) $(includes_flags) -c -o $@ $<
