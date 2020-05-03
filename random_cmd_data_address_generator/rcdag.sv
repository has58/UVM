module dut(dut_if dif);
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  always@(posedge dif.clock)
    begin
      `uvm_info("", $sformatf("DUT received cmd=%b, add=%d, data=%d", dif.cmd, dif.add, dif.data), UVM_MEDIUM)
    end
endmodule

interface dut_if;
  logic reset;
  logic clock;
  logic cmd;
  logic [7:0] add;
  logic [7:0] data;
endinterface
