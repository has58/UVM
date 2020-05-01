import uvm_pkg::*;
`include "uvm_macros.svh"

class my_env extends uvm_env;
  `uvm_component_utils(my_env)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  my_env m_env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    m_env =  my_env::type_id::create("m_env", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #10;
    `uvm_info("", "Hello Worl", UVM_MEDIUM);
    phase.drop_objection(this);
  endtask
endclass
  
module top;
  
  import uvm_pkg::*;
  
  dut_if dut_if1 ();
  
  dut dut1 (.dif(dut_if1));
  
  initial
    begin
      run_test("my_test");
    end
endmodule
