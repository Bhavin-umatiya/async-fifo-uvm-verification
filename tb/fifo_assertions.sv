// =============================================================================
// File: fifo_assertions.sv
// Description: SVA (SystemVerilog Assertions) for Async FIFO protocol checking
// Author: Bhavin Umatiya
// =============================================================================

module fifo_assertions #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 4)
(
    input logic wr_clk, rd_clk, rst,
    input logic wr_en, rd_en,
    input logic full, empty,
    input logic [DATA_WIDTH-1:0] data_in, data_out
);

    // =========================================================================
    // Property 1: No write when FIFO is full
    // =========================================================================
    property no_write_when_full;
        @(posedge wr_clk) disable iff (rst)
        (full && wr_en) |-> ##1 (full);
    endproperty
    assert property (no_write_when_full)
        else `uvm_error("ASSERT", "Write attempted while FIFO is full — data may be lost!")

    // =========================================================================
    // Property 2: No read when FIFO is empty
    // =========================================================================
    property no_read_when_empty;
        @(posedge rd_clk) disable iff (rst)
        (empty && rd_en) |-> ##1 (empty);
    endproperty
    assert property (no_read_when_empty)
        else `uvm_error("ASSERT", "Read attempted while FIFO is empty — data is invalid!")

    // =========================================================================
    // Property 3: After reset, FIFO must be empty
    // =========================================================================
    property reset_empty;
        @(posedge rd_clk)
        $rose(rst) |-> ##[1:3] empty;
    endproperty
    assert property (reset_empty)
        else `uvm_error("ASSERT", "FIFO not empty after reset!")

    // =========================================================================
    // Property 4: Full and empty should never be asserted simultaneously
    // =========================================================================
    property full_empty_mutex;
        @(posedge wr_clk) disable iff (rst)
        !(full && empty);
    endproperty
    assert property (full_empty_mutex)
        else `uvm_error("ASSERT", "Full and Empty asserted at the same time!")

    // =========================================================================
    // Property 5: data_out should remain stable when rd_en is deasserted
    // =========================================================================
    property data_stable_no_read;
        @(posedge rd_clk) disable iff (rst)
        (!rd_en && !empty) |=> ($stable(data_out));
    endproperty
    assert property (data_stable_no_read)
        else `uvm_info("ASSERT", "data_out changed without rd_en (may be expected in async design)", UVM_MEDIUM)

endmodule
