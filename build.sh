#!/bin/bash
set -euo pipefail

# Path variables
DIR=$(readlink -f .)
MAIN=$(readlink -f ${DIR}/..)

# Resources
export CLANG_PATH=$MAIN/clang-tc/bin/
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CROSS_COMPILE="aarch64-linux-gnu-"

# Manual ccache configuration if not running in github action
if [ -z "$GITHUB_ACTIONS" ]; then
    echo "Building in local machine!"
    mkdir -p "$(pwd)/.ccache" 2>/dev/null
    export CCACHE_DIR="$(pwd)/.ccache"
fi
export USE_CCACHE=1

# Config
THREAD="-j$(nproc --all)"
DEFCONFIG="bomb_defconfig"
export ARCH=arm64
export SUBARCH=$ARCH
export KBUILD_BUILD_USER=bachnxuan
LLVM_CONFIG=" AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip"
DATE_START=$(date +"%s")

make $THREAD CC="ccache clang" CXX="ccache clang++" LLVM=1 LLVM_IAS=1 $DEFCONFIG O=out
make $THREAD CC="ccache clang" CXX="ccache clang++" LLVM=1 LLVM_IAS=1 \
    LTO=thin O=out 2>&1 | tee kernel.log

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
