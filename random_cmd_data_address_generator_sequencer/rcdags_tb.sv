
`include "uvm_macros.svh"

package my_pkg;

  import uvm_pkg::*;

  class my_transaction extends uvm_sequence_item;
  
    `uvm_object_utils(my_transaction)
  
    rand bit cmd;
    rand int addr;
    rand int data;
  
    constraint c_addr { addr >= 0; addr < 256; }
    constraint c_data { data >= 0; data < 256; }
    
    function new (string name = "");
      super.new(name);
    endfunction
    
    function string convert2string;
      return $sformatf("cmd=%b, addr=%0d, data=%0d", cmd, addr, data);
    endfunction

    function void do_copy(uvm_object rhs);
      my_transaction tx;
      $cast(tx, rhs);
      cmd  = tx.cmd;
      addr = tx.addr;
      data = tx.data;
    endfunction
    
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      my_transaction tx;
      bit status = 1;
      $cast(tx, rhs);
      status &= (cmd  == tx.cmd);
      status &= (addr == tx.addr);
      status &= (data == tx.data);
      return status;
    endfunction

  endclass: my_transaction


  typedef uvm_sequencer #(my_transaction) my_sequencer;


  class my_sequence extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(my_sequence)
    
    function new (string name = "");
      super.new(name);
    endfunction

    task body;
      if (starting_phase != null)
        starting_phase.raise_objection(this);

      repeat(8)
      begin
        req = my_transaction::type_id::create("req");
        start_item(req);
        if( !req.randomize() )
          `uvm_error("", "Randomize failed")
        finish_item(req);
      end
      
      if (starting_phase != null)
        starting_phase.drop_objection(this);
    endtask: body
   
  endclass: my_sequence
  

  class my_driver extends uvm_driver #(my_transaction);
  
    `uvm_component_utils(my_driver)

    virtual dut_if dut_vi;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      // Get interface reference from config database
      if( !uvm_config_db #(virtual dut_if)::get(this, "", "dut_if", dut_vi) )
        `uvm_error("", "uvm_config_db::get failed")
    endfunction 
   
    task run_phase(uvm_phase phase);
      forever
      begin
        seq_item_port.get_next_item(req);

        // Wiggle pins of DUT
        @(posedge dut_vi.clock);
        dut_vi.cmd  = req.cmd;
        dut_vi.addr = req.addr;
        dut_vi.data = req.data;
        
        seq_item_port.item_done();
      end
    endtask

  endclass: my_driver
  
  
  class my_env extends uvm_env;

    `uvm_component_utils(my_env)
    
    my_sequencer m_seqr;
    my_driver    m_driv;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
      m_seqr = my_sequencer::type_id::create("m_seqr", this);
      m_driv = my_driver   ::type_id::create("m_driv", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      m_driv.seq_item_port.connect( m_seqr.seq_item_export );
    endfunction
    
  endclass: my_env
  
  
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
      my_sequence seq;
      seq = my_sequence::type_id::create("seq");
      if( !seq.randomize() ) 
        `uvm_error("", "Randomize failed")
      seq.starting_phase = phase;
      seq.start( m_env.m_seqr );
    endtask
     
  endclass: my_test
  
  
endpackage: my_pkg


module top;

  import uvm_pkg::*;
  import my_pkg::*;
  
  dut_if dut_if1 ();
  
  dut    dut1 ( .dif(dut_if1) );

  // Clock generator
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

endmodule: top

