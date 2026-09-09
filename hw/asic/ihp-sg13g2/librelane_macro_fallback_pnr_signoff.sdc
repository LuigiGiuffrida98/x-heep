# NOTE: This file is based on the IHP-GmbH/ihp-sg13g2-librelane-template (https://github.com/IHP-GmbH/ihp-sg13g2-librelane-template) github repo

current_design $::env(DESIGN_NAME)
set_units -time ns

set clock_port __VIRTUAL_CLK__
if { [info exists ::env(CLOCK_PORT)] } {
    set port_count [llength $::env(CLOCK_PORT)]

    if { $port_count == "0" } {
        puts "\[WARNING] No CLOCK_PORT found. A dummy clock will be used."
    } elseif { $port_count != "1" } {
        puts "\[WARNING] Multi-clock files are not currently supported by the base SDC file. Only the first clock will be constrained."
    }

    if { $port_count > "0" } {
        set ::clock_port [lindex $::env(CLOCK_PORT) 0]
    }
}

if { $::env(CLOCK_PORT) == $::env(CLOCK_NET) } {
    set port_args [get_ports $clock_port]
} else {
    # This should actually use CLOCK_PIN?
    set port_args [get_pins [lindex $::env(CLOCK_NET) 0]]
}

puts "\[INFO] Using clock $clock_port…"
create_clock {*}$port_args -name $clock_port -period $::env(CLOCK_PERIOD)

set input_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_DELAY_CONSTRAINT) / 100]
set output_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_DELAY_CONSTRAINT) / 100]
puts "\[INFO] Setting output delay to: $output_delay_value"
puts "\[INFO] Setting input delay to: $input_delay_value"

set_max_fanout $::env(MAX_FANOUT_CONSTRAINT) [current_design]
if { [info exists ::env(MAX_TRANSITION_CONSTRAINT)] } {
    set_max_transition $::env(MAX_TRANSITION_CONSTRAINT) [current_design]
}
if { [info exists ::env(MAX_CAPACITANCE_CONSTRAINT)] } {
    set_max_capacitance $::env(MAX_CAPACITANCE_CONSTRAINT) [current_design]
}

set clocks [get_clocks $clock_port]

# Input-only pads
set clk_core_input_ports [get_ports {

      gpio_1_i
      gpio_2_i
      gpio_3_i
      gpio_4_i
      gpio_5_i
      gpio_6_i
      gpio_7_i
      gpio_8_i
      gpio_9_i
      gpio_10_i
      gpio_11_i
      gpio_12_i
      gpio_13_i
      spi_flash_sck_i
      spi_flash_cs_0_i
      spi_flash_cs_1_i
      spi_flash_sd_0_i
      spi_flash_sd_1_i
      spi_flash_sd_2_i
      spi_flash_sd_3_i
      spi_sck_i
      spi_cs_0_i
      spi_cs_1_i
      spi_sd_0_i
      spi_sd_1_i
      spi_sd_2_i
      spi_sd_3_i
      spi_slave_sck_i
      spi_slave_cs_i
      spi_slave_miso_i
      spi_slave_mosi_i
      pdm2pcm_pdm_i
      pdm2pcm_clk_i
      i2s_sck_i
      i2s_ws_i
      i2s_sd_i
      spi2_cs_0_i
      spi2_cs_1_i
      spi2_sck_i
      spi2_sd_0_i
      spi2_sd_1_i
      spi2_sd_2_i
      spi2_sd_3_i
      i2c_scl_i
      i2c_sda_i
      clk_i
      rst_ni
      boot_select_i
      execute_from_flash_i
      jtag_tck_i
      jtag_tms_i
      jtag_trst_ni
      jtag_tdi_i
        uart_rx_i
          ddr_rcv_clk_i
        gpio_0_i
}]

set_input_delay -min 0 -clock $clocks $clk_core_input_ports
set_input_delay -max $input_delay_value -clock $clocks $clk_core_input_ports

