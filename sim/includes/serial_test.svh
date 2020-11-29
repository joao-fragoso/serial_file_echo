
class serial_test extends uvm_test;

  `uvm_component_utils(serial_test);

  project_env m_env;
  virtual reset_if rst_vif;
  virtual clk_if #(.CLK_FREQ(project_pkg::CLK_FREQ)) clk_vif;
  virtual sfe_if #(.BAUD_RATE(project_pkg::BAUD_RATE), .PARITY(project_pkg::PARITY), .NUM_BITS(project_pkg::NUM_BITS), .STOP_BITS(project_pkg::STOP_BITS)) _serial_vif;

  file_sequence file_test;
  file_sequencer m_file;
  serial_driver m_driver;
  tx_monitor m_monitor;
  file_scoreboard m_score;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    m_env = project_env::type_id::create("m_env", this);
    m_driver = serial_driver::type_id::create("m_driver",this);
    m_file = file_sequencer::type_id::create("m_file", this);
    m_monitor = tx_monitor::type_id::create("m_monitor", this);
    m_score = file_scoreboard::type_id::create("m_score", this);
    // recovering interfaces...
    if (!uvm_config_db #(virtual reset_if)::get(null, "uvm_test_top", "reset_vif", rst_vif))
      `uvm_fatal(get_name(), "Fail to find clock Interface");
    if (!uvm_config_db #(virtual clk_if #(.CLK_FREQ(project_pkg::CLK_FREQ)))::get(null, "uvm_test_top", "clk_vif", clk_vif))
      `uvm_fatal(get_name(), "Fail to find clock Interface");
    if (!uvm_config_db #(virtual sfe_if #(.BAUD_RATE(project_pkg::BAUD_RATE), 
      .PARITY(project_pkg::PARITY), .NUM_BITS(project_pkg::NUM_BITS), 
      .STOP_BITS(project_pkg::STOP_BITS)))::get(null, "uvm_test_top", "serial_vif", _serial_vif))
      `uvm_fatal(get_name(), "Fail to find serial Interface");
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    m_driver.seq_item_port.connect(m_file.seq_item_export);
    m_driver.set_serial_if(_serial_vif);
    m_driver.rx_port.connect(m_score.rx_port);
    m_monitor.tx_port.connect(m_score.tx_port);
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    file_test = file_sequence::type_id::create("file_test");
    phase.raise_objection(this);
    _serial_vif.init();
    clk_vif.start();
    clk_vif.wait_cycles(1);
    rst_vif.assert_reset();
    clk_vif.wait_cycles(4);
    rst_vif.dassert_reset();
    clk_vif.wait_cycles(2);
    `uvm_info(get_name(), "Starting sending file!", UVM_MEDIUM)
    file_test.start(m_file);
    #(64'd1_000_000_000_000);
    phase.drop_objection(this);
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info(get_name(), "Final results", UVM_MEDIUM);
  endfunction

endclass : serial_test
