package my_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	class my_driver extends uvm_driver;
	  `uvm_component_utils(my_driver)
	  
	  virtual dut_if dut_vi;
	  
	  function new(string name, uvm_component parent);
		super.new(name, parent);
	  endfunction
	  
	  function void build_phase(uvm_phase phase);
	  if (!
		uvm_config_db #(virtual dut_if)::get(this, "", "dut_if", dut_vi))
		`uvm_error("", "uvm_config_db::get failed")
		endfunction
		
		task run_phase(uvm_phase phase);
			forever
			  begin
				@(posedge dut_vi.clock);
				dut_vi.cmd <= $urandom;
				dut_vi.add <= $urandom;
				dut_vi.data<= $urandom; 
			  end
		endtask
	endclass: my_driver;
	
	class my_env extends uvm_env;
		
		`uvm_component_utils(my_env)
		
		my_driver m_driver;
		
		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction
		
      function void build_phase(uvm_phase phase);
			m_driver = my_driver::type_id::create("m_driver", this);
		endfunction
	endclass: my_env;
		
	class my_test extends uvm_test;
	  
	  `uvm_component_utils(my_test)
	  
	  my_env m_env;
	  
	  function new(string name, uvm_component parent);
		super.new(name, parent);
	  endfunction
	  
	  function void build_phase(uvm_phase phase);
		m_env = my_env::type_id::create("m_env", this);
	  endfunction
	  task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		#80;
		phase.drop_objection(this);
	  endtask
	endclass
endpackage

module top;
	  
	  import uvm_pkg::*;
	  import my_pkg::*;
	  
	  
	  dut_if dut_if1();
	  dut dut1(.dif(dut_if1));
	  
	  initial
	  begin
		dut_if1.clock = 0;
		forever #5 dut_if1.clock = ~dut_if1.clock;
	  end
	  
	  initial 
		begin
		  uvm_config_db #(virtual dut_if)::set(null, "*", "dut_if", dut_if1);
		  uvm_top.finish_on_completion = 1;
		  run_test("my_test");
		end
	endmodule
