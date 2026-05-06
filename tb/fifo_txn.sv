// =============================================================================
// File: fifo_txn.sv
// Description: UVM transaction (sequence item) for Async FIFO
// Author: Bhavin Umatiya
// =============================================================================

class fifo_txn extends uvm_sequence_item;

    // Stimulus fields
    rand bit        wr_en;
    rand bit        rd_en;
    rand bit [7:0]  data_in;

    // Response fields
    bit [7:0]       data_out;
    bit             full;
    bit             empty;

    // Constraints for realistic traffic
    constraint valid_ops {
        // Avoid simultaneous idle cycles
        !(wr_en == 0 && rd_en == 0) dist {0 := 20, 1 := 80};
    }

    constraint data_range {
        data_in inside {[8'h00 : 8'hFF]};
    }

    `uvm_object_utils_begin(fifo_txn)
        `uvm_field_int(wr_en,    UVM_ALL_ON)
        `uvm_field_int(rd_en,    UVM_ALL_ON)
        `uvm_field_int(data_in,  UVM_ALL_ON)
        `uvm_field_int(data_out, UVM_ALL_ON)
        `uvm_field_int(full,     UVM_ALL_ON)
        `uvm_field_int(empty,    UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "fifo_txn");
        super.new(name);
    endfunction

endclass
