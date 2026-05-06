// =============================================================================
// File: fifo_scoreboard.sv
// Description: UVM scoreboard — verifies data integrity across clock domains
// Author: Bhavin Umatiya
// =============================================================================

class fifo_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp_decl(_wr)
    uvm_analysis_imp_decl(_rd)

    uvm_analysis_imp_wr #(fifo_txn, fifo_scoreboard) wr_imp;
    uvm_analysis_imp_rd #(fifo_txn, fifo_scoreboard) rd_imp;

    // Reference model: internal queue mirrors FIFO behavior
    bit [7:0] ref_queue[$];
    int       pass_count;
    int       fail_count;

    function new(string name = "fifo_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_imp = new("wr_imp", this);
        rd_imp = new("rd_imp", this);
        pass_count = 0;
        fail_count = 0;
    endfunction

    // Called when monitor detects a write
    function void write_wr(fifo_txn txn);
        ref_queue.push_back(txn.data_in);
        `uvm_info("SCB", $sformatf("WRITE: Pushed 0x%02h (queue size: %0d)", txn.data_in, ref_queue.size()), UVM_MEDIUM)
    endfunction

    // Called when monitor detects a read
    function void write_rd(fifo_txn txn);
        bit [7:0] expected;

        if (ref_queue.size() == 0) begin
            `uvm_error("SCB", $sformatf("READ from empty FIFO! Got 0x%02h", txn.data_out))
            fail_count++;
            return;
        end

        expected = ref_queue.pop_front();

        if (txn.data_out === expected) begin
            pass_count++;
            `uvm_info("SCB", $sformatf("MATCH: Expected=0x%02h Got=0x%02h [PASS #%0d]", expected, txn.data_out, pass_count), UVM_MEDIUM)
        end else begin
            fail_count++;
            `uvm_error("SCB", $sformatf("MISMATCH: Expected=0x%02h Got=0x%02h [FAIL #%0d]", expected, txn.data_out, fail_count))
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCB", "========================================", UVM_NONE)
        `uvm_info("SCB", "       SCOREBOARD FINAL REPORT          ", UVM_NONE)
        `uvm_info("SCB", "========================================", UVM_NONE)
        `uvm_info("SCB", $sformatf("  PASS: %0d", pass_count), UVM_NONE)
        `uvm_info("SCB", $sformatf("  FAIL: %0d", fail_count), UVM_NONE)
        `uvm_info("SCB", $sformatf("  Remaining in queue: %0d", ref_queue.size()), UVM_NONE)
        if (fail_count == 0)
            `uvm_info("SCB", "  *** TEST PASSED ***", UVM_NONE)
        else
            `uvm_error("SCB", "  *** TEST FAILED ***")
        `uvm_info("SCB", "========================================", UVM_NONE)
    endfunction

endclass
