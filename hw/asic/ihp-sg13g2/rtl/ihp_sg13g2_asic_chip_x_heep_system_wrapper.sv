// Copyright 2022 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1






module ihp_sg13g2_asic_x_heep_system_wrapper #(
    parameter logic [31:0] XHEEP_INSTANCE_ID = 0,
    parameter EXT_XBAR_NMASTER = 0,
    parameter AO_SPC_NUM = 0,
    //do not touch these parameters
    parameter AO_SPC_NUM_RND = AO_SPC_NUM == 0 ? 0 : AO_SPC_NUM - 1,
    parameter EXT_XBAR_NMASTER_RND = EXT_XBAR_NMASTER == 0 ? 1 : EXT_XBAR_NMASTER,
    parameter EXT_DOMAINS_RND = core_v_mini_mcu_pkg::EXTERNAL_DOMAINS == 0 ? 1 : core_v_mini_mcu_pkg::EXTERNAL_DOMAINS,
    parameter NEXT_INT_RND = core_v_mini_mcu_pkg::NEXT_INT == 0 ? 1 : core_v_mini_mcu_pkg::NEXT_INT,
    // OBI and register interface data types
    parameter type obi_req_t  = xheep_obi_pkg::xheep_obi_req_t,
    parameter type obi_rsp_t  = xheep_obi_pkg::xheep_obi_rsp_t,
    parameter type reg_req_t  = xheep_reg_pkg::xheep_reg_req_t,
    parameter type reg_rsp_t  = xheep_reg_pkg::xheep_reg_rsp_t,
    parameter type fifo_req_t = xheep_fifo_pkg::xheep_fifo_req_t,
    parameter type fifo_rsp_t = xheep_fifo_pkg::xheep_fifo_rsp_t
) (
    `ifdef USE_POWER_PINS
    inout wire IOVDD,
    inout wire IOVSS,
    inout wire VDD,
    inout wire VSS,
    `endif


              inout wire gpio_1_io,
              inout wire gpio_2_io,
              inout wire gpio_3_io,
              inout wire gpio_4_io,
              inout wire gpio_5_io,
              inout wire gpio_6_io,
              inout wire gpio_7_io,
              inout wire gpio_8_io,
              inout wire gpio_9_io,
              inout wire gpio_10_io,
              inout wire gpio_11_io,
              inout wire gpio_12_io,
              inout wire gpio_13_io,
              inout wire spi_flash_sck_io,
              inout wire spi_flash_cs_0_io,
              inout wire spi_flash_cs_1_io,
              inout wire spi_flash_sd_0_io,
              inout wire spi_flash_sd_1_io,
              inout wire spi_flash_sd_2_io,
              inout wire spi_flash_sd_3_io,
              inout wire spi_sck_io,
              inout wire spi_cs_0_io,
              inout wire spi_cs_1_io,
              inout wire spi_sd_0_io,
              inout wire spi_sd_1_io,
              inout wire spi_sd_2_io,
              inout wire spi_sd_3_io,
              inout wire spi_slave_sck_io,
              inout wire spi_slave_cs_io,
              inout wire spi_slave_miso_io,
              inout wire spi_slave_mosi_io,
              inout wire pdm2pcm_pdm_io,
              inout wire pdm2pcm_clk_io,
              inout wire i2s_sck_io,
              inout wire i2s_ws_io,
              inout wire i2s_sd_io,
              inout wire spi2_cs_0_io,
              inout wire spi2_cs_1_io,
              inout wire spi2_sck_io,
              inout wire spi2_sd_0_io,
              inout wire spi2_sd_1_io,
              inout wire spi2_sd_2_io,
              inout wire spi2_sd_3_io,
              inout wire i2c_scl_io,
              inout wire i2c_sda_io,
              inout wire clk_i,
              inout wire rst_ni,
              inout wire boot_select_i,
              inout wire execute_from_flash_i,
              inout wire jtag_tck_i,
              inout wire jtag_tms_i,
              inout wire jtag_trst_ni,
              inout wire jtag_tdi_i,
              inout wire jtag_tdo_o,
              inout wire uart_rx_i,
              inout wire uart_tx_o,
              inout wire exit_valid_o,
              inout wire ddr_rcv_clk_i,
              inout wire ddr_snd_clk_o,
              inout wire gpio_0_io
);

  import core_v_mini_mcu_pkg::*;

  // Tie off unused signals
  logic [31:0] unused_xheep_instance_id = 32'h0;
  logic [31:0] unused_hart_id = 32'h0;
  logic [NEXT_INT_RND-1:0] unused_intr_vector_ext = '0;
  logic unused_intr_ext_peripheral = 1'b0;
  obi_req_t [EXT_XBAR_NMASTER_RND-1:0] unused_ext_xbar_master_req = '{default: '0};
  obi_rsp_t unused_ext_core_instr_resp = '{default: '0};
  obi_rsp_t unused_ext_core_data_resp = '{default: '0};
  obi_rsp_t unused_ext_debug_master_resp = '{default: '0};
  obi_rsp_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] unused_ext_dma_read_resp = '{default: '0};
  obi_rsp_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] unused_ext_dma_write_resp = '{default: '0};
  obi_rsp_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] unused_ext_dma_addr_resp = '{default: '0};
  fifo_rsp_t [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_hw_fifo_resp = '{default: '0};
  reg_req_t [AO_SPC_NUM_RND:0] unused_ext_ao_peripheral_req = '{default: '0};
  reg_rsp_t unused_ext_peripheral_slave_resp = '{default: '0};
  logic unused_cpu_subsystem_powergate_switch_ack_n = 1'b1;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_ext_dma_slot_tx_i = '0;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_ext_dma_slot_rx_i = '0;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_ext_dma_stop_i    = '0;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_hw_fifo_done_i    = '0;
  logic unused_peripheral_subsystem_powergate_switch_ack_n = 1'b1;
  logic [EXT_DOMAINS_RND-1:0] unused_external_subsystem_powergate_switch_ack_n = '1; // Set all bits high
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_ext_dma_slot_tx = '0;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_ext_dma_slot_rx = '0;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] unused_ext_dma_stop = '0;

  // eXtension interface
  if_xif xif_compressed_if();
  if_xif xif_issue_if();
  if_xif xif_commit_if();
  if_xif xif_mem_if();
  if_xif xif_mem_result_if();
  if_xif xif_result_if();

  x_heep_system #(
    .XHEEP_INSTANCE_ID(0),
    .EXT_XBAR_NMASTER(0),
    .AO_SPC_NUM(0),
    // OBI and register interface data types
    .obi_req_t(obi_req_t),
    .obi_rsp_t(obi_rsp_t),
    .reg_req_t(reg_req_t),
    .reg_rsp_t(reg_rsp_t),
    .fifo_req_t(fifo_req_t),
    .fifo_rsp_t(fifo_rsp_t)
  ) x_heep_system_inst (
    // IDs
    .hart_id_i                              (unused_hart_id),
    .xheep_instance_id_i                    (unused_xheep_instance_id),

    .intr_vector_ext_i                      (unused_intr_vector_ext),
    .intr_ext_peripheral_i                  (unused_intr_ext_peripheral),

    .ext_xbar_master_req_i                  (unused_ext_xbar_master_req),
    .ext_xbar_master_resp_o                 (),

    // External slave ports
    .ext_core_instr_req_o                   (),
    .ext_core_instr_resp_i                  (unused_ext_core_instr_resp),
    .ext_core_data_req_o                    (),
    .ext_core_data_resp_i                   (unused_ext_core_data_resp),
    .ext_debug_master_req_o                 (),
    .ext_debug_master_resp_i                (unused_ext_debug_master_resp),
    .ext_dma_read_req_o                     (),
    .ext_dma_read_resp_i                    (unused_ext_dma_read_resp),
    .ext_dma_write_req_o                    (),
    .ext_dma_write_resp_i                   (unused_ext_dma_write_resp),
    .ext_dma_addr_req_o                     (),
    .ext_dma_addr_resp_i                    (unused_ext_dma_addr_resp),

    .hw_fifo_req_o                          (),
    .hw_fifo_resp_i                         (unused_hw_fifo_resp),

    .ext_ao_peripheral_req_i                (unused_ext_ao_peripheral_req),
    .ext_ao_peripheral_resp_o               (),

    .ext_peripheral_slave_req_o             (),
    .ext_peripheral_slave_resp_i            (unused_ext_peripheral_slave_resp),

    // Power management
    .cpu_subsystem_powergate_switch_no              (),
    .cpu_subsystem_powergate_switch_ack_ni          (unused_cpu_subsystem_powergate_switch_ack_n),
    .peripheral_subsystem_powergate_switch_no       (),
    .peripheral_subsystem_powergate_switch_ack_ni   (unused_peripheral_subsystem_powergate_switch_ack_n),

    .external_subsystem_powergate_switch_no         (),
    .external_subsystem_powergate_switch_ack_ni     (unused_external_subsystem_powergate_switch_ack_n),
    .external_subsystem_powergate_iso_no            (),
    .external_subsystem_rst_no                      (),
    .external_ram_banks_set_retentive_no            (),
    .external_subsystem_clkgate_en_no               (),

    .exit_value_o                           (),

    .ext_dma_slot_tx_i                      (unused_ext_dma_slot_tx_i),
    .ext_dma_slot_rx_i                      (unused_ext_dma_slot_rx_i),
    .ext_dma_stop_i                         (unused_ext_dma_stop_i),
    .hw_fifo_done_i                         (unused_hw_fifo_done_i),

    // eXtension Interface
    .xif_compressed_if                      (xif_compressed_if),
    .xif_issue_if                           (xif_issue_if),
    .xif_commit_if                          (xif_commit_if),
    .xif_mem_if                             (xif_mem_if),
    .xif_mem_result_if                      (xif_mem_result_if),
    .xif_result_if                          (xif_result_if),

    // External SPC interface
    .dma_done_o                             (),

    `ifdef USE_POWER_PINS
    .iovdd_io(IOVDD),
    .iovss_io(IOVSS),
    .vdd_io(VDD),
    .vss_io(VSS),
    `endif

              .gpio_1_io  (gpio_1_io),
              .gpio_2_io  (gpio_2_io),
              .gpio_3_io  (gpio_3_io),
              .gpio_4_io  (gpio_4_io),
              .gpio_5_io  (gpio_5_io),
              .gpio_6_io  (gpio_6_io),
              .gpio_7_io  (gpio_7_io),
              .gpio_8_io  (gpio_8_io),
              .gpio_9_io  (gpio_9_io),
              .gpio_10_io  (gpio_10_io),
              .gpio_11_io  (gpio_11_io),
              .gpio_12_io  (gpio_12_io),
              .gpio_13_io  (gpio_13_io),
              .spi_flash_sck_io  (spi_flash_sck_io),
              .spi_flash_cs_0_io  (spi_flash_cs_0_io),
              .spi_flash_cs_1_io  (spi_flash_cs_1_io),
              .spi_flash_sd_0_io  (spi_flash_sd_0_io),
              .spi_flash_sd_1_io  (spi_flash_sd_1_io),
              .spi_flash_sd_2_io  (spi_flash_sd_2_io),
              .spi_flash_sd_3_io  (spi_flash_sd_3_io),
              .spi_sck_io  (spi_sck_io),
              .spi_cs_0_io  (spi_cs_0_io),
              .spi_cs_1_io  (spi_cs_1_io),
              .spi_sd_0_io  (spi_sd_0_io),
              .spi_sd_1_io  (spi_sd_1_io),
              .spi_sd_2_io  (spi_sd_2_io),
              .spi_sd_3_io  (spi_sd_3_io),
              .spi_slave_sck_io  (spi_slave_sck_io),
              .spi_slave_cs_io  (spi_slave_cs_io),
              .spi_slave_miso_io  (spi_slave_miso_io),
              .spi_slave_mosi_io  (spi_slave_mosi_io),
              .pdm2pcm_pdm_io  (pdm2pcm_pdm_io),
              .pdm2pcm_clk_io  (pdm2pcm_clk_io),
              .i2s_sck_io  (i2s_sck_io),
              .i2s_ws_io  (i2s_ws_io),
              .i2s_sd_io  (i2s_sd_io),
              .spi2_cs_0_io  (spi2_cs_0_io),
              .spi2_cs_1_io  (spi2_cs_1_io),
              .spi2_sck_io  (spi2_sck_io),
              .spi2_sd_0_io  (spi2_sd_0_io),
              .spi2_sd_1_io  (spi2_sd_1_io),
              .spi2_sd_2_io  (spi2_sd_2_io),
              .spi2_sd_3_io  (spi2_sd_3_io),
              .i2c_scl_io  (i2c_scl_io),
              .i2c_sda_io  (i2c_sda_io),
              .clk_i   (clk_i),
              .rst_ni   (rst_ni),
              .boot_select_i   (boot_select_i),
              .execute_from_flash_i   (execute_from_flash_i),
              .jtag_tck_i   (jtag_tck_i),
              .jtag_tms_i   (jtag_tms_i),
              .jtag_trst_ni   (jtag_trst_ni),
              .jtag_tdi_i   (jtag_tdi_i),
              .jtag_tdo_o   (jtag_tdo_o),
              .uart_rx_i   (uart_rx_i),
              .uart_tx_o   (uart_tx_o),
              .exit_valid_o   (exit_valid_o),
              .ddr_rcv_clk_i   (ddr_rcv_clk_i),
              .ddr_snd_clk_o   (ddr_snd_clk_o),
              .gpio_0_io  (gpio_0_io)
  );

endmodule
