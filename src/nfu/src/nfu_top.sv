// TODO: Find the right disclaimer
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 29.04.2021
// Description: Top level of the NOVIA Functional Unit (NFU)

module nfu_top #(
  // NFU configuration
  parameter nfu_pkg::nfu_features_t Features =  nfu_pkg::RV64NFU,

  localparam int unsigned WIDTH              = Features.Width,
  localparam int unsigned ACCS               = Features.Accelerators,
  localparam int unsigned NOPERANDS          = 2**Features.OpWidth
) (
  input logic                       clk_i,
  input logic                       rst_ni,
  // Input signals 
  input logic [NOPERANDS-1:0]         addr_i, // IRF, ORF register addr
  input logic [WIDTH-1:0]           data_i,
  input logic [ACCS-1:0]            acc_i,
  input logic                       irf_store_i,
  input logic                       orf_read_i,
  input logic                       exec_i,
  // Input handshake
  // Output signals
  output logic [WIDTH-1:0]          data_o
  // Output handshake
);

  logic [NOPERANDS-1:0][WIDTH-1:0] data_irf_acc;
  logic [NOPERANDS-1:0][WIDTH-1:0] data_acc_orf;

  // NFU Decoder
  nfu_decoder #() i_nfu_dec (
    .clk_i,
    .rst_ni
  );

  // IRF
  nfu_irf #() i_nfu_irf (
    .clk_i,
    .rst_ni,
    .data_i,
    .addr_i,
    .acc_i,
    .data_en_i ( irf_store_i ),
    .data_o( data_irf_acc )
  );
  
  // ORF
  nfu_orf #() i_nfu_orf (
    .clk_i,
    .rst_ni,
    .data_i ( data_acc_orf ),
    .addr_i,
    .acc_i,
    .data_en_i ( orf_read_i ),
    .data_o
  );
  
  // Config Regfiles
  nfu_config #() i_nfu_config (
    .clk_i,
    .rst_ni
  );

  // NFU Accelerators
  nfu_acc #() i_nfu_acc (
    .clk_i,
    .rst_ni,
    .acc_i,
    .data_i( data_irf_acc ),
    .data_o( data_acc_orf )
  );

endmodule
