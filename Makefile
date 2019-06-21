CHEERP_ROOT=/Applications/cheerp
CHEERP_BIN=$(CHEERP_ROOT)/bin

ROOT_DIR := $(shell dirname "$(realpath $(lastword $(MAKEFILE_LIST)))")

GMP_VERSION=6.1.2
GMP_DIR=gmp-$(GMP_VERSION)
GMP_TAR=$(GMP_DIR).tar.bz2
GMP_URL=https://ftp.gnu.org/pub/gnu/gmp/$(GMP_TAR)
GMP_MAKE_BINS=$(addprefix $(GMP_DIR)/, gen-fib gen-fac gen-bases gen-trialdivtab gen-jacobitab gen-psqr)

all: git-submodules gmp ethsnarks
	echo ...

installroot:
	mkdir -p $@

build:
	mkdir -p $@

git-submodules:
	git submodule update --init --recursive


#######################################################################
# ethsnarks

ethsnarks-patches:
	#cd ./ethsnarks/depends/libsnark/depends/libff && patch -p1 < $(ROOT_DIR)/libff.patch
	#cd ./ethsnarks/depends/libsnark/depends/libfqfft/depends/libff && patch -p1 < $(ROOT_DIR)/libff.patch
	#cd ./ethsnarks/depends/libsnark/depends/libfqfft && patch -p1 < $(ROOT_DIR)/libqfft.patch

ethsnarks: build.cheerp/test_hashpreimage.js

build.cheerp/test_hashpreimage.js: build/cmake_install.cmake # ethsnarks-patches
	make -C build

build/cmake_install.cmake: build
	cd build && cmake -DCMAKE_TOOLCHAIN_FILE=$(CHEERP_ROOT)/share/cmake/Modules/CheerpToolchain.cmake .. # -DWITH_PROCPS=OFF -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON -DCMAKE_PREFIX_PATH=`pwd`/../installroot/ 


#######################################################################
# GMP

gmp-bins: $(GMP_MAKE_BINS)

.PHONY: gmp
gmp: installroot/lib/libgmp.a

installroot/lib/libgmp.a: $(GMP_DIR) $(GMP_MAKE_BINS) $(GMP_DIR)/Makefile 
	make -C $(GMP_DIR)
	$(CHEERP_BIN)/llvm-link -o $(GMP_DIR)/.libs/libgmp.a $(GMP_DIR)/*.bc $(GMP_DIR)/mpn/*.bc $(GMP_DIR)/mpz/*.bc $(GMP_DIR)/mpf/*.bc $(GMP_DIR)/rand/*.bc
	make -C $(GMP_DIR) install

$(GMP_DIR)/Makefile: $(GMP_DIR)
	cd $< && sed -i.bak -e 's/ obstack_vprintf / /' configure.ac
	cd $< && sed -i.bak -e 's/^# Only do the GMP_ASM .*/gmp_asm_syntax_testing=no/' configure.ac
	cd $< && autoconf
	cd $< && ./configure --prefix=`pwd`/../installroot/ ABI=standard CC=$(CHEERP_BIN)/clang RANLIB=$(CHEERP_BIN)/llvm-ranlib AR=$(CHEERP_BIN)/llvm-ar NM=$(CHEERP_BIN)/llvm-nm LD=$(CHEERP_BIN)/llvm-link CFLAGS="-target cheerp -cheerp-mode=wasm -O2" --host=none --disable-assembly --disable-shared

$(GMP_DIR): $(GMP_TAR)
	tar -xf $<

$(GMP_TAR):
	curl -o $@ $(GMP_URL)

$(GMP_DIR)/gen-fib: $(GMP_DIR)/gen-fib.c

$(GMP_DIR)/gen-fac: $(GMP_DIR)/gen-fac.c

$(GMP_DIR)/gen-bases: $(GMP_DIR)/gen-bases.c

$(GMP_DIR)/gen-trialdivtab: $(GMP_DIR)/gen-trialdivtab.c

$(GMP_DIR)/gen-jacobitab: $(GMP_DIR)/gen-jacobitab.c

$(GMP_DIR)/gen-psqr: $(GMP_DIR)/gen-psqr.c
