// =============================================================================
// File: fifo_monitor.sv
// Description: UVM monitor — observes FIFO interface transactions passively
// Author: Bhavin Umatiya
// =============================================================================

class fifo_monitor extends uvm_monitor;

    `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;

    uvm_analysis_port #(fifo_txn) wr_ap;  // Write-side analysis port
    uvm_analysis_port #(fifo_txn) rd_ap;  // Read-side analysis port

    function new(string name = "fifo_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_ap = new("wr_ap", this);
        rd_ap = new("rd_ap", this);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Failed to get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            monitor_write();
            monitor_read();
        join
    endtask

    // Monitor write transactions
    task monitor_write();
        fifo_txn txn;
        forever begin
            @(posedge vif.wr_clk);
            if (vif.wr_en && !vif.full) begin
                txn = fifo_txn::type_id::create("wr_txn");
                txn.wr_en   = vif.wr_en;
                txn.data_in = vif.data_in;
                txn.full    = vif.full;
                wr_ap.write(txn);
                `uvm_info("MON", $sformatf("WR: data_in=0x%02h full=%0b", txn.data_in, txn.full), UVM_HIGH)
            end
        end
    endtask

    // Monitor read transactions
    task monitor_read();
        fifo_txn txn;
        forever begin
            @(posedge vif.rd_clk);
            if (vif.rd_en && !vif.empty) begin
                txn = fifo_txn::type_id::create("rd_txn");
                txn.rd_en    = vif.rd_en;
                txn.data_out = vif.data_out;
                txn.empty    = vif.empty;
                rd_ap.write(txn);
                `uvm_info("MON", $sformatf("RD: data_out=0x%02h empty=%0b", txn.data_out, txn.empty), UVM_HIGH)
            end
        end
    endtask

endclass
