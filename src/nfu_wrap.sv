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
  localparam int unsigned WIDTH                          = NFU_FEATURES.Width;
  localparam int unsigned OPWIDTH                        = NFU_FEATURES.OpWidth;
  localparam int unsigned ACCS                           = NFU_FEATURES.Accelerators;
  localparam int unsigned CONFIGS                        = NFU_FEATURES.Configs;

  logic irf_store_valid;
  logic orf_read_valid;
  logic [ACCS-1:0] acc;
  logic [CONFIGS-1:0] conf;
  logic [OPWIDTH-1:0] addr_irf, addr_orf;
  logic [WIDTH-1:0] data;

  logic [3:0] BufferIndex; // Max pending entries is 4
  logic [3:0] BufferIndex1; // Max pending entries is 4
  logic [3:0] BufferIndex2; // Max pending entries is 4
  logic [3:0] BufferLookup;
  logic [15:0][WIDTH-1:0] BufferPC;
  logic [15:0][OPWIDTH-1:0] BufferAddr;
  logic [15:0][WIDTH-1:0] BufferData;
  logic [15:0] BufferValid;

  assign nfu_ready_o = 1'b1;
  assign BufferIndex1 = BufferIndex+1;
  assign BufferIndex2 = BufferIndex+2;

  nfu_top #(

  ) i_nfu_top (
    .clk_i,
    .rst_ni,
    .addr_irf_i( addr_irf ),
    .addr_orf_i( addr_orf ),
    .data_i( data ),
    .acc_i( acc ),
    .config_i( conf ),
    .irf_store_i( irf_store_valid ),
    .orf_read_i( orf_read_valid ),
    .data_o( nfu_result_o )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : shift_reg
    if(~rst_ni) begin 
      //BufferFilled <= ~0;
      BufferAddr <= '0;
      BufferPC <= '0;
      BufferIndex <= '0;
      BufferLookup <= '0;
      irf_store_valid <= '0;
      BufferLookup <= 0;
    end else begin
      if(nfu_valid_i) begin
        case(fu_data_i.operator)
          SET_LOAD_NFU: begin
            
            acc <= fu_data_i.imm[OPWIDTH-2:0];

            BufferPC[BufferIndex] <= fu_data_i.imm[OPWIDTH*2-1:OPWIDTH]!=5'b0 ?
              fu_data_i.operand_a+4:0;
            BufferPC[BufferIndex1] <= fu_data_i.imm[OPWIDTH*3-1:OPWIDTH*2]!=5'b0 ?
              fu_data_i.operand_a+8:0;
            BufferPC[BufferIndex2] <= fu_data_i.imm[OPWIDTH*4-1:OPWIDTH*3]!=5'b0 ?
              fu_data_i.operand_a+12:0;
            
            BufferAddr[BufferIndex] <= fu_data_i.imm[OPWIDTH*2-1:OPWIDTH];
            BufferAddr[BufferIndex1] <= fu_data_i.imm[OPWIDTH*3-1:OPWIDTH*2];
            BufferAddr[BufferIndex2] <= fu_data_i.imm[OPWIDTH*4-1:OPWIDTH*3];
            
            BufferIndex <= BufferIndex+3;
          end
          default: begin
          end
        endcase
      end

      // Sending info to IRF
      if(BufferValid[BufferLookup] && BufferIndex != BufferLookup && !(nfu_valid_i && fu_data_i.operator == SET_LOAD_NFU) ) begin
        data <= BufferData[BufferLookup];
        addr_irf <= BufferAddr[BufferLookup];
        BufferLookup <= BufferLookup + 1;

        irf_store_valid <= BufferPC[BufferLookup] != 0;

      end else begin
        irf_store_valid <= 1'b0;
      end
    end
  end

  always_comb begin : decoder
    orf_read_valid = 1'b0;

    if(~rst_ni) begin
      BufferValid = '0;
    end

      for(bit [1:0] i = 0; i < 2; i++) begin
        if(commit_ack_i[i[0]] && commit_instr_i[i[0]].valid) begin 
          for(byte unsigned slot = 0; slot < 2; slot++ ) begin
            if ((commit_instr_i[i].pc == BufferPC[{3'b000,BufferLookup}+slot]) &&
              BufferAddr[{3'b000,BufferLookup}+slot] != 0 && 
              !BufferValid[{4'h0,BufferLookup}+slot]) begin
              BufferData[{3'b000,BufferLookup}+slot] = commit_instr_i[i].result;
              BufferValid[{4'h0,BufferLookup}+slot] = 1'b1;
            end
          end
        end
    end

    if(nfu_valid_i) begin
      case(fu_data_i.operator)
        SET_LOAD_NFU: begin
            BufferValid[BufferIndex] = fu_data_i.imm[OPWIDTH*2-1:OPWIDTH*1]==0;
            BufferValid[BufferIndex1] = fu_data_i.imm[OPWIDTH*3-1:OPWIDTH*2]==0;
            BufferValid[BufferIndex2] = fu_data_i.imm[OPWIDTH*4-1:OPWIDTH*3]==0;
        end
        EXEC_NFU: begin
          conf = fu_data_i.imm[2*OPWIDTH-2:OPWIDTH]; 
        end
        POP_NFU: begin            
          orf_read_valid = 1'b1;
          addr_orf = fu_data_i.imm[3*OPWIDTH-1:2*OPWIDTH]; 
        end
        default: begin
          //TODO: default:  This should raise an exception
        end
      endcase
    end
    

  end
endmodule
