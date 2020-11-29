//  Class: file_scoreboard
//
class file_scoreboard extends uvm_component;
  `uvm_component_utils(file_scoreboard);

  uvm_analysis_export #(file_seq_item) rx_port;
  uvm_analysis_export #(file_seq_item) tx_port;
  file_comparator comp;

  function new(string name = "file_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    rx_port = new("rx_port", this);
    tx_port = new("tx_port", this);    
    comp = file_comparator::type_id::create("comp", this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rx_port.connect(comp.rx_port);
    tx_port.connect(comp.tx_port);
  endfunction: connect_phase
  
  function bit passfail();
    if (comp.get_errors() == 0)
      return 1'b1;
    return 1'b0;
  endfunction
  
  function void summarize();
    automatic int errs;
    automatic int tot;
    errs = comp.get_errors();
    tot = comp.get_matches();
    tot += errs;
    `uvm_info(get_name(), $sformatf("Received: %d, Errors: %d", tot, errs), UVM_MEDIUM);
  endfunction
  
endclass: file_scoreboard
