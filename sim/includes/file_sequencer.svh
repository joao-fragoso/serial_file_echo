class file_sequencer extends uvm_sequencer #(file_seq_item);

`uvm_component_utils(file_sequencer)

function new(string name = "file_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

endclass: file_sequencer