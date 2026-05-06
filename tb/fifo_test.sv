class fifo_base_seq extends uvm_sequence #(fifo_txn);
    `uvm_object_utils(fifo_base_seq)
    function new(string name = "fifo_base_seq");
        super.new(name);
    endfunction
    task body();
        fifo_txn txn;
        repeat(500) begin
            txn = fifo_txn::type_id::create("txn");
            start_item(txn);
            assert(txn.randomize());
            finish_item(txn);
        end
    endtask
endclass

class fifo_write_burst_seq extends uvm_sequence #(fifo_txn);
    `uvm_object_utils(fifo_write_burst_seq)
    function new(string name = "fifo_write_burst_seq");
        super.new(name);
    endfunction
    task body();
        fifo_txn txn;
        repeat(20) begin
            txn = fifo_txn::type_id::create("txn");
            start_item(txn);
            assert(txn.randomize() with { wr_en == 1; rd_en == 0; });
            finish_item(txn);
        end
        repeat(20) begin
            txn = fifo_txn::type_id::create("txn");
            start_item(txn);
            assert(txn.randomize() with { wr_en == 0; rd_en == 1; });
            finish_item(txn);
        end
    endtask
endclass

class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)
    fifo_env env;
    function new(string name = "fifo_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction
    task run_phase(uvm_phase phase);
        fifo_base_seq base_seq;
        fifo_write_burst_seq burst_seq;
        phase.raise_objection(this);
        base_seq = fifo_base_seq::type_id::create("base_seq");
        base_seq.start(env.seqr);
        burst_seq = fifo_write_burst_seq::type_id::create("burst_seq");
        burst_seq.start(env.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass
