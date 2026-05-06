module fifo_top #(parameter DATA_WIDTH = 8,
                  parameter ADDR_WIDTH = 4)
(
    input wr_clk, rd_clk,
    input wr_en, rd_en,
    input [DATA_WIDTH-1:0] data_in,
    input rst,
    output [DATA_WIDTH-1:0] data_out,
    output full, empty
);

    wire [ADDR_WIDTH:0] wr_ptr_bin, rd_ptr_bin;
    wire [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;

    wire [ADDR_WIDTH:0] wr_ptr_gray_sync;
    wire [ADDR_WIDTH:0] rd_ptr_gray_sync;

    write_pointer wp (
        .wr_clk(wr_clk),
        .rst(rst),
        .wr_en(wr_en),
        .full(full),
        .wr_ptr_bin(wr_ptr_bin),
        .wr_ptr_gray(wr_ptr_gray)
    );

    read_pointer rp (
        .rd_clk(rd_clk),
        .rst(rst),
        .rd_en(rd_en),
        .empty(empty),
        .rd_ptr_bin(rd_ptr_bin),
        .rd_ptr_gray(rd_ptr_gray)
    );

    synchronizer sync_w2r (
        .clk(rd_clk),
        .rst(rst),
        .d_in(wr_ptr_gray),
        .d_out(wr_ptr_gray_sync)
    );

    synchronizer sync_r2w (
        .clk(wr_clk),
        .rst(rst),
        .d_in(rd_ptr_gray),
        .d_out(rd_ptr_gray_sync)
    );

    fifo_mem mem (
        .wr_clk(wr_clk),
        .wr_en(wr_en && !full),
        .wr_addr(wr_ptr_bin[ADDR_WIDTH-1:0]),
        .data_in(data_in),
        .rd_clk(rd_clk),
        .rd_en(rd_en && !empty),
        .rd_addr(rd_ptr_bin[ADDR_WIDTH-1:0]),
        .data_out(data_out)
    );

    assign full = (wr_ptr_gray ==
                  {~rd_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
                   rd_ptr_gray_sync[ADDR_WIDTH-2:0]});

    assign empty = (rd_ptr_gray == wr_ptr_gray_sync);

endmodule
