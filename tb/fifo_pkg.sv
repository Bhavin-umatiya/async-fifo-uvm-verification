// =============================================================================
// File: fifo_pkg.sv
// Description: UVM package for Async FIFO verification environment
// Author: Bhavin Umatiya
// =============================================================================

package fifo_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "fifo_txn.sv"
    `include "fifo_driver.sv"
    `include "fifo_monitor.sv"
    `include "fifo_scoreboard.sv"
    `include "fifo_coverage.sv"
    `include "fifo_env.sv"
    `include "fifo_test.sv"

endpackage
