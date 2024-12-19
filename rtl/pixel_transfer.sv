module pixel_transfer(
    input logic clk_i,
    input logic rst_n_i,

    output logic [14:0] fb_addr_o,
    input  logic [3:0]  fb_data_i,

    output logic        write_en_o,
    output logic        sof_o,  // start of frame
    output logic [3:0]  data_o
);


logic half_clk_s;
always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
        half_clk_s <= 0;
    end else begin
        half_clk_s <= ~half_clk_s;
    end
end

// frame buffer control -------------------------------------------------------------
always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
        fb_addr_o <= 0;
    end else begin
        if (half_clk_s) begin
            fb_addr_o <= (fb_addr_o == 19200-1) ? 15'd0 : fb_addr_o + 1;
        end
    end
end
//-----------------------------------------------------------------------------------

// drive data out -------------------------------------------------------------------
assign write_en_o = half_clk_s;
assign sof_o = (fb_addr_o == 15'b0);
assign data_o = (write_en_o) ? fb_data_i : 4'bX;
//-----------------------------------------------------------------------------------

endmodule
