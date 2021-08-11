// TODO: Find the right disclaimer
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 28.04.2021
// Description: Wrapper for the Novia functional unit (NFU)

module nfu_wrap import ariane_pkg::*; (
  input logic                                            clk_i,
  input logic                                            rst_ni,
  // Input signals
  input fu_data_t                                        fu_data_i,
  input scoreboard_entry_t [NR_COMMIT_PORTS-1:0]         commit_instr_i,
  input logic [NR_COMMIT_PORTS-1:0]                      commit_ack_i,
  // Input handshake
  input logic                                            nfu_valid_i,
  output logic                                           nfu_ready_o,
  // Output signals
  //output exception_t                                   nfu_exception_o,
  output logic [63:0]                         nfu_result_o
  // Output handshake
  //output logic                                         nfu_valid_o
);

  localparam nfu_pkg::nfu_features_t NFU_FEATURES        = nfu_pkg::RV64NFU;
  localparam int unsigned NR_SHIFT_REG_ENTRIES           = NFU_FEATURES.NrShiftRegEntries;
  localparam int unsigned WIDTH                          = NFU_FEATURES.Width;
  localparam int unsigned OPWIDTH                        = NFU_FEATURES.OpWidth;
  localparam int unsigned NR_SHIFT_REG_WIDTH             = NR_SHIFT_REG_ENTRIES*OPWIDTH-1;
  localparam int unsigned ACCS                           = NFU_FEATURES.Accelerators;
  localparam int unsigned REG_ENTRIES_BITS               = $clog2(NR_SHIFT_REG_ENTRIES);

  logic irf_store_valid;
  logic orf_read_valid;
  logic exec_valid;
  logic [ACCS-1:0] acc;
  logic [OPWIDTH-1:0] addr;
  logic [WIDTH-1:0] data;

  logic [NR_SHIFT_REG_ENTRIES-1:0][OPWIDTH-1:0] ShiftReg;
  assign nfu_ready_o = 1'b1;



  nfu_top #(

  ) i_nfu_top (
    .clk_i,
    .rst_ni,
    .addr_i( addr ),
    .data_i( data ),
    .acc_i( acc ),
    .irf_store_i( irf_store_valid ),
    .orf_read_i( orf_read_valid ),
    .exec_i( exec_valid ),
    .data_o( nfu_result_o )
  );

  // Shift Register Window
  always_ff @(posedge clk_i or negedge rst_ni) begin : shift_reg
    if(~rst_ni) begin 
      ShiftReg <= '0;
    end else begin
      // Shift Register
      if(nfu_valid_i && fu_data_i.operator == ariane_pkg::SET_LOAD_NFU) begin
        // Adding a single 0 position to not count the commit of the
        // SET_LOAD instructions
        ShiftReg <= {fu_data_i.imm[NR_SHIFT_REG_WIDTH-1:OPWIDTH],5'b0};
        acc <= fu_data_i.imm[OPWIDTH-1:0];
      end
      else begin
        if(commit_ack_i[0] || commit_ack_i[1]) begin
          for (int j = 1; j < NR_SHIFT_REG_ENTRIES; j++) begin
            ShiftReg[j-1][OPWIDTH-1:0] <= ShiftReg[j][OPWIDTH-1:0];
          end
          ShiftReg[NR_SHIFT_REG_ENTRIES-1][OPWIDTH-1:0] <= '0;
        end
      end
    end
  end

  always_comb begin : decoder
    irf_store_valid = 1'b0;
    orf_read_valid = 1'b0;
    exec_valid = 1'b0;
        
    addr = ShiftReg[0];
    
    // Set valid signals
    if(addr != 0 && (commit_ack_i[0] || commit_ack_i[1])) begin
      irf_store_valid = 1'b1;
      if(commit_instr_i[0].valid) begin
        data = commit_instr_i[0].result;
      end
      else if (commit_instr_i[1].valid) begin
        data = commit_instr_i[1].result;
      end
    end
    if(nfu_valid_i) begin
      case(fu_data_i.operator)
        SET_LOAD_NFU: begin
        end
        EXEC_NFU: begin
          exec_valid = 1'b1;
        end
        POP_NFU: begin            
          orf_read_valid = 1'b1;
          addr = fu_data_i.imm[3*OPWIDTH-1:2*OPWIDTH]; 
        end
        default: begin
          //TODO: default:  This should raise an exception
        end
      endcase
    end
  end


endmodule
