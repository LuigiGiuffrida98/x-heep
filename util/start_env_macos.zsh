#!/usr/bin/env zsh
# author: Ludovic Blanc 
# ludovic.blanc@epfl.ch
# TCL EPFL 2026
# Usage: source util/start_env_macos.zsh

# --- 1. Environment Detection ---
# Determine the absolute path to the directory containing this script
SCRIPT_DIR=$(cd -- "$(dirname -- "${(%):-%N}")" &> /dev/null && pwd)
TOOLS_DIR=$(realpath "$SCRIPT_DIR/../tools")

# --- 2. Conda Initialization ---
if [ -z "$CONDA_EXE" ]; then
    CONDA_BASE=$(conda info --base)
else
    CONDA_BASE="${CONDA_EXE%/bin/conda}"
fi
source "$CONDA_BASE/etc/profile.d/conda.sh"
conda activate core-v-mini-mcu

# --- 3. Dependency Paths (Homebrew) ---
if command -v brew >/dev/null; then
    LIBELF_PREFIX=$(brew --prefix libelf)
    export C_INCLUDE_PATH="$LIBELF_PREFIX/include${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
    export LIBRARY_PATH="$LIBELF_PREFIX/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi

# --- 4. Toolchain Exports ---
export RISCV_XHEEP=$(realpath "$TOOLS_DIR/riscv-v")

# OSS CAD Suite Setup
OSS_CAD_PATH="$TOOLS_DIR/oss-cad-suite"
if [[ "$(uname)" == "Darwin" ]]; then
    # Use the bundled realpath for macOS compatibility
    OSS_BIN_DIR="$("$OSS_CAD_PATH"/libexec/realpath "$OSS_CAD_PATH")/bin"
else
    OSS_BIN_DIR="$(realpath "$OSS_CAD_PATH")/bin"
fi

# Verilator Setup
VERILATOR_BIN=$(realpath "$TOOLS_DIR/verilator/bin")

# Update PATH (Prepend to ensure these versions are used)
export PATH="$VERILATOR_BIN:$OSS_BIN_DIR:$PATH"

# --- 5. Optional/SystemC Placeholder ---
# Note: Ensure these variables are defined elsewhere or update the paths below
if [ -n "$system_c_dir" ]; then
    export SYSTEMC_INCLUDE="$system_c_dir/include"
    export SYSTEMC_LIB="$system_c_dir/lib"
fi

if [ -n "$flex_dir" ]; then
    export PATH="$flex_dir/bin:$PATH"
fi

echo "✅ CORE-V Mini-MCU environment activated."