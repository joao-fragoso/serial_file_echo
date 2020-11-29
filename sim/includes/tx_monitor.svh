`timescale 1ps/1ps
class tx_monitor extends uvm_monitor;
  `uvm_component_utils(tx_monitor)

  uvm_analysis_port #(file_seq_item) tx_port;

  virtual sfe_if _serial_vif;
  localparam BIT_TIME = (64'd1_000_000_000_000/project_pkg::BAUD_RATE);
  localparam HALF_BIT_TIME = (BIT_TIME/2);
  localparam NUM_BITS = project_pkg::NUM_BITS;
  localparam PARITY = project_pkg::PARITY;
  localparam STOP_BITS = project_pkg::STOP_BITS;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db #(virtual sfe_if #(.BAUD_RATE(project_pkg::BAUD_RATE), 
      .PARITY(project_pkg::PARITY), .NUM_BITS(project_pkg::NUM_BITS), 
      .STOP_BITS(project_pkg::STOP_BITS)))::get(null, "uvm_test_top", "serial_vif", _serial_vif))
      `uvm_fatal(get_name(), "Fail to find serial Interface");
    tx_port = new("tx_port", this);
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    automatic int i;
    automatic bit [NUM_BITS-1:0] data;
    automatic bit parity_bit;
    automatic file_seq_item recfile;
    recfile = file_seq_item::type_id::create("recfile");
    recfile.randomize();
    recfile.empty();
    forever begin
      wait(_serial_vif.tx);
      @(negedge _serial_vif.tx) #HALF_BIT_TIME;
      #BIT_TIME;
      for(i=0;i<NUM_BITS;i++) begin
        data[i]=_serial_vif.tx;
        #BIT_TIME;
      end
      if ( PARITY != 0) begin
        parity_bit = _serial_vif.tx;
        #BIT_TIME;
      end
      for(i=0;i<STOP_BITS-1;i++)
        #BIT_TIME;
      // receive a bye
      if (data == project_pkg::SOT || data == project_pkg::EOT) begin
        if (recfile.size()>0) begin
          tx_port.write(recfile);
          recfile.empty();
        end
      end else begin
          recfile.add_data(data);
      end
      `uvm_info(get_name(), $sformatf("Data received in tx %d", data), UVM_MEDIUM);
    end    
  endtask : run_phase
endclass : tx_monitor