//  Class: file_comparator
//
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_tx)

class file_comparator extends uvm_component;
  `uvm_component_utils(file_comparator);

  //typedef file_comparator #(file_seq_item) this_type;
  //`uvm_component_param_utils(file_comparator)

  uvm_analysis_imp_rx #(file_seq_item, file_comparator) rx_port;
  uvm_analysis_imp_tx #(file_seq_item, file_comparator) tx_port;


  protected int n_matches;
  protected int n_errors;
  protected file_seq_item rx_files[$];

  //  Constructor: new
  function new(string name = "file_comparator", uvm_component parent);
    super.new(name, parent);
    rx_port = new("rx_port", this);
    tx_port = new("tx_port", this);
  endfunction: new

  function void build_phase(uvm_phase phase);
    n_matches = 0;
    n_errors = 0;
  endfunction

  virtual function int get_matches();
    return n_matches;
  endfunction

  virtual function int get_errors();
    return n_errors;
  endfunction

  task run_phase(uvm_phase phase);
    fork
    join
  endtask

  virtual function void write_rx(file_seq_item _file);
    rx_files.push_back(_file);
    `uvm_info(get_name(),"Adding file to queue", UVM_MEDIUM);
  endfunction

  virtual function void write_tx(file_seq_item _file);
    automatic file_seq_item _rx_file;
    `uvm_info(get_name(),"File received by monitor", UVM_MEDIUM);
    if (rx_files.size()>0) begin
      _rx_file = rx_files.pop_front();
      if (_rx_file.verbose_compare(_file)) begin
        `uvm_info(get_name(), "File received matches transmitted!!", UVM_MEDIUM);
        n_matches++;
      end else begin
        `uvm_error(get_name(), "File received does NOT MATCH transmitted!");
        n_errors++;
      end
    end else begin
      `uvm_error(get_name(), "No files in the queue!");
      n_errors++;
    end
  endfunction
  
endclass: file_comparator
