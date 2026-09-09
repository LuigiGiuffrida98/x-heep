// Copyright 2022 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// MODIFICATION NOTICE:
// This file has been modified by Nathan Chandanson on 15/07/2026.
// Brief description of changes: Remove the pad_ring and outputs the i, o and oe signals for each pad.
//






module ihp_sg13g2_asic_x_heep_system_wrapper
import if_xif_structs_pkg::*;
#(
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
    // IDs
    input logic [31:0] hart_id_i,
    input logic [31:0] xheep_instance_id_i,

    input logic [NEXT_INT_RND-1:0] intr_vector_ext_i,
    input logic intr_ext_peripheral_i,

    input  obi_req_t [EXT_XBAR_NMASTER_RND-1:0] ext_xbar_master_req_i,
    output obi_rsp_t [EXT_XBAR_NMASTER_RND-1:0] ext_xbar_master_resp_o,

    // External slave ports
    output obi_req_t ext_core_instr_req_o,
    input  obi_rsp_t ext_core_instr_resp_i,
    output obi_req_t ext_core_data_req_o,
    input  obi_rsp_t ext_core_data_resp_i,
    output obi_req_t ext_debug_master_req_o,
    input  obi_rsp_t ext_debug_master_resp_i,
    output obi_req_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] ext_dma_read_req_o,
    input  obi_rsp_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] ext_dma_read_resp_i,
    output obi_req_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] ext_dma_write_req_o,
    input  obi_rsp_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] ext_dma_write_resp_i,
    output obi_req_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] ext_dma_addr_req_o,
    input  obi_rsp_t [core_v_mini_mcu_pkg::DMA_NUM_MASTER_PORTS-1:0] ext_dma_addr_resp_i,

    output fifo_req_t [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] hw_fifo_req_o,
    input fifo_rsp_t [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] hw_fifo_resp_i,

    input  reg_req_t [AO_SPC_NUM_RND:0] ext_ao_peripheral_req_i,
    output reg_rsp_t [AO_SPC_NUM_RND:0] ext_ao_peripheral_resp_o,

    output reg_req_t ext_peripheral_slave_req_o,
    input  reg_rsp_t ext_peripheral_slave_resp_i,

    // PM signals
    output logic cpu_subsystem_powergate_switch_no,
    input  logic cpu_subsystem_powergate_switch_ack_ni,
    output logic peripheral_subsystem_powergate_switch_no,
    input  logic peripheral_subsystem_powergate_switch_ack_ni,

    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_powergate_switch_no,
    input  logic [EXT_DOMAINS_RND-1:0] external_subsystem_powergate_switch_ack_ni,
    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_powergate_iso_no,
    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_rst_no,
    output logic [EXT_DOMAINS_RND-1:0] external_ram_banks_set_retentive_no,
    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_clkgate_en_no,

    output logic [31:0] exit_value_o,

    input logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_dma_slot_tx_i,
    input logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_dma_slot_rx_i,
    input logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_dma_stop_i,
    input logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] hw_fifo_done_i,

    // eXtension interface
    // Compressed interface
    output logic               xif_compressed_valid,
    input  logic               xif_compressed_ready,
    output x_compressed_req_t  xif_compressed_req,
    input  x_compressed_resp_t xif_compressed_resp,
    // Issue interface
    output logic               xif_issue_valid,
    input  logic               xif_issue_ready,
    output x_issue_req_t       xif_issue_req,
    input  x_issue_resp_t      xif_issue_resp,
    // Commit interface
    output logic               xif_commit_valid,
    output x_commit_t          xif_commit,
    // Memory (request/response) interface
    input  logic               xif_mem_valid,
    output logic               xif_mem_ready,
    input  x_mem_req_t         xif_mem_req,
    output x_mem_resp_t        xif_mem_resp,
    // Memory result interface
    output logic               xif_mem_result_valid,
    output x_mem_result_t      xif_mem_result,
    // Result interface
    input  logic               xif_result_valid,
    output logic               xif_result_ready,
    input  x_result_t          xif_result,

    // External SPC interface
    output logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] dma_done_o,

        `ifdef USE_POWER_PINS
                inout wire vdd_io,
        inout wire vss_io,
        inout wire iovdd_io,
        inout wire iovss_io,
        `endif


              input  logic gpio_1_i,
        output logic gpio_1_oe,
        output logic gpio_1_o,
              input  logic gpio_2_i,
        output logic gpio_2_oe,
        output logic gpio_2_o,
              input  logic gpio_3_i,
        output logic gpio_3_oe,
        output logic gpio_3_o,
              input  logic gpio_4_i,
        output logic gpio_4_oe,
        output logic gpio_4_o,
              input  logic gpio_5_i,
        output logic gpio_5_oe,
        output logic gpio_5_o,
              input  logic gpio_6_i,
        output logic gpio_6_oe,
        output logic gpio_6_o,
              input  logic gpio_7_i,
        output logic gpio_7_oe,
        output logic gpio_7_o,
              input  logic gpio_8_i,
        output logic gpio_8_oe,
        output logic gpio_8_o,
              input  logic gpio_9_i,
        output logic gpio_9_oe,
        output logic gpio_9_o,
              input  logic gpio_10_i,
        output logic gpio_10_oe,
        output logic gpio_10_o,
              input  logic gpio_11_i,
        output logic gpio_11_oe,
        output logic gpio_11_o,
              input  logic gpio_12_i,
        output logic gpio_12_oe,
        output logic gpio_12_o,
              input  logic gpio_13_i,
        output logic gpio_13_oe,
        output logic gpio_13_o,
              input  logic spi_flash_sck_i,
        output logic spi_flash_sck_oe,
        output logic spi_flash_sck_o,
              input  logic spi_flash_cs_0_i,
        output logic spi_flash_cs_0_oe,
        output logic spi_flash_cs_0_o,
              input  logic spi_flash_cs_1_i,
        output logic spi_flash_cs_1_oe,
        output logic spi_flash_cs_1_o,
              input  logic spi_flash_sd_0_i,
        output logic spi_flash_sd_0_oe,
        output logic spi_flash_sd_0_o,
              input  logic spi_flash_sd_1_i,
        output logic spi_flash_sd_1_oe,
        output logic spi_flash_sd_1_o,
              input  logic spi_flash_sd_2_i,
        output logic spi_flash_sd_2_oe,
        output logic spi_flash_sd_2_o,
              input  logic spi_flash_sd_3_i,
        output logic spi_flash_sd_3_oe,
        output logic spi_flash_sd_3_o,
              input  logic spi_sck_i,
        output logic spi_sck_oe,
        output logic spi_sck_o,
              input  logic spi_cs_0_i,
        output logic spi_cs_0_oe,
        output logic spi_cs_0_o,
              input  logic spi_cs_1_i,
        output logic spi_cs_1_oe,
        output logic spi_cs_1_o,
              input  logic spi_sd_0_i,
        output logic spi_sd_0_oe,
        output logic spi_sd_0_o,
              input  logic spi_sd_1_i,
        output logic spi_sd_1_oe,
        output logic spi_sd_1_o,
              input  logic spi_sd_2_i,
        output logic spi_sd_2_oe,
        output logic spi_sd_2_o,
              input  logic spi_sd_3_i,
        output logic spi_sd_3_oe,
        output logic spi_sd_3_o,
              input  logic spi_slave_sck_i,
        output logic spi_slave_sck_oe,
        output logic spi_slave_sck_o,
              input  logic spi_slave_cs_i,
        output logic spi_slave_cs_oe,
        output logic spi_slave_cs_o,
              input  logic spi_slave_miso_i,
        output logic spi_slave_miso_oe,
        output logic spi_slave_miso_o,
              input  logic spi_slave_mosi_i,
        output logic spi_slave_mosi_oe,
        output logic spi_slave_mosi_o,
              input  logic pdm2pcm_pdm_i,
        output logic pdm2pcm_pdm_oe,
        output logic pdm2pcm_pdm_o,
              input  logic pdm2pcm_clk_i,
        output logic pdm2pcm_clk_oe,
        output logic pdm2pcm_clk_o,
              input  logic i2s_sck_i,
        output logic i2s_sck_oe,
        output logic i2s_sck_o,
              input  logic i2s_ws_i,
        output logic i2s_ws_oe,
        output logic i2s_ws_o,
              input  logic i2s_sd_i,
        output logic i2s_sd_oe,
        output logic i2s_sd_o,
              input  logic spi2_cs_0_i,
        output logic spi2_cs_0_oe,
        output logic spi2_cs_0_o,
              input  logic spi2_cs_1_i,
        output logic spi2_cs_1_oe,
        output logic spi2_cs_1_o,
              input  logic spi2_sck_i,
        output logic spi2_sck_oe,
        output logic spi2_sck_o,
              input  logic spi2_sd_0_i,
        output logic spi2_sd_0_oe,
        output logic spi2_sd_0_o,
              input  logic spi2_sd_1_i,
        output logic spi2_sd_1_oe,
        output logic spi2_sd_1_o,
              input  logic spi2_sd_2_i,
        output logic spi2_sd_2_oe,
        output logic spi2_sd_2_o,
              input  logic spi2_sd_3_i,
        output logic spi2_sd_3_oe,
        output logic spi2_sd_3_o,
              input  logic i2c_scl_i,
        output logic i2c_scl_oe,
        output logic i2c_scl_o,
              input  logic i2c_sda_i,
        output logic i2c_sda_oe,
        output logic i2c_sda_o,
              input  logic clk_i,
              input  logic rst_ni,
              input  logic boot_select_i,
              input  logic execute_from_flash_i,
              input  logic jtag_tck_i,
              input  logic jtag_tms_i,
              input  logic jtag_trst_ni,
              input  logic jtag_tdi_i,
              output logic jtag_tdo_o,
              input  logic uart_rx_i,
              output logic uart_tx_o,
              output logic exit_valid_o,
              input  logic ddr_rcv_clk_i,
              output logic ddr_snd_clk_o,
              input  logic gpio_0_i,
        output logic gpio_0_oe,
        output logic gpio_0_o
);

  import core_v_mini_mcu_pkg::*;

  localparam EXT_HARTS = 0;

  //do not touch these parameter
  localparam EXT_HARTS_RND = EXT_HARTS == 0 ? 1 : EXT_HARTS;

  logic [EXT_HARTS_RND-1:0] ext_debug_req;
  logic ext_cpu_subsystem_rst_n;
  logic ext_debug_reset_n;

  // PAD controller
  reg_req_t pad_req;
  reg_rsp_t pad_resp;

    logic [core_v_mini_mcu_pkg::NUM_PAD-1:0][0:0] pad_muxes;

  logic rst_ngen;

  // core_v_mini_mcu input/output pins
        logic gpio_1_in_x, gpio_1_out_x, gpio_1_oe_x;
        logic ddr_rcv_0_in_x, ddr_rcv_0_out_x, ddr_rcv_0_oe_x;
      logic gpio_1_in_x_muxed, gpio_1_out_x_muxed, gpio_1_oe_x_muxed;
        logic gpio_2_in_x, gpio_2_out_x, gpio_2_oe_x;
        logic ddr_rcv_1_in_x, ddr_rcv_1_out_x, ddr_rcv_1_oe_x;
      logic gpio_2_in_x_muxed, gpio_2_out_x_muxed, gpio_2_oe_x_muxed;
        logic gpio_3_in_x, gpio_3_out_x, gpio_3_oe_x;
        logic ddr_rcv_2_in_x, ddr_rcv_2_out_x, ddr_rcv_2_oe_x;
      logic gpio_3_in_x_muxed, gpio_3_out_x_muxed, gpio_3_oe_x_muxed;
        logic gpio_4_in_x, gpio_4_out_x, gpio_4_oe_x;
        logic gpio_5_in_x, gpio_5_out_x, gpio_5_oe_x;
        logic gpio_6_in_x, gpio_6_out_x, gpio_6_oe_x;
        logic ddr_rcv_3_in_x, ddr_rcv_3_out_x, ddr_rcv_3_oe_x;
      logic gpio_6_in_x_muxed, gpio_6_out_x_muxed, gpio_6_oe_x_muxed;
        logic gpio_7_in_x, gpio_7_out_x, gpio_7_oe_x;
        logic ddr_snd_0_in_x, ddr_snd_0_out_x, ddr_snd_0_oe_x;
      logic gpio_7_in_x_muxed, gpio_7_out_x_muxed, gpio_7_oe_x_muxed;
        logic gpio_8_in_x, gpio_8_out_x, gpio_8_oe_x;
        logic ddr_snd_1_in_x, ddr_snd_1_out_x, ddr_snd_1_oe_x;
      logic gpio_8_in_x_muxed, gpio_8_out_x_muxed, gpio_8_oe_x_muxed;
        logic gpio_9_in_x, gpio_9_out_x, gpio_9_oe_x;
        logic ddr_snd_2_in_x, ddr_snd_2_out_x, ddr_snd_2_oe_x;
      logic gpio_9_in_x_muxed, gpio_9_out_x_muxed, gpio_9_oe_x_muxed;
        logic gpio_10_in_x, gpio_10_out_x, gpio_10_oe_x;
        logic ddr_snd_3_in_x, ddr_snd_3_out_x, ddr_snd_3_oe_x;
      logic gpio_10_in_x_muxed, gpio_10_out_x_muxed, gpio_10_oe_x_muxed;
        logic gpio_11_in_x, gpio_11_out_x, gpio_11_oe_x;
        logic gpio_12_in_x, gpio_12_out_x, gpio_12_oe_x;
        logic gpio_13_in_x, gpio_13_out_x, gpio_13_oe_x;
        logic spi_flash_sck_in_x, spi_flash_sck_out_x, spi_flash_sck_oe_x;
        logic spi_flash_cs_0_in_x, spi_flash_cs_0_out_x, spi_flash_cs_0_oe_x;
        logic spi_flash_cs_1_in_x, spi_flash_cs_1_out_x, spi_flash_cs_1_oe_x;
        logic spi_flash_sd_0_in_x, spi_flash_sd_0_out_x, spi_flash_sd_0_oe_x;
        logic spi_flash_sd_1_in_x, spi_flash_sd_1_out_x, spi_flash_sd_1_oe_x;
        logic spi_flash_sd_2_in_x, spi_flash_sd_2_out_x, spi_flash_sd_2_oe_x;
        logic spi_flash_sd_3_in_x, spi_flash_sd_3_out_x, spi_flash_sd_3_oe_x;
        logic spi_sck_in_x, spi_sck_out_x, spi_sck_oe_x;
        logic spi_cs_0_in_x, spi_cs_0_out_x, spi_cs_0_oe_x;
        logic spi_cs_1_in_x, spi_cs_1_out_x, spi_cs_1_oe_x;
        logic spi_sd_0_in_x, spi_sd_0_out_x, spi_sd_0_oe_x;
        logic spi_sd_1_in_x, spi_sd_1_out_x, spi_sd_1_oe_x;
        logic spi_sd_2_in_x, spi_sd_2_out_x, spi_sd_2_oe_x;
        logic spi_sd_3_in_x, spi_sd_3_out_x, spi_sd_3_oe_x;
        logic spi_slave_sck_in_x, spi_slave_sck_out_x, spi_slave_sck_oe_x;
        logic gpio_14_in_x, gpio_14_out_x, gpio_14_oe_x;
      logic spi_slave_sck_in_x_muxed, spi_slave_sck_out_x_muxed, spi_slave_sck_oe_x_muxed;
        logic spi_slave_cs_in_x, spi_slave_cs_out_x, spi_slave_cs_oe_x;
        logic gpio_15_in_x, gpio_15_out_x, gpio_15_oe_x;
      logic spi_slave_cs_in_x_muxed, spi_slave_cs_out_x_muxed, spi_slave_cs_oe_x_muxed;
        logic spi_slave_miso_in_x, spi_slave_miso_out_x, spi_slave_miso_oe_x;
        logic gpio_16_in_x, gpio_16_out_x, gpio_16_oe_x;
      logic spi_slave_miso_in_x_muxed, spi_slave_miso_out_x_muxed, spi_slave_miso_oe_x_muxed;
        logic spi_slave_mosi_in_x, spi_slave_mosi_out_x, spi_slave_mosi_oe_x;
        logic gpio_17_in_x, gpio_17_out_x, gpio_17_oe_x;
      logic spi_slave_mosi_in_x_muxed, spi_slave_mosi_out_x_muxed, spi_slave_mosi_oe_x_muxed;
        logic pdm2pcm_pdm_in_x, pdm2pcm_pdm_out_x, pdm2pcm_pdm_oe_x;
        logic gpio_18_in_x, gpio_18_out_x, gpio_18_oe_x;
      logic pdm2pcm_pdm_in_x_muxed, pdm2pcm_pdm_out_x_muxed, pdm2pcm_pdm_oe_x_muxed;
        logic pdm2pcm_clk_in_x, pdm2pcm_clk_out_x, pdm2pcm_clk_oe_x;
        logic gpio_19_in_x, gpio_19_out_x, gpio_19_oe_x;
      logic pdm2pcm_clk_in_x_muxed, pdm2pcm_clk_out_x_muxed, pdm2pcm_clk_oe_x_muxed;
        logic i2s_sck_in_x, i2s_sck_out_x, i2s_sck_oe_x;
        logic gpio_20_in_x, gpio_20_out_x, gpio_20_oe_x;
      logic i2s_sck_in_x_muxed, i2s_sck_out_x_muxed, i2s_sck_oe_x_muxed;
        logic i2s_ws_in_x, i2s_ws_out_x, i2s_ws_oe_x;
        logic gpio_21_in_x, gpio_21_out_x, gpio_21_oe_x;
      logic i2s_ws_in_x_muxed, i2s_ws_out_x_muxed, i2s_ws_oe_x_muxed;
        logic i2s_sd_in_x, i2s_sd_out_x, i2s_sd_oe_x;
        logic gpio_22_in_x, gpio_22_out_x, gpio_22_oe_x;
      logic i2s_sd_in_x_muxed, i2s_sd_out_x_muxed, i2s_sd_oe_x_muxed;
        logic spi2_cs_0_in_x, spi2_cs_0_out_x, spi2_cs_0_oe_x;
        logic gpio_23_in_x, gpio_23_out_x, gpio_23_oe_x;
      logic spi2_cs_0_in_x_muxed, spi2_cs_0_out_x_muxed, spi2_cs_0_oe_x_muxed;
        logic spi2_cs_1_in_x, spi2_cs_1_out_x, spi2_cs_1_oe_x;
        logic gpio_24_in_x, gpio_24_out_x, gpio_24_oe_x;
      logic spi2_cs_1_in_x_muxed, spi2_cs_1_out_x_muxed, spi2_cs_1_oe_x_muxed;
        logic spi2_sck_in_x, spi2_sck_out_x, spi2_sck_oe_x;
        logic gpio_25_in_x, gpio_25_out_x, gpio_25_oe_x;
      logic spi2_sck_in_x_muxed, spi2_sck_out_x_muxed, spi2_sck_oe_x_muxed;
        logic spi2_sd_0_in_x, spi2_sd_0_out_x, spi2_sd_0_oe_x;
        logic gpio_26_in_x, gpio_26_out_x, gpio_26_oe_x;
      logic spi2_sd_0_in_x_muxed, spi2_sd_0_out_x_muxed, spi2_sd_0_oe_x_muxed;
        logic spi2_sd_1_in_x, spi2_sd_1_out_x, spi2_sd_1_oe_x;
        logic gpio_27_in_x, gpio_27_out_x, gpio_27_oe_x;
      logic spi2_sd_1_in_x_muxed, spi2_sd_1_out_x_muxed, spi2_sd_1_oe_x_muxed;
        logic spi2_sd_2_in_x, spi2_sd_2_out_x, spi2_sd_2_oe_x;
        logic gpio_28_in_x, gpio_28_out_x, gpio_28_oe_x;
      logic spi2_sd_2_in_x_muxed, spi2_sd_2_out_x_muxed, spi2_sd_2_oe_x_muxed;
        logic spi2_sd_3_in_x, spi2_sd_3_out_x, spi2_sd_3_oe_x;
        logic gpio_29_in_x, gpio_29_out_x, gpio_29_oe_x;
      logic spi2_sd_3_in_x_muxed, spi2_sd_3_out_x_muxed, spi2_sd_3_oe_x_muxed;
        logic i2c_scl_in_x, i2c_scl_out_x, i2c_scl_oe_x;
        logic gpio_31_in_x, gpio_31_out_x, gpio_31_oe_x;
      logic i2c_scl_in_x_muxed, i2c_scl_out_x_muxed, i2c_scl_oe_x_muxed;
        logic i2c_sda_in_x, i2c_sda_out_x, i2c_sda_oe_x;
        logic gpio_30_in_x, gpio_30_out_x, gpio_30_oe_x;
      logic i2c_sda_in_x_muxed, i2c_sda_out_x_muxed, i2c_sda_oe_x_muxed;
        logic clk_in_x, clk_out_x, clk_oe_x;
        logic rst_nin_x, rst_nout_x, rst_noe_x;
        logic boot_select_in_x, boot_select_out_x, boot_select_oe_x;
        logic execute_from_flash_in_x, execute_from_flash_out_x, execute_from_flash_oe_x;
        logic jtag_tck_in_x, jtag_tck_out_x, jtag_tck_oe_x;
        logic jtag_tms_in_x, jtag_tms_out_x, jtag_tms_oe_x;
        logic jtag_trst_nin_x, jtag_trst_nout_x, jtag_trst_noe_x;
        logic jtag_tdi_in_x, jtag_tdi_out_x, jtag_tdi_oe_x;
        logic jtag_tdo_in_x, jtag_tdo_out_x, jtag_tdo_oe_x;
        logic uart_rx_in_x, uart_rx_out_x, uart_rx_oe_x;
        logic uart_tx_in_x, uart_tx_out_x, uart_tx_oe_x;
        logic exit_valid_in_x, exit_valid_out_x, exit_valid_oe_x;
        logic ddr_rcv_clk_in_x, ddr_rcv_clk_out_x, ddr_rcv_clk_oe_x;
        logic ddr_snd_clk_in_x, ddr_snd_clk_out_x, ddr_snd_clk_oe_x;
        logic gpio_0_in_x, gpio_0_out_x, gpio_0_oe_x;

            assign gpio_1_oe         = gpio_1_oe_x_muxed;
      assign gpio_1_o          = gpio_1_out_x_muxed;
      assign gpio_1_in_x_muxed = gpio_1_i;
            assign gpio_2_oe         = gpio_2_oe_x_muxed;
      assign gpio_2_o          = gpio_2_out_x_muxed;
      assign gpio_2_in_x_muxed = gpio_2_i;
            assign gpio_3_oe         = gpio_3_oe_x_muxed;
      assign gpio_3_o          = gpio_3_out_x_muxed;
      assign gpio_3_in_x_muxed = gpio_3_i;
            assign gpio_4_oe   = gpio_4_oe_x;
      assign gpio_4_o    = gpio_4_out_x;
      assign gpio_4_in_x = gpio_4_i;
            assign gpio_5_oe   = gpio_5_oe_x;
      assign gpio_5_o    = gpio_5_out_x;
      assign gpio_5_in_x = gpio_5_i;
            assign gpio_6_oe         = gpio_6_oe_x_muxed;
      assign gpio_6_o          = gpio_6_out_x_muxed;
      assign gpio_6_in_x_muxed = gpio_6_i;
            assign gpio_7_oe         = gpio_7_oe_x_muxed;
      assign gpio_7_o          = gpio_7_out_x_muxed;
      assign gpio_7_in_x_muxed = gpio_7_i;
            assign gpio_8_oe         = gpio_8_oe_x_muxed;
      assign gpio_8_o          = gpio_8_out_x_muxed;
      assign gpio_8_in_x_muxed = gpio_8_i;
            assign gpio_9_oe         = gpio_9_oe_x_muxed;
      assign gpio_9_o          = gpio_9_out_x_muxed;
      assign gpio_9_in_x_muxed = gpio_9_i;
            assign gpio_10_oe         = gpio_10_oe_x_muxed;
      assign gpio_10_o          = gpio_10_out_x_muxed;
      assign gpio_10_in_x_muxed = gpio_10_i;
            assign gpio_11_oe   = gpio_11_oe_x;
      assign gpio_11_o    = gpio_11_out_x;
      assign gpio_11_in_x = gpio_11_i;
            assign gpio_12_oe   = gpio_12_oe_x;
      assign gpio_12_o    = gpio_12_out_x;
      assign gpio_12_in_x = gpio_12_i;
            assign gpio_13_oe   = gpio_13_oe_x;
      assign gpio_13_o    = gpio_13_out_x;
      assign gpio_13_in_x = gpio_13_i;
            assign spi_flash_sck_oe   = spi_flash_sck_oe_x;
      assign spi_flash_sck_o    = spi_flash_sck_out_x;
      assign spi_flash_sck_in_x = spi_flash_sck_i;
            assign spi_flash_cs_0_oe   = spi_flash_cs_0_oe_x;
      assign spi_flash_cs_0_o    = spi_flash_cs_0_out_x;
      assign spi_flash_cs_0_in_x = spi_flash_cs_0_i;
                                    assign spi_flash_cs_1_oe   = spi_flash_cs_1_oe_x;
      assign spi_flash_cs_1_o    = spi_flash_cs_1_out_x;
      assign spi_flash_cs_1_in_x = spi_flash_cs_1_i;
            assign spi_flash_sd_0_oe   = spi_flash_sd_0_oe_x;
      assign spi_flash_sd_0_o    = spi_flash_sd_0_out_x;
      assign spi_flash_sd_0_in_x = spi_flash_sd_0_i;
            assign spi_flash_sd_1_oe   = spi_flash_sd_1_oe_x;
      assign spi_flash_sd_1_o    = spi_flash_sd_1_out_x;
      assign spi_flash_sd_1_in_x = spi_flash_sd_1_i;
            assign spi_flash_sd_2_oe   = spi_flash_sd_2_oe_x;
      assign spi_flash_sd_2_o    = spi_flash_sd_2_out_x;
      assign spi_flash_sd_2_in_x = spi_flash_sd_2_i;
            assign spi_flash_sd_3_oe   = spi_flash_sd_3_oe_x;
      assign spi_flash_sd_3_o    = spi_flash_sd_3_out_x;
      assign spi_flash_sd_3_in_x = spi_flash_sd_3_i;
            assign spi_sck_oe   = spi_sck_oe_x;
      assign spi_sck_o    = spi_sck_out_x;
      assign spi_sck_in_x = spi_sck_i;
            assign spi_cs_0_oe   = spi_cs_0_oe_x;
      assign spi_cs_0_o    = spi_cs_0_out_x;
      assign spi_cs_0_in_x = spi_cs_0_i;
            assign spi_cs_1_oe   = spi_cs_1_oe_x;
      assign spi_cs_1_o    = spi_cs_1_out_x;
      assign spi_cs_1_in_x = spi_cs_1_i;
            assign spi_sd_0_oe   = spi_sd_0_oe_x;
      assign spi_sd_0_o    = spi_sd_0_out_x;
      assign spi_sd_0_in_x = spi_sd_0_i;
            assign spi_sd_1_oe   = spi_sd_1_oe_x;
      assign spi_sd_1_o    = spi_sd_1_out_x;
      assign spi_sd_1_in_x = spi_sd_1_i;
            assign spi_sd_2_oe   = spi_sd_2_oe_x;
      assign spi_sd_2_o    = spi_sd_2_out_x;
      assign spi_sd_2_in_x = spi_sd_2_i;
            assign spi_sd_3_oe   = spi_sd_3_oe_x;
      assign spi_sd_3_o    = spi_sd_3_out_x;
      assign spi_sd_3_in_x = spi_sd_3_i;
            assign spi_slave_sck_oe         = spi_slave_sck_oe_x_muxed;
      assign spi_slave_sck_o          = spi_slave_sck_out_x_muxed;
      assign spi_slave_sck_in_x_muxed = spi_slave_sck_i;
            assign spi_slave_cs_oe         = spi_slave_cs_oe_x_muxed;
      assign spi_slave_cs_o          = spi_slave_cs_out_x_muxed;
      assign spi_slave_cs_in_x_muxed = spi_slave_cs_i;
            assign spi_slave_miso_oe         = spi_slave_miso_oe_x_muxed;
      assign spi_slave_miso_o          = spi_slave_miso_out_x_muxed;
      assign spi_slave_miso_in_x_muxed = spi_slave_miso_i;
                        assign spi_slave_mosi_oe         = spi_slave_mosi_oe_x_muxed;
      assign spi_slave_mosi_o          = spi_slave_mosi_out_x_muxed;
      assign spi_slave_mosi_in_x_muxed = spi_slave_mosi_i;
            assign pdm2pcm_pdm_oe         = pdm2pcm_pdm_oe_x_muxed;
      assign pdm2pcm_pdm_o          = pdm2pcm_pdm_out_x_muxed;
      assign pdm2pcm_pdm_in_x_muxed = pdm2pcm_pdm_i;
            assign pdm2pcm_clk_oe         = pdm2pcm_clk_oe_x_muxed;
      assign pdm2pcm_clk_o          = pdm2pcm_clk_out_x_muxed;
      assign pdm2pcm_clk_in_x_muxed = pdm2pcm_clk_i;
            assign i2s_sck_oe         = i2s_sck_oe_x_muxed;
      assign i2s_sck_o          = i2s_sck_out_x_muxed;
      assign i2s_sck_in_x_muxed = i2s_sck_i;
            assign i2s_ws_oe         = i2s_ws_oe_x_muxed;
      assign i2s_ws_o          = i2s_ws_out_x_muxed;
      assign i2s_ws_in_x_muxed = i2s_ws_i;
            assign i2s_sd_oe         = i2s_sd_oe_x_muxed;
      assign i2s_sd_o          = i2s_sd_out_x_muxed;
      assign i2s_sd_in_x_muxed = i2s_sd_i;
            assign spi2_cs_0_oe         = spi2_cs_0_oe_x_muxed;
      assign spi2_cs_0_o          = spi2_cs_0_out_x_muxed;
      assign spi2_cs_0_in_x_muxed = spi2_cs_0_i;
            assign spi2_cs_1_oe         = spi2_cs_1_oe_x_muxed;
      assign spi2_cs_1_o          = spi2_cs_1_out_x_muxed;
      assign spi2_cs_1_in_x_muxed = spi2_cs_1_i;
            assign spi2_sck_oe         = spi2_sck_oe_x_muxed;
      assign spi2_sck_o          = spi2_sck_out_x_muxed;
      assign spi2_sck_in_x_muxed = spi2_sck_i;
            assign spi2_sd_0_oe         = spi2_sd_0_oe_x_muxed;
      assign spi2_sd_0_o          = spi2_sd_0_out_x_muxed;
      assign spi2_sd_0_in_x_muxed = spi2_sd_0_i;
            assign spi2_sd_1_oe         = spi2_sd_1_oe_x_muxed;
      assign spi2_sd_1_o          = spi2_sd_1_out_x_muxed;
      assign spi2_sd_1_in_x_muxed = spi2_sd_1_i;
            assign spi2_sd_2_oe         = spi2_sd_2_oe_x_muxed;
      assign spi2_sd_2_o          = spi2_sd_2_out_x_muxed;
      assign spi2_sd_2_in_x_muxed = spi2_sd_2_i;
            assign spi2_sd_3_oe         = spi2_sd_3_oe_x_muxed;
      assign spi2_sd_3_o          = spi2_sd_3_out_x_muxed;
      assign spi2_sd_3_in_x_muxed = spi2_sd_3_i;
            assign i2c_scl_oe         = i2c_scl_oe_x_muxed;
      assign i2c_scl_o          = i2c_scl_out_x_muxed;
      assign i2c_scl_in_x_muxed = i2c_scl_i;
            assign i2c_sda_oe         = i2c_sda_oe_x_muxed;
      assign i2c_sda_o          = i2c_sda_out_x_muxed;
      assign i2c_sda_in_x_muxed = i2c_sda_i;
            assign clk_in_x = clk_i;
            assign rst_nin_x = rst_ni;
            assign boot_select_in_x = boot_select_i;
            assign execute_from_flash_in_x = execute_from_flash_i;
            assign jtag_tck_in_x = jtag_tck_i;
            assign jtag_tms_in_x = jtag_tms_i;
            assign jtag_trst_nin_x = jtag_trst_ni;
            assign jtag_tdi_in_x = jtag_tdi_i;
            assign jtag_tdo_o    = jtag_tdo_out_x;
            assign uart_rx_in_x = uart_rx_i;
            assign uart_tx_o    = uart_tx_out_x;
            assign exit_valid_o    = exit_valid_out_x;
            assign ddr_rcv_clk_in_x = ddr_rcv_clk_i;
            assign ddr_snd_clk_o    = ddr_snd_clk_out_x;
            assign gpio_0_oe   = gpio_0_oe_x;
      assign gpio_0_o    = gpio_0_out_x;
      assign gpio_0_in_x = gpio_0_i;

  // eXtension interface
  if_xif xif_compressed_if();
  if_xif xif_issue_if();
  if_xif xif_commit_if();
  if_xif xif_mem_if();
  if_xif xif_mem_result_if();
  if_xif xif_result_if();

  assign xif_compressed_valid = xif_compressed_if.compressed_valid;
  assign xif_compressed_if.compressed_ready = xif_compressed_ready;
  assign xif_compressed_req = xif_compressed_if.compressed_req;
  assign xif_compressed_if.compressed_resp = xif_compressed_resp;

  assign xif_issue_valid = xif_issue_if.issue_valid;
  assign xif_issue_if.issue_ready = xif_issue_ready;
  assign xif_issue_req = xif_issue_if.issue_req;
  assign xif_issue_if.issue_resp = xif_issue_resp;

  assign xif_commit_valid = xif_commit_if.commit_valid;
  assign xif_commit = xif_commit_if.commit;

  assign xif_mem_if.mem_valid = xif_mem_valid;
  assign xif_mem_ready = xif_mem_if.mem_ready;
  assign xif_mem_if.mem_req = xif_mem_req;
  assign xif_mem_resp = xif_mem_if.mem_resp;

  assign xif_mem_result_valid = xif_mem_result_if.mem_result_valid;
  assign xif_mem_result = xif_mem_result_if.mem_result;

  assign xif_result_if.result_valid = xif_result_valid;
  assign xif_result_ready = xif_result_if.result_ready;
  assign xif_result_if.result = xif_result;


  core_v_mini_mcu #(
    .EXT_XBAR_NMASTER(EXT_XBAR_NMASTER),
    .AO_SPC_NUM(AO_SPC_NUM),
    .EXT_HARTS(EXT_HARTS)
  ) core_v_mini_mcu_i (
    // MCU pads
    .rst_ni(rst_ngen),
          .gpio_1_i(gpio_1_in_x),
          .gpio_1_o(gpio_1_out_x),
          .gpio_1_oe_o(gpio_1_oe_x),
          .ddr_rcv_0_i(ddr_rcv_0_in_x),
          .gpio_2_i(gpio_2_in_x),
          .gpio_2_o(gpio_2_out_x),
          .gpio_2_oe_o(gpio_2_oe_x),
          .ddr_rcv_1_i(ddr_rcv_1_in_x),
          .gpio_3_i(gpio_3_in_x),
          .gpio_3_o(gpio_3_out_x),
          .gpio_3_oe_o(gpio_3_oe_x),
          .ddr_rcv_2_i(ddr_rcv_2_in_x),
          .gpio_4_i(gpio_4_in_x),
          .gpio_4_o(gpio_4_out_x),
          .gpio_4_oe_o(gpio_4_oe_x),
          .gpio_5_i(gpio_5_in_x),
          .gpio_5_o(gpio_5_out_x),
          .gpio_5_oe_o(gpio_5_oe_x),
          .gpio_6_i(gpio_6_in_x),
          .gpio_6_o(gpio_6_out_x),
          .gpio_6_oe_o(gpio_6_oe_x),
          .ddr_rcv_3_i(ddr_rcv_3_in_x),
          .gpio_7_i(gpio_7_in_x),
          .gpio_7_o(gpio_7_out_x),
          .gpio_7_oe_o(gpio_7_oe_x),
          .ddr_snd_0_o(ddr_snd_0_out_x),
          .gpio_8_i(gpio_8_in_x),
          .gpio_8_o(gpio_8_out_x),
          .gpio_8_oe_o(gpio_8_oe_x),
          .ddr_snd_1_o(ddr_snd_1_out_x),
          .gpio_9_i(gpio_9_in_x),
          .gpio_9_o(gpio_9_out_x),
          .gpio_9_oe_o(gpio_9_oe_x),
          .ddr_snd_2_o(ddr_snd_2_out_x),
          .gpio_10_i(gpio_10_in_x),
          .gpio_10_o(gpio_10_out_x),
          .gpio_10_oe_o(gpio_10_oe_x),
          .ddr_snd_3_o(ddr_snd_3_out_x),
          .gpio_11_i(gpio_11_in_x),
          .gpio_11_o(gpio_11_out_x),
          .gpio_11_oe_o(gpio_11_oe_x),
          .gpio_12_i(gpio_12_in_x),
          .gpio_12_o(gpio_12_out_x),
          .gpio_12_oe_o(gpio_12_oe_x),
          .gpio_13_i(gpio_13_in_x),
          .gpio_13_o(gpio_13_out_x),
          .gpio_13_oe_o(gpio_13_oe_x),
          .spi_flash_sck_i(spi_flash_sck_in_x),
          .spi_flash_sck_o(spi_flash_sck_out_x),
          .spi_flash_sck_oe_o(spi_flash_sck_oe_x),
          .spi_flash_cs_0_i(spi_flash_cs_0_in_x),
          .spi_flash_cs_0_o(spi_flash_cs_0_out_x),
          .spi_flash_cs_0_oe_o(spi_flash_cs_0_oe_x),
          .spi_flash_cs_1_i(spi_flash_cs_1_in_x),
          .spi_flash_cs_1_o(spi_flash_cs_1_out_x),
          .spi_flash_cs_1_oe_o(spi_flash_cs_1_oe_x),
          .spi_flash_sd_0_i(spi_flash_sd_0_in_x),
          .spi_flash_sd_0_o(spi_flash_sd_0_out_x),
          .spi_flash_sd_0_oe_o(spi_flash_sd_0_oe_x),
          .spi_flash_sd_1_i(spi_flash_sd_1_in_x),
          .spi_flash_sd_1_o(spi_flash_sd_1_out_x),
          .spi_flash_sd_1_oe_o(spi_flash_sd_1_oe_x),
          .spi_flash_sd_2_i(spi_flash_sd_2_in_x),
          .spi_flash_sd_2_o(spi_flash_sd_2_out_x),
          .spi_flash_sd_2_oe_o(spi_flash_sd_2_oe_x),
          .spi_flash_sd_3_i(spi_flash_sd_3_in_x),
          .spi_flash_sd_3_o(spi_flash_sd_3_out_x),
          .spi_flash_sd_3_oe_o(spi_flash_sd_3_oe_x),
          .spi_sck_i(spi_sck_in_x),
          .spi_sck_o(spi_sck_out_x),
          .spi_sck_oe_o(spi_sck_oe_x),
          .spi_cs_0_i(spi_cs_0_in_x),
          .spi_cs_0_o(spi_cs_0_out_x),
          .spi_cs_0_oe_o(spi_cs_0_oe_x),
          .spi_cs_1_i(spi_cs_1_in_x),
          .spi_cs_1_o(spi_cs_1_out_x),
          .spi_cs_1_oe_o(spi_cs_1_oe_x),
          .spi_sd_0_i(spi_sd_0_in_x),
          .spi_sd_0_o(spi_sd_0_out_x),
          .spi_sd_0_oe_o(spi_sd_0_oe_x),
          .spi_sd_1_i(spi_sd_1_in_x),
          .spi_sd_1_o(spi_sd_1_out_x),
          .spi_sd_1_oe_o(spi_sd_1_oe_x),
          .spi_sd_2_i(spi_sd_2_in_x),
          .spi_sd_2_o(spi_sd_2_out_x),
          .spi_sd_2_oe_o(spi_sd_2_oe_x),
          .spi_sd_3_i(spi_sd_3_in_x),
          .spi_sd_3_o(spi_sd_3_out_x),
          .spi_sd_3_oe_o(spi_sd_3_oe_x),
          .spi_slave_sck_i(spi_slave_sck_in_x),
          .gpio_14_i(gpio_14_in_x),
          .gpio_14_o(gpio_14_out_x),
          .gpio_14_oe_o(gpio_14_oe_x),
          .spi_slave_cs_i(spi_slave_cs_in_x),
          .gpio_15_i(gpio_15_in_x),
          .gpio_15_o(gpio_15_out_x),
          .gpio_15_oe_o(gpio_15_oe_x),
          .spi_slave_miso_i(spi_slave_miso_in_x),
          .spi_slave_miso_o(spi_slave_miso_out_x),
          .spi_slave_miso_oe_o(spi_slave_miso_oe_x),
          .gpio_16_i(gpio_16_in_x),
          .gpio_16_o(gpio_16_out_x),
          .gpio_16_oe_o(gpio_16_oe_x),
          .spi_slave_mosi_i(spi_slave_mosi_in_x),
          .gpio_17_i(gpio_17_in_x),
          .gpio_17_o(gpio_17_out_x),
          .gpio_17_oe_o(gpio_17_oe_x),
          .pdm2pcm_pdm_i(pdm2pcm_pdm_in_x),
          .pdm2pcm_pdm_o(pdm2pcm_pdm_out_x),
          .pdm2pcm_pdm_oe_o(pdm2pcm_pdm_oe_x),
          .gpio_18_i(gpio_18_in_x),
          .gpio_18_o(gpio_18_out_x),
          .gpio_18_oe_o(gpio_18_oe_x),
          .pdm2pcm_clk_i(pdm2pcm_clk_in_x),
          .pdm2pcm_clk_o(pdm2pcm_clk_out_x),
          .pdm2pcm_clk_oe_o(pdm2pcm_clk_oe_x),
          .gpio_19_i(gpio_19_in_x),
          .gpio_19_o(gpio_19_out_x),
          .gpio_19_oe_o(gpio_19_oe_x),
          .i2s_sck_i(i2s_sck_in_x),
          .i2s_sck_o(i2s_sck_out_x),
          .i2s_sck_oe_o(i2s_sck_oe_x),
          .gpio_20_i(gpio_20_in_x),
          .gpio_20_o(gpio_20_out_x),
          .gpio_20_oe_o(gpio_20_oe_x),
          .i2s_ws_i(i2s_ws_in_x),
          .i2s_ws_o(i2s_ws_out_x),
          .i2s_ws_oe_o(i2s_ws_oe_x),
          .gpio_21_i(gpio_21_in_x),
          .gpio_21_o(gpio_21_out_x),
          .gpio_21_oe_o(gpio_21_oe_x),
          .i2s_sd_i(i2s_sd_in_x),
          .i2s_sd_o(i2s_sd_out_x),
          .i2s_sd_oe_o(i2s_sd_oe_x),
          .gpio_22_i(gpio_22_in_x),
          .gpio_22_o(gpio_22_out_x),
          .gpio_22_oe_o(gpio_22_oe_x),
          .spi2_cs_0_i(spi2_cs_0_in_x),
          .spi2_cs_0_o(spi2_cs_0_out_x),
          .spi2_cs_0_oe_o(spi2_cs_0_oe_x),
          .gpio_23_i(gpio_23_in_x),
          .gpio_23_o(gpio_23_out_x),
          .gpio_23_oe_o(gpio_23_oe_x),
          .spi2_cs_1_i(spi2_cs_1_in_x),
          .spi2_cs_1_o(spi2_cs_1_out_x),
          .spi2_cs_1_oe_o(spi2_cs_1_oe_x),
          .gpio_24_i(gpio_24_in_x),
          .gpio_24_o(gpio_24_out_x),
          .gpio_24_oe_o(gpio_24_oe_x),
          .spi2_sck_i(spi2_sck_in_x),
          .spi2_sck_o(spi2_sck_out_x),
          .spi2_sck_oe_o(spi2_sck_oe_x),
          .gpio_25_i(gpio_25_in_x),
          .gpio_25_o(gpio_25_out_x),
          .gpio_25_oe_o(gpio_25_oe_x),
          .spi2_sd_0_i(spi2_sd_0_in_x),
          .spi2_sd_0_o(spi2_sd_0_out_x),
          .spi2_sd_0_oe_o(spi2_sd_0_oe_x),
          .gpio_26_i(gpio_26_in_x),
          .gpio_26_o(gpio_26_out_x),
          .gpio_26_oe_o(gpio_26_oe_x),
          .spi2_sd_1_i(spi2_sd_1_in_x),
          .spi2_sd_1_o(spi2_sd_1_out_x),
          .spi2_sd_1_oe_o(spi2_sd_1_oe_x),
          .gpio_27_i(gpio_27_in_x),
          .gpio_27_o(gpio_27_out_x),
          .gpio_27_oe_o(gpio_27_oe_x),
          .spi2_sd_2_i(spi2_sd_2_in_x),
          .spi2_sd_2_o(spi2_sd_2_out_x),
          .spi2_sd_2_oe_o(spi2_sd_2_oe_x),
          .gpio_28_i(gpio_28_in_x),
          .gpio_28_o(gpio_28_out_x),
          .gpio_28_oe_o(gpio_28_oe_x),
          .spi2_sd_3_i(spi2_sd_3_in_x),
          .spi2_sd_3_o(spi2_sd_3_out_x),
          .spi2_sd_3_oe_o(spi2_sd_3_oe_x),
          .gpio_29_i(gpio_29_in_x),
          .gpio_29_o(gpio_29_out_x),
          .gpio_29_oe_o(gpio_29_oe_x),
          .i2c_scl_i(i2c_scl_in_x),
          .i2c_scl_o(i2c_scl_out_x),
          .i2c_scl_oe_o(i2c_scl_oe_x),
          .gpio_31_i(gpio_31_in_x),
          .gpio_31_o(gpio_31_out_x),
          .gpio_31_oe_o(gpio_31_oe_x),
          .i2c_sda_i(i2c_sda_in_x),
          .i2c_sda_o(i2c_sda_out_x),
          .i2c_sda_oe_o(i2c_sda_oe_x),
          .gpio_30_i(gpio_30_in_x),
          .gpio_30_o(gpio_30_out_x),
          .gpio_30_oe_o(gpio_30_oe_x),
          .clk_i(clk_in_x),
          .boot_select_i(boot_select_in_x),
          .execute_from_flash_i(execute_from_flash_in_x),
          .jtag_tck_i(jtag_tck_in_x),
          .jtag_tms_i(jtag_tms_in_x),
          .jtag_trst_ni(jtag_trst_nin_x),
          .jtag_tdi_i(jtag_tdi_in_x),
          .jtag_tdo_o(jtag_tdo_out_x),
          .uart_rx_i(uart_rx_in_x),
          .uart_tx_o(uart_tx_out_x),
          .exit_valid_o(exit_valid_out_x),
          .ddr_rcv_clk_i(ddr_rcv_clk_in_x),
          .ddr_snd_clk_o(ddr_snd_clk_out_x),
          .gpio_0_i(gpio_0_in_x),
          .gpio_0_o(gpio_0_out_x),
          .gpio_0_oe_o(gpio_0_oe_x),

    .hart_id_i,
    .xheep_instance_id_i,
    .intr_vector_ext_i,
    .intr_ext_peripheral_i,
    .xif_compressed_if,
    .xif_issue_if,
    .xif_commit_if,
    .xif_mem_if,
    .xif_mem_result_if,
    .xif_result_if,
    .pad_req_o(pad_req),
    .pad_resp_i(pad_resp),
    .ext_xbar_master_req_i,
    .ext_xbar_master_resp_o,
    .ext_ao_peripheral_slave_req_i(ext_ao_peripheral_req_i),
    .ext_ao_peripheral_slave_resp_o(ext_ao_peripheral_resp_o),
    .ext_core_instr_req_o,
    .ext_core_instr_resp_i,
    .ext_core_data_req_o,
    .ext_core_data_resp_i,
    .ext_debug_master_req_o,
    .ext_debug_master_resp_i,
    .ext_dma_read_req_o,
    .ext_dma_read_resp_i,
    .ext_dma_write_req_o,
    .ext_dma_write_resp_i,
    .ext_dma_addr_req_o,
    .ext_dma_addr_resp_i,
    .hw_fifo_done_i,
    .ext_dma_stop_i,
    .hw_fifo_req_o,
    .hw_fifo_resp_i,
    .ext_peripheral_slave_req_o,
    .ext_peripheral_slave_resp_i,
    .ext_debug_req_o(ext_debug_req),
    .ext_debug_reset_no(ext_debug_reset_n),
    .cpu_subsystem_powergate_switch_no,
    .cpu_subsystem_powergate_switch_ack_ni,
    .peripheral_subsystem_powergate_switch_no,
    .peripheral_subsystem_powergate_switch_ack_ni,
    .external_subsystem_powergate_switch_no,
    .external_subsystem_powergate_switch_ack_ni,
    .external_subsystem_powergate_iso_no,
    .external_subsystem_rst_no,
    .ext_cpu_subsystem_rst_no(ext_cpu_subsystem_rst_n),
    .external_ram_banks_set_retentive_no,
    .external_subsystem_clkgate_en_no,
    .exit_value_o,
    .ext_dma_slot_tx_i,
    .ext_dma_slot_rx_i,
    .dma_done_o
  );

    assign clk_out_x = 1'b0;
    assign clk_oe_x = 1'b0;
    assign rst_nout_x = 1'b0;
    assign rst_noe_x = 1'b0;
    assign boot_select_out_x = 1'b0;
    assign boot_select_oe_x = 1'b0;
    assign execute_from_flash_out_x = 1'b0;
    assign execute_from_flash_oe_x = 1'b0;
    assign jtag_tck_out_x = 1'b0;
    assign jtag_tck_oe_x = 1'b0;
    assign jtag_tms_out_x = 1'b0;
    assign jtag_tms_oe_x = 1'b0;
    assign jtag_trst_nout_x = 1'b0;
    assign jtag_trst_noe_x = 1'b0;
    assign jtag_tdi_out_x = 1'b0;
    assign jtag_tdi_oe_x = 1'b0;
    assign jtag_tdo_oe_x = 1'b1;
    assign uart_rx_out_x = 1'b0;
    assign uart_rx_oe_x = 1'b0;
    assign uart_tx_oe_x = 1'b1;
    assign exit_valid_oe_x = 1'b1;
    assign spi_slave_sck_out_x = 1'b0;
    assign spi_slave_sck_oe_x = 1'b0;
    assign spi_slave_cs_out_x = 1'b0;
    assign spi_slave_cs_oe_x = 1'b0;
    assign spi_slave_mosi_out_x = 1'b0;
    assign spi_slave_mosi_oe_x = 1'b0;
    assign ddr_rcv_clk_out_x = 1'b0;
    assign ddr_rcv_clk_oe_x = 1'b0;
    assign ddr_snd_clk_oe_x = 1'b1;
    assign ddr_rcv_0_out_x = 1'b0;
    assign ddr_rcv_0_oe_x = 1'b0;
    assign ddr_rcv_1_out_x = 1'b0;
    assign ddr_rcv_1_oe_x = 1'b0;
    assign ddr_rcv_2_out_x = 1'b0;
    assign ddr_rcv_2_oe_x = 1'b0;
    assign ddr_rcv_3_out_x = 1'b0;
    assign ddr_rcv_3_oe_x = 1'b0;
    assign ddr_snd_0_oe_x = 1'b1;
    assign ddr_snd_1_oe_x = 1'b1;
    assign ddr_snd_2_oe_x = 1'b1;
    assign ddr_snd_3_oe_x = 1'b1;

