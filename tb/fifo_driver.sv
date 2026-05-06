// =============================================================================
// File: fifo_driver.sv
// Description: UVM driver for Async FIFO — drives stimuli on both clock domains
// Author: Bhavin Umatiya
// =============================================================================

class fifo_driver extends uvm_driver #(fifo_txn);

    `uvm_component_utils(fifo_driver)

    virtual fifo_if vif;

    function new(string name = "fifo_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Failed to get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        fifo_txn txn;
        forever begin
            seq_item_port.get_next_item(txn);
            drive_transaction(txn);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(fifo_txn txn);
        // Drive write domain
        @(posedge vif.wr_clk);
        vif.wr_en   <= txn.wr_en;
        vif.data_in  <= txn.data_in;

        // Drive read domain
        @(posedge vif.rd_clk);
        vif.rd_en <= txn.rd_en;

        // Capture response
        @(posedge vif.rd_clk);
        txn.data_out = vif.data_out;
        txn.full     = vif.full;
        txn.empty    = vif.empty;
    endtask

endclass
