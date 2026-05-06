// =============================================================================
// File: fifo_if.sv
// Description: Interface for Async FIFO DUT connection
// Author: Bhavin Umatiya
// =============================================================================

interface fifo_if #(parameter DATA_WIDTH = 8) (
    input logic wr_clk,
    input logic rd_clk
);

    logic rst;
    logic wr_en;
    logic rd_en;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic full;
    logic empty;

    // Write domain clocking block
    clocking wr_cb @(posedge wr_clk);
        default input #1 output #1;
        output wr_en;
        output data_in;
        input  full;
    endclocking

    // Read domain clocking block
    clocking rd_cb @(posedge rd_clk);
        default input #1 output #1;
        output rd_en;
        input  data_out;
        input  empty;
    endclocking

    // Write domain modport
    modport WR_DRV (clocking wr_cb, output rst);
    modport RD_DRV (clocking rd_cb);

    // Monitor modport
    modport MON (
        input wr_clk, rd_clk, rst,
        input wr_en, rd_en,
        input data_in, data_out,
        input full, empty
    );

endinterface
