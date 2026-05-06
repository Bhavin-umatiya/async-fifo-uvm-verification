module synchronizer #(parameter WIDTH = 5)
(
    input clk,
    input rst,
    input [WIDTH-1:0] d_in,
    output reg [WIDTH-1:0] d_out
);

    reg [WIDTH-1:0] sync_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_reg <= 0;
            d_out <= 0;
        end else begin
            sync_reg <= d_in;
            d_out <= sync_reg;
        end
    end

endmodule
