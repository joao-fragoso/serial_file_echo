class file_sequence extends uvm_sequence #(file_seq_item);

  `uvm_object_utils(file_sequence)
  file_seq_item aFile;
  int no_files=1;
  int files_sent = 0;
  function new (string name = "File sequence");
    super.new(name);
  endfunction : new

  task body;
    aFile = file_seq_item::type_id::create("file");
    while(files_sent < no_files) begin
      start_item(aFile);
      if (!aFile.randomize()) begin
        `uvm_fatal(get_name(), "Fail to randomizer a File");
      end
      finish_item(aFile);
      aFile.end_event.wait_on();
      `uvm_info(get_name(), $sformatf("File %02d/%02d size=%0d to serial", files_sent+1, no_files, aFile.size()), UVM_MEDIUM);
      files_sent++;
    end
  endtask : body
endclass : file_sequence
