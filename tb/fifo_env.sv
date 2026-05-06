// =============================================================================
// File: fifo_env.sv
// Description: UVM environment — connects driver, monitor, scoreboard, coverage
// Author: Bhavin Umatiya
// =============================================================================

class fifo_env extends uvm_env;

    `uvm_component_utils(fifo_env)

    fifo_driver      drv;
    fifo_monitor     mon;
    fifo_scoreboard  scb;
    fifo_coverage    cov;

    uvm_sequencer #(fifo_txn) seqr;

    function new(string name = "fifo_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv  = fifo_driver::type_id::create("drv", this);
        mon  = fifo_monitor::type_id::create("mon", this);
        scb  = fifo_scoreboard::type_id::create("scb", this);
        cov  = fifo_coverage::type_id::create("cov", this);
        seqr = uvm_sequencer #(fifo_txn)::type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect driver to sequencer
        drv.seq_item_port.connect(seqr.seq_item_export);
        // Connect monitor analysis ports to scoreboard
        mon.wr_ap.connect(scb.wr_imp);
        mon.rd_ap.connect(scb.rd_imp);
        // Connect monitor to coverage
        mon.wr_ap.connect(cov.analysis_export);
    endfunction

endclass
