#!/bin/bash

# Color codes (using -e flag in echo or double quotes for printf)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get the base directory (assuming script is in test/test_cpus/)
BASE_DIR="$(cd "$(dirname "$0")/../../" && pwd)"

# Array of CPUs to test
CPUS=("cv32e40p")

# Print table header
printf "\n${BOLD}%-29s | %-17s | %-17s | %-17s${NC}\n" "CPU" "Generation" "Compilation" "Simulation"
printf "${BOLD}%-29s-+-%-17s-+-%-17s-+-%-17s${NC}\n" "$(printf '%29s' | tr ' ' '-')" "$(printf '%17s' | tr ' ' '-')" "$(printf '%17s' | tr ' ' '-')" "$(printf '%17s' | tr ' ' '-')"

# Iterate through each CPU and run mcu-gen
for cpu in "${CPUS[@]}"; do
    if [ -n "$cpu" ]; then
        cd "$BASE_DIR"
        
        # Try to generate MCU
        if make mcu-gen X_HEEP_CFG="$(pwd)/test/test_cpus/python_unsupported.hjson" PYTHON_X_HEEP_CFG="$(pwd)/test/test_cpus/${cpu}_test.py" > /dev/null 2>&1; then
            gen_status="${GREEN}OK${NC}"
            
            # If generation successful, run compilation
            if python3 test/test_apps/test_apps.py --compile-only > /tmp/test_output.log 2>&1; then
                comp_status="${GREEN}OK${NC}"
                
                # If compilation successful, run simulation
                if python3 test/test_apps/test_apps.py > /tmp/test_output.log 2>&1; then
                    sim_status="${GREEN}OK${NC}"
                else
                    sim_status="${RED}FAIL${NC}"
                fi
            else
                comp_status="${RED}FAIL${NC}"
                sim_status="${YELLOW}SKIPPED${NC}"
            fi
        else
            gen_status="${RED}FAIL${NC}"
            comp_status="${YELLOW}SKIPPED${NC}"
            sim_status="${YELLOW}SKIPPED${NC}"
            # Print error details on generation failure
            echo ""
            make mcu-gen X_HEEP_CFG="$(pwd)/test/test_cpus/python_unsupported.hjson" PYTHON_X_HEEP_CFG="$(pwd)/test/test_cpus/${cpu}_test.py"
            echo ""
        fi
        
        # Pad status values to correct width accounting for color codes
        # Color codes add ~9 chars but take 0 visual space, so we reduce padding
        gen_padded=$(printf '%b' "$gen_status" | sed "s/\x1b\[[0-9;]*m//g")
        comp_padded=$(printf '%b' "$comp_status" | sed "s/\x1b\[[0-9;]*m//g")
        sim_padded=$(printf '%b' "$sim_status" | sed "s/\x1b\[[0-9;]*m//g")
        gen_spaces=$((17 - ${#gen_padded}))
        comp_spaces=$((17 - ${#comp_padded}))
        sim_spaces=$((17 - ${#sim_padded}))
        
        printf -- "%-29s | %b%*s | %b%*s | %b%*s\n" "$cpu" "$gen_status" "$gen_spaces" "" "$comp_status" "$comp_spaces" "" "$sim_status" "$sim_spaces" ""
    fi
done

printf "\n"

