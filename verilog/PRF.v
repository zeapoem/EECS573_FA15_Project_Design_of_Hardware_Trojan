/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  PRF.v                                               //
//                                                                     //
//  Description :  This module creates the PRF                         // 
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

module PRF(
  input                         clock, reset,
  input  [63:0]                 ex_wb_wr_data_in,            // write data
  input  [`PRF_width-1:0]       ex_wb_wr_idx_in,
  input  [`PRF_width-1:0]       rs_ex_rda_idx_in,
  input  [`PRF_width-1:0]       rs_ex_rdb_idx_in,            // read/write index
  input  [`PRF_width-1:0]       debug_rd_idx_in,

  output logic [63:0]           rda_out, rdb_out, debug_out    // read data 

);

  logic  [`PRF_size-1:0] [63:0] registers;   // PRF_SIZE, 64-bit Registers 

  logic                         wr_enable;   // If wr_idx is 0, do not write data in.
  wire   [63:0]                 rda_reg   = registers[rs_ex_rda_idx_in];
  wire   [63:0]                 rdb_reg   = registers[rs_ex_rdb_idx_in];
  wire   [63:0]                 debug_reg = registers[debug_rd_idx_in];
  
  assign  wr_enable = (ex_wb_wr_idx_in != 0);
  
  // Read port A
  always_comb
    if (rs_ex_rda_idx_in == 0) // Read form the ZERO_REG
      rda_out = 0;
    else if (wr_enable && (ex_wb_wr_idx_in == rs_ex_rda_idx_in))
      rda_out = ex_wb_wr_data_in;  // internal forwarding
    else
      rda_out = rda_reg;

  // Read port B
  always_comb
    if (rs_ex_rdb_idx_in == 0) // Read form the ZERO_REG
      rdb_out = 0;
    else if (wr_enable && (ex_wb_wr_idx_in == rs_ex_rdb_idx_in))
      rdb_out = ex_wb_wr_data_in;  // internal forwarding
    else
      rdb_out = rdb_reg;

  always_comb
    if (debug_rd_idx_in == 0) // Read form the ZERO_REG
      debug_out = 0;
    else if (wr_enable && (ex_wb_wr_idx_in == debug_rd_idx_in))
      debug_out = ex_wb_wr_data_in;  // internal forwarding
    else
      debug_out = debug_reg;

  // Write port
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      registers <= `SD 0;
    else begin
      if (wr_enable) begin
        registers[ex_wb_wr_idx_in] <= `SD ex_wb_wr_data_in;
      end
    end
  end  

endmodule // PRF