// PAD MULTIPLEXERS
    always_comb
  begin
      gpio_1_in_x = 1'b0;
      ddr_rcv_0_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_1])
        0: begin

          gpio_1_out_x_muxed = gpio_1_out_x;
          gpio_1_oe_x_muxed  = gpio_1_oe_x;
          gpio_1_in_x        = gpio_1_in_x_muxed;
        end
        1: begin

          gpio_1_out_x_muxed = ddr_rcv_0_out_x;
          gpio_1_oe_x_muxed  = ddr_rcv_0_oe_x;
          ddr_rcv_0_in_x        = gpio_1_in_x_muxed;
        end
      default: begin
        gpio_1_out_x_muxed = gpio_1_out_x;
        gpio_1_oe_x_muxed  = gpio_1_oe_x;
        gpio_1_in_x        = gpio_1_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      gpio_2_in_x = 1'b0;
      ddr_rcv_1_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_2])
        0: begin

          gpio_2_out_x_muxed = gpio_2_out_x;
          gpio_2_oe_x_muxed  = gpio_2_oe_x;
          gpio_2_in_x        = gpio_2_in_x_muxed;
        end
        1: begin

          gpio_2_out_x_muxed = ddr_rcv_1_out_x;
          gpio_2_oe_x_muxed  = ddr_rcv_1_oe_x;
          ddr_rcv_1_in_x        = gpio_2_in_x_muxed;
        end
      default: begin
        gpio_2_out_x_muxed = gpio_2_out_x;
        gpio_2_oe_x_muxed  = gpio_2_oe_x;
        gpio_2_in_x        = gpio_2_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      gpio_3_in_x = 1'b0;
      ddr_rcv_2_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_3])
        0: begin

          gpio_3_out_x_muxed = gpio_3_out_x;
          gpio_3_oe_x_muxed  = gpio_3_oe_x;
          gpio_3_in_x        = gpio_3_in_x_muxed;
        end
        1: begin

          gpio_3_out_x_muxed = ddr_rcv_2_out_x;
          gpio_3_oe_x_muxed  = ddr_rcv_2_oe_x;
          ddr_rcv_2_in_x        = gpio_3_in_x_muxed;
        end
      default: begin
        gpio_3_out_x_muxed = gpio_3_out_x;
        gpio_3_oe_x_muxed  = gpio_3_oe_x;
        gpio_3_in_x        = gpio_3_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      gpio_6_in_x = 1'b0;
      ddr_rcv_3_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_6])
        0: begin

          gpio_6_out_x_muxed = gpio_6_out_x;
          gpio_6_oe_x_muxed  = gpio_6_oe_x;
          gpio_6_in_x        = gpio_6_in_x_muxed;
        end
        1: begin

          gpio_6_out_x_muxed = ddr_rcv_3_out_x;
          gpio_6_oe_x_muxed  = ddr_rcv_3_oe_x;
          ddr_rcv_3_in_x        = gpio_6_in_x_muxed;
        end
      default: begin
        gpio_6_out_x_muxed = gpio_6_out_x;
        gpio_6_oe_x_muxed  = gpio_6_oe_x;
        gpio_6_in_x        = gpio_6_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      gpio_7_in_x = 1'b0;
      ddr_snd_0_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_7])
        0: begin

          gpio_7_out_x_muxed = gpio_7_out_x;
          gpio_7_oe_x_muxed  = gpio_7_oe_x;
          gpio_7_in_x        = gpio_7_in_x_muxed;
        end
        1: begin

          gpio_7_out_x_muxed = ddr_snd_0_out_x;
          gpio_7_oe_x_muxed  = ddr_snd_0_oe_x;
          ddr_snd_0_in_x        = gpio_7_in_x_muxed;
        end
      default: begin
        gpio_7_out_x_muxed = gpio_7_out_x;
        gpio_7_oe_x_muxed  = gpio_7_oe_x;
        gpio_7_in_x        = gpio_7_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      gpio_8_in_x = 1'b0;
      ddr_snd_1_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_8])
        0: begin

          gpio_8_out_x_muxed = gpio_8_out_x;
          gpio_8_oe_x_muxed  = gpio_8_oe_x;
          gpio_8_in_x        = gpio_8_in_x_muxed;
        end
        1: begin

          gpio_8_out_x_muxed = ddr_snd_1_out_x;
          gpio_8_oe_x_muxed  = ddr_snd_1_oe_x;
          ddr_snd_1_in_x        = gpio_8_in_x_muxed;
        end
      default: begin
        gpio_8_out_x_muxed = gpio_8_out_x;
        gpio_8_oe_x_muxed  = gpio_8_oe_x;
        gpio_8_in_x        = gpio_8_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      gpio_9_in_x = 1'b0;
      ddr_snd_2_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_9])
        0: begin

          gpio_9_out_x_muxed = gpio_9_out_x;
          gpio_9_oe_x_muxed  = gpio_9_oe_x;
          gpio_9_in_x        = gpio_9_in_x_muxed;
        end
        1: begin

          gpio_9_out_x_muxed = ddr_snd_2_out_x;
          gpio_9_oe_x_muxed  = ddr_snd_2_oe_x;
          ddr_snd_2_in_x        = gpio_9_in_x_muxed;
        end
      default: begin
        gpio_9_out_x_muxed = gpio_9_out_x;
        gpio_9_oe_x_muxed  = gpio_9_oe_x;
        gpio_9_in_x        = gpio_9_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      gpio_10_in_x = 1'b0;
      ddr_snd_3_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_GPIO_10])
        0: begin

          gpio_10_out_x_muxed = gpio_10_out_x;
          gpio_10_oe_x_muxed  = gpio_10_oe_x;
          gpio_10_in_x        = gpio_10_in_x_muxed;
        end
        1: begin

          gpio_10_out_x_muxed = ddr_snd_3_out_x;
          gpio_10_oe_x_muxed  = ddr_snd_3_oe_x;
          ddr_snd_3_in_x        = gpio_10_in_x_muxed;
        end
      default: begin
        gpio_10_out_x_muxed = gpio_10_out_x;
        gpio_10_oe_x_muxed  = gpio_10_oe_x;
        gpio_10_in_x        = gpio_10_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi_slave_sck_in_x = 1'b0;
      gpio_14_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI_SLAVE_SCK])
        0: begin

          spi_slave_sck_out_x_muxed = spi_slave_sck_out_x;
          spi_slave_sck_oe_x_muxed  = spi_slave_sck_oe_x;
          spi_slave_sck_in_x        = spi_slave_sck_in_x_muxed;
        end
        1: begin

          spi_slave_sck_out_x_muxed = gpio_14_out_x;
          spi_slave_sck_oe_x_muxed  = gpio_14_oe_x;
          gpio_14_in_x        = spi_slave_sck_in_x_muxed;
        end
      default: begin
        spi_slave_sck_out_x_muxed = spi_slave_sck_out_x;
        spi_slave_sck_oe_x_muxed  = spi_slave_sck_oe_x;
        spi_slave_sck_in_x        = spi_slave_sck_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi_slave_cs_in_x = 1'b0;
      gpio_15_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI_SLAVE_CS])
        0: begin

          spi_slave_cs_out_x_muxed = spi_slave_cs_out_x;
          spi_slave_cs_oe_x_muxed  = spi_slave_cs_oe_x;
          spi_slave_cs_in_x        = spi_slave_cs_in_x_muxed;
        end
        1: begin

          spi_slave_cs_out_x_muxed = gpio_15_out_x;
          spi_slave_cs_oe_x_muxed  = gpio_15_oe_x;
          gpio_15_in_x        = spi_slave_cs_in_x_muxed;
        end
      default: begin
        spi_slave_cs_out_x_muxed = spi_slave_cs_out_x;
        spi_slave_cs_oe_x_muxed  = spi_slave_cs_oe_x;
        spi_slave_cs_in_x        = spi_slave_cs_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi_slave_miso_in_x = 1'b0;
      gpio_16_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI_SLAVE_MISO])
        0: begin

          spi_slave_miso_out_x_muxed = spi_slave_miso_out_x;
          spi_slave_miso_oe_x_muxed  = spi_slave_miso_oe_x;
          spi_slave_miso_in_x        = spi_slave_miso_in_x_muxed;
        end
        1: begin

          spi_slave_miso_out_x_muxed = gpio_16_out_x;
          spi_slave_miso_oe_x_muxed  = gpio_16_oe_x;
          gpio_16_in_x        = spi_slave_miso_in_x_muxed;
        end
      default: begin
        spi_slave_miso_out_x_muxed = spi_slave_miso_out_x;
        spi_slave_miso_oe_x_muxed  = spi_slave_miso_oe_x;
        spi_slave_miso_in_x        = spi_slave_miso_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi_slave_mosi_in_x = 1'b0;
      gpio_17_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI_SLAVE_MOSI])
        0: begin

          spi_slave_mosi_out_x_muxed = spi_slave_mosi_out_x;
          spi_slave_mosi_oe_x_muxed  = spi_slave_mosi_oe_x;
          spi_slave_mosi_in_x        = spi_slave_mosi_in_x_muxed;
        end
        1: begin

          spi_slave_mosi_out_x_muxed = gpio_17_out_x;
          spi_slave_mosi_oe_x_muxed  = gpio_17_oe_x;
          gpio_17_in_x        = spi_slave_mosi_in_x_muxed;
        end
      default: begin
        spi_slave_mosi_out_x_muxed = spi_slave_mosi_out_x;
        spi_slave_mosi_oe_x_muxed  = spi_slave_mosi_oe_x;
        spi_slave_mosi_in_x        = spi_slave_mosi_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      pdm2pcm_pdm_in_x = 1'b0;
      gpio_18_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_PDM2PCM_PDM])
        0: begin

          pdm2pcm_pdm_out_x_muxed = pdm2pcm_pdm_out_x;
          pdm2pcm_pdm_oe_x_muxed  = pdm2pcm_pdm_oe_x;
          pdm2pcm_pdm_in_x        = pdm2pcm_pdm_in_x_muxed;
        end
        1: begin

          pdm2pcm_pdm_out_x_muxed = gpio_18_out_x;
          pdm2pcm_pdm_oe_x_muxed  = gpio_18_oe_x;
          gpio_18_in_x        = pdm2pcm_pdm_in_x_muxed;
        end
      default: begin
        pdm2pcm_pdm_out_x_muxed = pdm2pcm_pdm_out_x;
        pdm2pcm_pdm_oe_x_muxed  = pdm2pcm_pdm_oe_x;
        pdm2pcm_pdm_in_x        = pdm2pcm_pdm_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      pdm2pcm_clk_in_x = 1'b0;
      gpio_19_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_PDM2PCM_CLK])
        0: begin

          pdm2pcm_clk_out_x_muxed = pdm2pcm_clk_out_x;
          pdm2pcm_clk_oe_x_muxed  = pdm2pcm_clk_oe_x;
          pdm2pcm_clk_in_x        = pdm2pcm_clk_in_x_muxed;
        end
        1: begin

          pdm2pcm_clk_out_x_muxed = gpio_19_out_x;
          pdm2pcm_clk_oe_x_muxed  = gpio_19_oe_x;
          gpio_19_in_x        = pdm2pcm_clk_in_x_muxed;
        end
      default: begin
        pdm2pcm_clk_out_x_muxed = pdm2pcm_clk_out_x;
        pdm2pcm_clk_oe_x_muxed  = pdm2pcm_clk_oe_x;
        pdm2pcm_clk_in_x        = pdm2pcm_clk_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      i2s_sck_in_x = 1'b0;
      gpio_20_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_I2S_SCK])
        0: begin

          i2s_sck_out_x_muxed = i2s_sck_out_x;
          i2s_sck_oe_x_muxed  = i2s_sck_oe_x;
          i2s_sck_in_x        = i2s_sck_in_x_muxed;
        end
        1: begin

          i2s_sck_out_x_muxed = gpio_20_out_x;
          i2s_sck_oe_x_muxed  = gpio_20_oe_x;
          gpio_20_in_x        = i2s_sck_in_x_muxed;
        end
      default: begin
        i2s_sck_out_x_muxed = i2s_sck_out_x;
        i2s_sck_oe_x_muxed  = i2s_sck_oe_x;
        i2s_sck_in_x        = i2s_sck_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      i2s_ws_in_x = 1'b0;
      gpio_21_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_I2S_WS])
        0: begin

          i2s_ws_out_x_muxed = i2s_ws_out_x;
          i2s_ws_oe_x_muxed  = i2s_ws_oe_x;
          i2s_ws_in_x        = i2s_ws_in_x_muxed;
        end
        1: begin

          i2s_ws_out_x_muxed = gpio_21_out_x;
          i2s_ws_oe_x_muxed  = gpio_21_oe_x;
          gpio_21_in_x        = i2s_ws_in_x_muxed;
        end
      default: begin
        i2s_ws_out_x_muxed = i2s_ws_out_x;
        i2s_ws_oe_x_muxed  = i2s_ws_oe_x;
        i2s_ws_in_x        = i2s_ws_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      i2s_sd_in_x = 1'b0;
      gpio_22_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_I2S_SD])
        0: begin

          i2s_sd_out_x_muxed = i2s_sd_out_x;
          i2s_sd_oe_x_muxed  = i2s_sd_oe_x;
          i2s_sd_in_x        = i2s_sd_in_x_muxed;
        end
        1: begin

          i2s_sd_out_x_muxed = gpio_22_out_x;
          i2s_sd_oe_x_muxed  = gpio_22_oe_x;
          gpio_22_in_x        = i2s_sd_in_x_muxed;
        end
      default: begin
        i2s_sd_out_x_muxed = i2s_sd_out_x;
        i2s_sd_oe_x_muxed  = i2s_sd_oe_x;
        i2s_sd_in_x        = i2s_sd_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi2_cs_0_in_x = 1'b0;
      gpio_23_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI2_CS_0])
        0: begin

          spi2_cs_0_out_x_muxed = spi2_cs_0_out_x;
          spi2_cs_0_oe_x_muxed  = spi2_cs_0_oe_x;
          spi2_cs_0_in_x        = spi2_cs_0_in_x_muxed;
        end
        1: begin

          spi2_cs_0_out_x_muxed = gpio_23_out_x;
          spi2_cs_0_oe_x_muxed  = gpio_23_oe_x;
          gpio_23_in_x        = spi2_cs_0_in_x_muxed;
        end
      default: begin
        spi2_cs_0_out_x_muxed = spi2_cs_0_out_x;
        spi2_cs_0_oe_x_muxed  = spi2_cs_0_oe_x;
        spi2_cs_0_in_x        = spi2_cs_0_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi2_cs_1_in_x = 1'b0;
      gpio_24_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI2_CS_1])
        0: begin

          spi2_cs_1_out_x_muxed = spi2_cs_1_out_x;
          spi2_cs_1_oe_x_muxed  = spi2_cs_1_oe_x;
          spi2_cs_1_in_x        = spi2_cs_1_in_x_muxed;
        end
        1: begin

          spi2_cs_1_out_x_muxed = gpio_24_out_x;
          spi2_cs_1_oe_x_muxed  = gpio_24_oe_x;
          gpio_24_in_x        = spi2_cs_1_in_x_muxed;
        end
      default: begin
        spi2_cs_1_out_x_muxed = spi2_cs_1_out_x;
        spi2_cs_1_oe_x_muxed  = spi2_cs_1_oe_x;
        spi2_cs_1_in_x        = spi2_cs_1_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi2_sck_in_x = 1'b0;
      gpio_25_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI2_SCK])
        0: begin

          spi2_sck_out_x_muxed = spi2_sck_out_x;
          spi2_sck_oe_x_muxed  = spi2_sck_oe_x;
          spi2_sck_in_x        = spi2_sck_in_x_muxed;
        end
        1: begin

          spi2_sck_out_x_muxed = gpio_25_out_x;
          spi2_sck_oe_x_muxed  = gpio_25_oe_x;
          gpio_25_in_x        = spi2_sck_in_x_muxed;
        end
      default: begin
        spi2_sck_out_x_muxed = spi2_sck_out_x;
        spi2_sck_oe_x_muxed  = spi2_sck_oe_x;
        spi2_sck_in_x        = spi2_sck_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi2_sd_0_in_x = 1'b0;
      gpio_26_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI2_SD_0])
        0: begin

          spi2_sd_0_out_x_muxed = spi2_sd_0_out_x;
          spi2_sd_0_oe_x_muxed  = spi2_sd_0_oe_x;
          spi2_sd_0_in_x        = spi2_sd_0_in_x_muxed;
        end
        1: begin

          spi2_sd_0_out_x_muxed = gpio_26_out_x;
          spi2_sd_0_oe_x_muxed  = gpio_26_oe_x;
          gpio_26_in_x        = spi2_sd_0_in_x_muxed;
        end
      default: begin
        spi2_sd_0_out_x_muxed = spi2_sd_0_out_x;
        spi2_sd_0_oe_x_muxed  = spi2_sd_0_oe_x;
        spi2_sd_0_in_x        = spi2_sd_0_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi2_sd_1_in_x = 1'b0;
      gpio_27_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI2_SD_1])
        0: begin

          spi2_sd_1_out_x_muxed = spi2_sd_1_out_x;
          spi2_sd_1_oe_x_muxed  = spi2_sd_1_oe_x;
          spi2_sd_1_in_x        = spi2_sd_1_in_x_muxed;
        end
        1: begin

          spi2_sd_1_out_x_muxed = gpio_27_out_x;
          spi2_sd_1_oe_x_muxed  = gpio_27_oe_x;
          gpio_27_in_x        = spi2_sd_1_in_x_muxed;
        end
      default: begin
        spi2_sd_1_out_x_muxed = spi2_sd_1_out_x;
        spi2_sd_1_oe_x_muxed  = spi2_sd_1_oe_x;
        spi2_sd_1_in_x        = spi2_sd_1_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi2_sd_2_in_x = 1'b0;
      gpio_28_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI2_SD_2])
        0: begin

          spi2_sd_2_out_x_muxed = spi2_sd_2_out_x;
          spi2_sd_2_oe_x_muxed  = spi2_sd_2_oe_x;
          spi2_sd_2_in_x        = spi2_sd_2_in_x_muxed;
        end
        1: begin

          spi2_sd_2_out_x_muxed = gpio_28_out_x;
          spi2_sd_2_oe_x_muxed  = gpio_28_oe_x;
          gpio_28_in_x        = spi2_sd_2_in_x_muxed;
        end
      default: begin
        spi2_sd_2_out_x_muxed = spi2_sd_2_out_x;
        spi2_sd_2_oe_x_muxed  = spi2_sd_2_oe_x;
        spi2_sd_2_in_x        = spi2_sd_2_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      spi2_sd_3_in_x = 1'b0;
      gpio_29_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_SPI2_SD_3])
        0: begin

          spi2_sd_3_out_x_muxed = spi2_sd_3_out_x;
          spi2_sd_3_oe_x_muxed  = spi2_sd_3_oe_x;
          spi2_sd_3_in_x        = spi2_sd_3_in_x_muxed;
        end
        1: begin

          spi2_sd_3_out_x_muxed = gpio_29_out_x;
          spi2_sd_3_oe_x_muxed  = gpio_29_oe_x;
          gpio_29_in_x        = spi2_sd_3_in_x_muxed;
        end
      default: begin
        spi2_sd_3_out_x_muxed = spi2_sd_3_out_x;
        spi2_sd_3_oe_x_muxed  = spi2_sd_3_oe_x;
        spi2_sd_3_in_x        = spi2_sd_3_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      i2c_scl_in_x = 1'b0;
      gpio_31_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_I2C_SCL])
        0: begin

          i2c_scl_out_x_muxed = i2c_scl_out_x;
          i2c_scl_oe_x_muxed  = i2c_scl_oe_x;
          i2c_scl_in_x        = i2c_scl_in_x_muxed;
        end
        1: begin

          i2c_scl_out_x_muxed = gpio_31_out_x;
          i2c_scl_oe_x_muxed  = gpio_31_oe_x;
          gpio_31_in_x        = i2c_scl_in_x_muxed;
        end
      default: begin
        i2c_scl_out_x_muxed = i2c_scl_out_x;
        i2c_scl_oe_x_muxed  = i2c_scl_oe_x;
        i2c_scl_in_x        = i2c_scl_in_x_muxed;
      end
    endcase
  end
    always_comb
  begin
      i2c_sda_in_x = 1'b0;
      gpio_30_in_x = 1'b0;
    unique case(pad_muxes[core_v_mini_mcu_pkg::PAD_I2C_SDA])
        0: begin

          i2c_sda_out_x_muxed = i2c_sda_out_x;
          i2c_sda_oe_x_muxed  = i2c_sda_oe_x;
          i2c_sda_in_x        = i2c_sda_in_x_muxed;
        end
        1: begin

          i2c_sda_out_x_muxed = gpio_30_out_x;
          i2c_sda_oe_x_muxed  = gpio_30_oe_x;
          gpio_30_in_x        = i2c_sda_in_x_muxed;
        end
      default: begin
        i2c_sda_out_x_muxed = i2c_sda_out_x;
        i2c_sda_oe_x_muxed  = i2c_sda_oe_x;
        i2c_sda_in_x        = i2c_sda_in_x_muxed;
      end
    endcase
  end

  pad_control #(
      .reg_req_t(xheep_reg_pkg::xheep_reg_req_t),
      .reg_rsp_t(xheep_reg_pkg::xheep_reg_rsp_t),
      .NUM_PAD  (core_v_mini_mcu_pkg::NUM_PAD)
  ) pad_control_i (
      .clk_i(clk_in_x),
      .rst_ni(rst_ngen),
      .reg_req_i(pad_req),
      .reg_rsp_o(pad_resp),
        .pad_muxes_o(pad_muxes)
  );

  rstgen rstgen_i (
    .clk_i(clk_in_x),
    .rst_ni(rst_nin_x),
    .test_mode_i(1'b0),
    .rst_no(rst_ngen),
    .init_no()
  );


endmodule  // x_heep_system
