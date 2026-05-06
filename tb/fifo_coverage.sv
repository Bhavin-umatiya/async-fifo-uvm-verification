// =============================================================================
// File: fifo_coverage.sv
// Description: Functional coverage for Async FIFO verification
// Author: Bhavin Umatiya
// =============================================================================

class fifo_coverage extends uvm_subscriber #(fifo_txn);

    `uvm_component_utils(fifo_coverage)

    fifo_txn txn;

    covergroup fifo_cg;

        // Cover write enable toggle
        cp_wr_en: coverpoint txn.wr_en {
            bins write_active = {1};
            bins write_idle   = {0};
        }

        // Cover read enable toggle
        cp_rd_en: coverpoint txn.rd_en {
            bins read_active = {1};
            bins read_idle   = {0};
        }

        // Cover full flag
        cp_full: coverpoint txn.full {
            bins fifo_full     = {1};
            bins fifo_not_full = {0};
        }

        // Cover empty flag
        cp_empty: coverpoint txn.empty {
            bins fifo_empty     = {1};
            bins fifo_not_empty = {0};
        }

        // Cover data values — corner cases
        cp_data: coverpoint txn.data_in {
            bins zero     = {8'h00};
            bins max      = {8'hFF};
            bins low      = {[8'h01 : 8'h3F]};
            bins mid      = {[8'h40 : 8'hBF]};
            bins high     = {[8'hC0 : 8'hFE]};
        }

        // Cross coverage: simultaneous read & write
        cx_rw: cross cp_wr_en, cp_rd_en;

        // Cross coverage: full and write attempt
        cx_full_wr: cross cp_full, cp_wr_en;

        // Cross coverage: empty and read attempt
        cx_empty_rd: cross cp_empty, cp_rd_en;

    endgroup

    function new(string name = "fifo_coverage", uvm_component parent);
        super.new(name, parent);
        fifo_cg = new();
    endfunction

    function void write(fifo_txn t);
        txn = t;
        fifo_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("COV", $sformatf("Functional Coverage: %.2f%%", fifo_cg.get_coverage()), UVM_NONE)
    endfunction

endclass
