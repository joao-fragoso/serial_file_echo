class serial_driver extends uvm_driver #(file_seq_item);
  
  `uvm_component_utils(serial_driver)

  file_seq_item aFile;
  virtual sfe_if #(.BAUD_RATE(project_pkg::BAUD_RATE), .PARITY(project_pkg::PARITY), .NUM_BITS(project_pkg::NUM_BITS), .STOP_BITS(project_pkg::STOP_BITS))
    serial_vif;
  uvm_analysis_port #(file_seq_item) rx_port;

  function new(string name="serial_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void set_serial_if(virtual sfe_if #(.BAUD_RATE(project_pkg::BAUD_RATE), .PARITY(project_pkg::PARITY), .NUM_BITS(project_pkg::NUM_BITS), .STOP_BITS(project_pkg::STOP_BITS))
 _serial);
    serial_vif = _serial;
  endfunction

  function void build_phase(uvm_phase phase);
    rx_port = new("rx_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    automatic bit [project_pkg::NUM_BITS-1:0] data;
    automatic int i;
    forever begin
      seq_item_port.get_next_item(aFile);
      `uvm_info(get_name(), $sformatf("Sending file of size %d", aFile.size()), UVM_MEDIUM);
      `uvm_info(get_name(), "Sending SOT", UVM_MEDIUM);
      data = project_pkg::SOT;
      serial_vif.write_data(data);
      for(i=0; i<aFile.size(); i++) begin
        `uvm_info(get_name(), $sformatf("Send data %d value %d", i, aFile.data[i]), UVM_MEDIUM);
        serial_vif.write_data(aFile.data[i]);
      end
      data = project_pkg::EOT;
      `uvm_info(get_name(), "Sending EOT", UVM_MEDIUM);
      serial_vif.write_data(data);
      rx_port.write(aFile);
      seq_item_port.item_done();
    end
  endtask: run_phase

endclass : serial_driver