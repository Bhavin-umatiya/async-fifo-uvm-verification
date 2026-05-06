module write_pointer #(parameter ADDR_WIDTH = 4)
(
    input wr_clk,
    input rst,
    input wr_en,
    input full,
    output reg [ADDR_WIDTH:0] wr_ptr_bin,
    output [ADDR_WIDTH:0] wr_ptr_gray
);

    always @(posedge wr_clk or posedge rst) begin
        if (rst)
            wr_ptr_bin <= 0;
        else if (wr_en && !full)
            wr_ptr_bin <= wr_ptr_bin + 1;
    end

    assign wr_ptr_gray = wr_ptr_bin ^ (wr_ptr_bin >> 1);

endmodule