# Output-only pads
set clk_core_output_ports [get_ports {

      gpio_1_oe
    gpio_1_o
      gpio_2_oe
    gpio_2_o
      gpio_3_oe
    gpio_3_o
      gpio_4_oe
    gpio_4_o
      gpio_5_oe
    gpio_5_o
      gpio_6_oe
    gpio_6_o
      gpio_7_oe
    gpio_7_o
      gpio_8_oe
    gpio_8_o
      gpio_9_oe
    gpio_9_o
      gpio_10_oe
    gpio_10_o
      gpio_11_oe
    gpio_11_o
      gpio_12_oe
    gpio_12_o
      gpio_13_oe
    gpio_13_o
      spi_flash_sck_oe
    spi_flash_sck_o
      spi_flash_cs_0_oe
    spi_flash_cs_0_o
      spi_flash_cs_1_oe
    spi_flash_cs_1_o
      spi_flash_sd_0_oe
    spi_flash_sd_0_o
      spi_flash_sd_1_oe
    spi_flash_sd_1_o
      spi_flash_sd_2_oe
    spi_flash_sd_2_o
      spi_flash_sd_3_oe
    spi_flash_sd_3_o
      spi_sck_oe
    spi_sck_o
      spi_cs_0_oe
    spi_cs_0_o
      spi_cs_1_oe
    spi_cs_1_o
      spi_sd_0_oe
    spi_sd_0_o
      spi_sd_1_oe
    spi_sd_1_o
      spi_sd_2_oe
    spi_sd_2_o
      spi_sd_3_oe
    spi_sd_3_o
      spi_slave_sck_oe
    spi_slave_sck_o
      spi_slave_cs_oe
    spi_slave_cs_o
      spi_slave_miso_oe
    spi_slave_miso_o
      spi_slave_mosi_oe
    spi_slave_mosi_o
      pdm2pcm_pdm_oe
    pdm2pcm_pdm_o
      pdm2pcm_clk_oe
    pdm2pcm_clk_o
      i2s_sck_oe
    i2s_sck_o
      i2s_ws_oe
    i2s_ws_o
      i2s_sd_oe
    i2s_sd_o
      spi2_cs_0_oe
    spi2_cs_0_o
      spi2_cs_1_oe
    spi2_cs_1_o
      spi2_sck_oe
    spi2_sck_o
      spi2_sd_0_oe
    spi2_sd_0_o
      spi2_sd_1_oe
    spi2_sd_1_o
      spi2_sd_2_oe
    spi2_sd_2_o
      spi2_sd_3_oe
    spi2_sd_3_o
      i2c_scl_oe
    i2c_scl_o
      i2c_sda_oe
    i2c_sda_o
                      jtag_tdo_oe
    jtag_tdo_o
        uart_tx_oe
    uart_tx_o
      exit_valid_oe
    exit_valid_o
        ddr_snd_clk_oe
    ddr_snd_clk_o
      gpio_0_oe
    gpio_0_o
}]

set_output_delay $output_delay_value -clock $clocks $clk_core_output_ports

# Bidirectional pads
set clk_core_inout_ports [get_ports {
}]

set_input_delay -min 0 -clock $clocks $clk_core_inout_ports
set_input_delay -max $input_delay_value -clock $clocks $clk_core_inout_ports
set_output_delay $output_delay_value -clock $clocks $clk_core_inout_ports

set cap_load [expr $::env(OUTPUT_CAP_LOAD) / 1000.0]
puts "\[INFO] Setting load to: $cap_load"
set_load $cap_load [all_outputs]

puts "\[INFO] Setting clock uncertainty to: $::env(CLOCK_UNCERTAINTY_CONSTRAINT)"
set_clock_uncertainty $::env(CLOCK_UNCERTAINTY_CONSTRAINT) $clocks

puts "\[INFO] Setting clock transition to: $::env(CLOCK_TRANSITION_CONSTRAINT)"
set_clock_transition $::env(CLOCK_TRANSITION_CONSTRAINT) $clocks

puts "\[INFO] Setting timing derate to: $::env(TIME_DERATING_CONSTRAINT)%"
set_timing_derate -early [expr 1-[expr $::env(TIME_DERATING_CONSTRAINT) / 100]]
set_timing_derate -late [expr 1+[expr $::env(TIME_DERATING_CONSTRAINT) / 100]]

if { [info exists ::env(OPENLANE_SDC_IDEAL_CLOCKS)] && $::env(OPENLANE_SDC_IDEAL_CLOCKS) } {
    unset_propagated_clock [all_clocks]
} else {
    set_propagated_clock [all_clocks]
}
