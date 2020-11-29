class file_seq_item extends uvm_sequence_item;

//  rand int size;
  rand bit [project_pkg::NUM_BITS-1:0] data[$];

  `uvm_object_utils(file_seq_item)

  function new (string name ="random file");
    super.new(name);
  endfunction : new

  constraint c_len { data.size() > 10; data.size()<100;}
  constraint c_data { foreach(data[i]) data[i] inside {[9:126]}; }
/*  
  function void post_randomize();
    size = data.size;
  endfunction : post_randomize
*/
  function void do_copy(uvm_object rhs);
    file_seq_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_fatal("file_seq_item", "Failing casting before copying. Invalid object");
    end
    //size = rhs_.size;
    data = rhs_.data;
  endfunction : do_copy

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    file_seq_item rhs_;
    do_compare = $cast(rhs_, rhs) &&
                super.do_compare(rhs, comparer) &&
                //size == rhs_.size &&
                data == rhs_.data;
  endfunction : do_compare

  function string convert2string();
    string s;
    s = super.convert2string();
    $sformat(s,"FILE size=%0d data=%p", data.size(), data);
    return s;
  endfunction : convert2string

  function void do_print(uvm_printer printer);
    printer.m_string = convert2string();
  endfunction : do_print

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
//    `uvm_record_field("size", size);
    `uvm_record_field("data", data);
  endfunction : do_record  
  
  function void add_data(bit [project_pkg::NUM_BITS-1:0] _data);
    data.push_back(_data);
   // size = data.size;
  endfunction

  function void empty();
    data.delete();
  endfunction
  
  function int size();
    return data.size();
  endfunction

  function bit verbose_compare(file_seq_item rhs);
    bit isEqual;
    int size;
    int i;
    isEqual = compare(rhs);
    if (~isEqual) begin
      if (data.size() != rhs.data.size()) begin
        `uvm_info(get_name(), $sformatf("Files size does not match %d != %d", data.size(), rhs.data.size()), UVM_MEDIUM);
      end
      size = (data.size() < rhs.data.size()) ? data.size() : rhs.data.size();
      for(i=0; i<size; i++) begin
        if (data[i] != rhs.data[i])
          `uvm_info(get_name(), $sformatf("File data differs @%d: %h != %h", i, data[i], rhs.data[i]), UVM_MEDIUM);
      end
    end
    verbose_compare = isEqual;
  endfunction : verbose_compare


endclass : file_seq_item
