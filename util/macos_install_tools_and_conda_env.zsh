#!/usr/bin/env zsh
# author: Ludovic Blanc 
# ludovic.blanc@epfl.ch
# TCL EPFL 2026
# Usage: ./util/macos_install_tools_and_conda_env.zsh

# to undo:
# rm -rf tools
# conda remove --name core-v-mini-mcu --all
# brew uninstall <packages>

# --- Configuration & Versions ---
RISCV_V_DATE="20240530"
OSS_CAD_DATE="2026-02-15"
VERIBLE_HASH="v0.0-4051-g9fdb4057"
VERILATOR_VER="v5.040"

# --- System Validation ---
OS=$(uname -s)
ARCH=$(uname -m)
echo "--- Detected ${OS}/${ARCH} ---"

if [[ "$OS" != "Darwin" || "$ARCH" != "arm64" ]]; then
    echo "Error: This script requires macOS arm64. Found: ${OS}/${ARCH}"
    exit 1
fi

# --- Dependencies ---
echo "--- Installing Homebrew dependencies ---"
brew install libyaml libelf cmake ninja wget git flex bison systemc help2man autoconf automake meson

# --- Tool Download Paths ---
OSS_CAD_URL="https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${OSS_CAD_DATE}/oss-cad-suite-darwin-arm64-${OSS_CAD_DATE//-/}.tgz"
VERIBLE_URL="https://github.com/chipsalliance/verible/releases/download/${VERIBLE_HASH}/verible-${VERIBLE_HASH}-macOS.tar.gz"
RISCV_URL="https://buildbot.embecosm.com/job/corev-gcc-macos-arm64/8/artifact/corev-openhw-gcc-macos-${RISCV_V_DATE}.zip"

mkdir -p tools

# --- 1. OSS CAD Suite ---
echo "--- Downloading OSS CAD Suite ---"
wget -q --show-progress "$OSS_CAD_URL" -O oss-cad-suite.tgz
tar -xzf oss-cad-suite.tgz -C tools 
rm oss-cad-suite.tgz
# Remove quarantine with the activate scripts
# xattr -dr com.apple.quarantine tools/oss-cad-suite
echo "Allowing execution of quarantined files (you may be prompted for a password)..."
zsh tools/oss-cad-suite/activate

# --- 2. Verible ---
echo "--- Downloading Verible ---"
wget -q --show-progress "$VERIBLE_URL" -O verible.tgz
# Extracting directly into oss-cad-suite
tar -xzf verible.tgz -C tools/oss-cad-suite --strip-components=1
mv tools/oss-cad-suite/verible-*/bin/* tools/oss-cad-suite/bin/
rm -rf tools/oss-cad-suite/verible-* 
rm verible.tgz

# --- 3. RISC-V Toolchain ---
echo "--- Downloading RISC-V Toolchain ---"
wget -q --show-progress "$RISCV_URL" -O riscv.zip
unzip -q riscv.zip -d tools 
mv tools/corev-openhw-gcc-macos-${RISCV_V_DATE} tools/riscv-v
rm riscv.zip

# --- 4. Environment & Conda Setup ---
echo "--- Patching Conda Environment Files ---"
cp util/python-requirements.txt util/python-requirements_macos.txt
cp util/conda_environment.yml   util/conda_environment_macos.yml

# Clean up PyYAML for the version with C-binding installation (worked only through conda instead of pip installation on my side)

sed -i '' '/pyyaml/d' util/python-requirements_macos.txt
sed -i '' '/- pip:/i \
  - pyYAML' util/conda_environment_macos.yml

# Initialize Conda
CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"
conda env create -f util/conda_environment_macos.yml || echo "Conda env might already exist, skipping..."
source $(dirname "$0")/start_env_macos.zsh &> /dev/null

# --- 5. Custom Verilator Build ---
echo "--- Building Verilator ${VERILATOR_VER} ---"
pushd tools
[[ -d verilator ]] || git clone https://github.com/verilator/verilator.git
cd verilator
git checkout "$VERILATOR_VER"

FLEX_DIR=$(brew --prefix flex)
SYSC_DIR=$(brew --prefix systemc)

# Set build flags
export SYSTEMC_INCLUDE="${SYSC_DIR}/include"
export SYSTEMC_LIB="${SYSC_DIR}/lib"
export PATH="${FLEX_DIR}/bin:${PATH}"

ADDITIONAL_FLAGS=""
if [[ "$VERILATOR_VER" == v5.040* ]]; then
    echo "Applying macOS Clang patch for v5.040..."
    ADDITIONAL_FLAGS="-DVL_DEBUG"
    sed -i '' 's|V3Hash{reinterpret_cast<uintptr_t>(val)} {}|V3Hash{static_cast<uint64_t>(reinterpret_cast<uintptr_t>(val))} {}|g' src/V3Hash.h
fi

export CXXFLAGS="-I${FLEX_DIR}/include ${ADDITIONAL_FLAGS}"
export CFLAGS="-I${FLEX_DIR}/include ${ADDITIONAL_FLAGS}"
export LDFLAGS="-L${FLEX_DIR}/lib"
export VERILATOR_ROOT=$(pwd)

autoconf
./configure --enable-longtests
make -j$(sysctl -n hw.ncpu)

unset CFLAGS CXXFLAGS LDFLAGS
popd

echo "-------------------------------------------------------"
echo "Setup Complete!"
echo "To activate: source util/start_env_macos.zsh"
echo "-------------------------------------------------------"

