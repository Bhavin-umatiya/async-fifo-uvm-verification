module read_pointer #(parameter ADDR_WIDTH = 4)
(
    input rd_clk,
    input rst,
    input rd_en,
    input empty,
    output reg [ADDR_WIDTH:0] rd_ptr_bin,
    output [ADDR_WIDTH:0] rd_ptr_gray
);

    always @(posedge rd_clk or posedge rst) begin
        if (rst)
            rd_ptr_bin <= 0;
        else if (rd_en && !empty)
            rd_ptr_bin <= rd_ptr_bin + 1;
    end

    assign rd_ptr_gray = rd_ptr_bin ^ (rd_ptr_bin >> 1);

endmodule
