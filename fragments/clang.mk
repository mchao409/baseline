LLVM_DIR         ?= $(BSG_MANYCORE_DIR)/software/riscv-tools/llvm/llvm-install
LLVM_CLANG       ?= $(LLVM_DIR)/bin/clang
LLVM_OPT         ?= $(LLVM_DIR)/bin/opt
LLVM_LLC         ?= $(LLVM_DIR)/bin/llc
PASS_DIR         ?= $(BSG_MANYCORE_DIR)/software/manycore-llvm-pass
PASS_LIB         ?= build/manycore/libManycorePass.so
RUNTIME_FNS      ?= $(BSG_MANYCORE_DIR)/software/bsg_manycore_lib/bsg_tilegroup.h

RISCV_GCC_OPTS += -mno-fdiv

$(LLVM_DIR):
	@echo "LLVM is not installed! Follow build instructions in the TRM and \
	set LLVM_DIR in Makefile.builddefs accordingly" && exit 1

# Remove default %.o: %.c rule
%.o: %.c
%.o: %.cpp

# Emit -O0 so that loads to consecutive memory locations aren't combined
# Opt can run optimizations in any order, so it doesn't matter
%.bc: %.c $(PASS_LIB) $(LLVM_DIR) $(RUNTIME_FNS)
	$(LLVM_CLANG) $(RISCV_GCC_OPTS) $(OPT_LEVEL) $(spmd_defs) -c -emit-llvm $(INCS) $< -o $@

# do the same for C++ sources
%.bc: %.cpp $(PASS_LIB) $(LLVM_DIR) $(RUNTIME_FNS)
	$(LLVM_CLANG) $(RISCV_GXX_OPTS) $(OPT_LEVEL) $(spmd_defs) -c -emit-llvm $(INCS) $< -o $@

%.bc.pass: %.bc
	$(LLVM_OPT) -load $(PASS_LIB) -manycore $(OPT_LEVEL) $< -o $@

%.bc.s: %.bc.pass
	$(LLVM_LLC) $< -o $@

%.o: %.bc.s
	$(RISCV_GCC) $(RISCV_GCC_OPTS) $(OPT_LEVEL) -c $< -o $@


$(PASS_LIB): $(PASS_DIR)/manycore/Manycore.cpp $(LLVM_DIR)
	mkdir -p build
	cd build && LLVM_DIR=$(LLVM_DIR) cmake3 $(PASS_DIR) -Dbsg_group_size:INTEGER=$(bsg_group_size) && make
