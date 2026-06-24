// Copyright 2022 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1



module rel_cpu_subsystem
  import core_v_mini_mcu_pkg::*;
#(
    parameter type obi_req_t = logic,
    parameter type obi_rsp_t = logic,

    parameter type rel_obi_req_t = logic,
    parameter type rel_obi_rsp_t = logic,

    parameter obi_pkg::obi_cfg_t ObiCfg = obi_pkg::ObiDefaultConfig,

    parameter BOOT_ADDR = 'h180,
    parameter DM_HALTADDRESS = '0
) (
    // Clock and Reset
    input logic clk_i,
    input logic rst_ni,

    // Core ID
    input logic [31:0] hart_id_i,

    // Instruction memory interface
    output rel_obi_req_t core_instr_req_o,
    input  rel_obi_rsp_t core_instr_resp_i,

    // Data memory interface
    output rel_obi_req_t core_data_req_o,
    input  rel_obi_rsp_t core_data_resp_i,

    // eXtension interface
    if_xif.cpu_compressed xif_compressed_if,
    if_xif.cpu_issue      xif_issue_if,
    if_xif.cpu_commit     xif_commit_if,
    if_xif.cpu_mem        xif_mem_if,
    if_xif.cpu_mem_result xif_mem_result_if,
    if_xif.cpu_result     xif_result_if,

    // Interrupt inputs
    input  logic [31:0] irq_i,      // CLINT interrupts + CLINT extension interrupts
    output logic        irq_ack_o,
    output logic [ 4:0] irq_id_o,

    // Debug Interface
    input logic debug_req_i,

    // sleep
    output logic core_sleep_o
);

  import cv32e40px_core_v_xif_pkg::*;

  // CPU Control Signals
  logic            fetch_enable;

  logic            instr_req_o;
  logic            instr_gnt_i;
  logic            instr_rvalid_i;
  logic     [31:0] instr_addr_o;
  logic     [31:0] instr_rdata_i;
  logic            instr_err_i;
  logic            data_req_o;
  logic            data_gnt_i;
  logic            data_rvalid_i;
  logic            data_we_o;
  logic     [ 3:0] data_be_o;
  logic     [31:0] data_addr_o;
  logic     [31:0] data_wdata_o;
  logic     [31:0] data_rdata_i;
  logic            data_err_i;
  obi_req_t        instr_req;
  obi_rsp_t        instr_rsp;
  obi_req_t        data_req;
  obi_rsp_t        data_rsp;

  assign instr_req = '{
          a : '{
              addr : instr_addr_o,
              we   : 1'b0,  // always read
              be   : 4'b1111,  // always read full word
              wdata : 32'h0,  // dummy value
              aid   : '0,  // dummy value
              a_optional : '0  // dummy signal
          },
          req : instr_req_o,
          rready : 1'b1,  // always ready to accept response
          default : '0  // reqpar / rreadypar unused
      };
  assign data_req = '{
          a : '{
              addr : data_addr_o,
              we   : data_we_o,
              be   : data_be_o,
              wdata : data_wdata_o,
              aid   : '0,  // dummy value
              a_optional : '0  // dummy signal
          },
          req : data_req_o,
          rready : 1'b1,  // always ready to accept response
          default : '0  // reqpar / rreadypar unused
      };

  assign instr_gnt_i = instr_rsp.gnt;
  assign instr_rvalid_i = instr_rsp.rvalid;
  assign instr_rdata_i = instr_rsp.r.rdata;
  assign instr_err_i = instr_rsp.r.err;
  assign data_gnt_i = data_rsp.gnt;
  assign data_rvalid_i = data_rsp.rvalid;
  assign data_rdata_i = data_rsp.r.rdata;
  assign data_err_i = data_rsp.r.err;

  relobi_encoder #(
      .Cfg(ObiCfg),
      .relobi_req_t(rel_obi_req_t),
      .relobi_rsp_t(rel_obi_rsp_t),
      .obi_req_t(obi_req_t),
      .obi_rsp_t(obi_rsp_t),
      .a_optional_t(logic),
      .r_optional_t(logic)
  ) i_instr_encoder (
      .req_i(instr_req),
      .rsp_o(instr_rsp),
      .rel_req_o(core_instr_req_o),
      .rel_rsp_i(core_instr_resp_i),
      .fault_o()
  );

  relobi_encoder #(
      .Cfg(ObiCfg),
      .relobi_req_t(rel_obi_req_t),
      .relobi_rsp_t(rel_obi_rsp_t),
      .obi_req_t(obi_req_t),
      .obi_rsp_t(obi_rsp_t),
      .a_optional_t(logic),
      .r_optional_t(logic)
  ) i_data_encoder (
      .req_i(data_req),
      .rsp_o(data_rsp),
      .rel_req_o(core_data_req_o),
      .rel_rsp_i(core_data_resp_i),
      .fault_o()
  );

  assign fetch_enable = 1'b1;

  cv32e40px_xif_wrapper cv32e40px_xif_wrapper_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .pulp_clock_en_i(1'b1),
      .scan_cg_en_i   (1'b0),

      .boot_addr_i        (BOOT_ADDR),
      .mtvec_addr_i       (32'h0),
      .dm_halt_addr_i     (DM_HALTADDRESS),
      .hart_id_i,
      .dm_exception_addr_i(32'h0),

      .instr_addr_o,
      .instr_req_o,
      .instr_rdata_i,
      .instr_gnt_i,
      .instr_rvalid_i,

      .data_addr_o,
      .data_wdata_o,
      .data_we_o,
      .data_req_o,
      .data_be_o,
      .data_rdata_i,
      .data_gnt_i,
      .data_rvalid_i,

      // CORE-V-XIF
      .xif_compressed_if,
      .xif_issue_if,
      .xif_commit_if,
      .xif_mem_if,
      .xif_mem_result_if,
      .xif_result_if,

      .irq_i    (irq_i),
      .irq_ack_o(irq_ack_o),
      .irq_id_o (irq_id_o),

      .debug_req_i      (debug_req_i),
      .debug_havereset_o(),
      .debug_running_o  (),
      .debug_halted_o   (),

      .fetch_enable_i(fetch_enable),
      .core_sleep_o

  );

endmodule
