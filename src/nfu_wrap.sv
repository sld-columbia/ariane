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
  localparam int unsigned NR_SHIFT_REG_WIDTH             = NR_SHIFT_REG_ENTRIES*OPWIDTH;
  localparam int unsigned ACCS                           = NFU_FEATURES.Accelerators;
  localparam int unsigned CONFIGS                        = NFU_FEATURES.Configs;

  logic irf_store_valid;
  logic orf_read_valid;
  logic [ACCS-1:0] acc;
  logic [CONFIGS-1:0] conf;
  logic [OPWIDTH-1:0] addr_irf, addr_orf;
  logic [WIDTH-1:0] data;

  logic [NR_SHIFT_REG_ENTRIES-1:0][OPWIDTH-1:0] ShiftRegAddr;
  logic [NR_SHIFT_REG_ENTRIES-1:0][WIDTH-1:0] ShiftRegData;
  logic [NR_SHIFT_REG_ENTRIES-1:0] ShiftRegValid;
  logic [NR_SHIFT_REG_ENTRIES-1:0] ShiftRegFilled;
  logic [WIDTH-1:0] PCReg;

  logic comp4, comp8;
  logic nfu_ready;

  logic [WIDTH-1:0] BufferedPCReg;
  logic [WIDTH-1:0] BufferedImm;

  assign nfu_ready_o = nfu_ready;

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
      ShiftRegAddr <= '0;
      ShiftRegFilled <= ~0;
      PCReg <= '0;
      BufferedImm <= '0;
      BufferedPCReg <= '0;
    end else begin
      if(nfu_valid_i) begin
        case(fu_data_i.operator)
          SET_LOAD_NFU: begin
            if(ShiftRegFilled == 3'b111) begin
              ShiftRegAddr <= fu_data_i.imm[NR_SHIFT_REG_WIDTH+OPWIDTH-1:OPWIDTH];
              acc <= fu_data_i.imm[OPWIDTH-1:0];
              PCReg <= fu_data_i.operand_a;
              ShiftRegFilled <= {fu_data_i.imm[OPWIDTH*4-1:OPWIDTH*3]==0,
                             fu_data_i.imm[OPWIDTH*3-1:OPWIDTH*2]==0,
                             fu_data_i.imm[OPWIDTH*2-1:OPWIDTH]==0};
            end else begin
              BufferedImm <= fu_data_i.imm;
              BufferedPCReg <= fu_data_i.operand_a;
            end
          end
        endcase
      end

      if(BufferedImm != 0 && ShiftRegFilled == 3'b111) begin
        ShiftRegAddr <= BufferedImm[NR_SHIFT_REG_WIDTH+OPWIDTH-1:OPWIDTH];
        acc <= BufferedImm[OPWIDTH-1:0];
        PCReg <= BufferedPCReg;
        ShiftRegFilled <= {BufferedImm[OPWIDTH*4-1:OPWIDTH*3]==0,
                             BufferedImm[OPWIDTH*3-1:OPWIDTH*2]==0,
                             BufferedImm[OPWIDTH*2-1:OPWIDTH]==0};
        BufferedImm <= '0;
        BufferedPCReg <= '0;
      end

      if(ShiftRegValid[0] && !ShiftRegFilled[0]) begin
        data <= ShiftRegData[0];
        addr_irf <= ShiftRegAddr[0];
        ShiftRegFilled[0] <= 1'b1;
        irf_store_valid <= 1'b1;
      end else if (ShiftRegValid[1] && !ShiftRegFilled[1]) begin
        data <= ShiftRegData[1];
        addr_irf <= ShiftRegAddr[1];
        ShiftRegFilled[1] <= 1'b1;
        irf_store_valid <= 1'b1;
      end else if (ShiftRegValid[2] && !ShiftRegFilled[2]) begin
        data <= ShiftRegData[2];
        addr_irf <= ShiftRegAddr[2];
        ShiftRegFilled[2] <= 1'b1;
        irf_store_valid <= 1'b1;
      end else begin
        irf_store_valid <= 1'b0;
      end
    end
  end

  always_comb begin : decoder
    orf_read_valid = 1'b0;
    
    if(~rst_ni) begin 
      ShiftRegData <= '0;
      ShiftRegValid <= '0;
      nfu_ready <= '1;
    end

    if(commit_ack_i[0] || commit_ack_i[1]) begin
      for(int unsigned i = 0; i < 2; i++) begin
        if(commit_instr_i[i].valid) begin 
          if (commit_instr_i[i].pc == PCReg+4 && ShiftRegAddr[0] != 0) begin
            ShiftRegData[0] = commit_instr_i[i].result;
            ShiftRegValid[0] = 1'b1;
            comp4 = commit_instr_i[i].is_compressed;
          end
          if (((commit_instr_i[i].pc == PCReg+6 && comp4) ||
            (commit_instr_i[i].pc == PCReg+8 && !comp4)) && ShiftRegAddr[1] != 0) begin
            ShiftRegData[1] = commit_instr_i[i].result;
            ShiftRegValid[1] = 1'b1;
            comp8 = commit_instr_i[i].is_compressed;
          end
          if (((commit_instr_i[i].pc == PCReg+8 && (comp4&&comp8)) || 
              (commit_instr_i[i].pc == PCReg+10 && (comp4^comp8)) ||
            commit_instr_i[i].pc == PCReg+12) && ShiftRegAddr[2] != 0) begin
            ShiftRegData[2] = commit_instr_i[i].result;
            ShiftRegValid[2] = 1'b1;
          end
        end
      end
    end

    if(nfu_valid_i) begin
      case(fu_data_i.operator)
        SET_LOAD_NFU: begin
          if(ShiftRegFilled != 3'b111) begin
            nfu_ready = 1'b0;
          end else begin
              ShiftRegValid <= {fu_data_i.imm[OPWIDTH*4-1:OPWIDTH*3]==0,
                            fu_data_i.imm[OPWIDTH*3-1:OPWIDTH*2]==0,
                            fu_data_i.imm[OPWIDTH*2-1:OPWIDTH]==0};
          end  
        end
        EXEC_NFU: begin
          if(ShiftRegFilled != 3'b111) begin
            nfu_ready = 1'b0;
          end
          conf = fu_data_i.imm[2*OPWIDTH-1:OPWIDTH]; 
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
    
    if(!nfu_ready) begin
      if(ShiftRegFilled == 3'b111) begin
        nfu_ready = 1'b1;
        ShiftRegValid <= {BufferedImm[OPWIDTH*4-1:OPWIDTH*3]==0,
                          BufferedImm[OPWIDTH*3-1:OPWIDTH*2]==0,
                          BufferedImm[OPWIDTH*2-1:OPWIDTH]==0};
      end
    end
  end


endmodule
