module frame_downscaler_by_four #(
    parameter PIXEL_WIDTH = 4,

    parameter PIXELS_PER_LINE_I   = 640,
    parameter LINES_PER_FRAME_I   = 480,
    localparam PIXELS_PER_FRAME_I = LINES_PER_FRAME_I * PIXELS_PER_LINE_I,
    localparam FB_ADDR_WIDTH_I    = $clog2(PIXELS_PER_FRAME_I),

    parameter PIXELS_PER_LINE_O   = 160,
    parameter LINES_PER_FRAME_O   = 120,
    localparam PIXELS_PER_FRAME_O = LINES_PER_FRAME_O * PIXELS_PER_LINE_O,
    localparam FB_ADDR_WIDTH_O    = $clog2(PIXELS_PER_FRAME_O)
) (
    input logic                        clk_i,
    input logic                        rst_n_i,

    input logic                        pixel_write_i,
    input logic [FB_ADDR_WIDTH_I-1:0]  pixel_addr_i,
    input logic [PIXEL_WIDTH-1:0]      pixel_data_i,

    output logic                       fb_write_o,
    output logic [FB_ADDR_WIDTH_O-1:0] fb_addr_o,
    output logic [PIXEL_WIDTH-1:0]     fb_data_o
);
    
    localparam PPL_CNT_WIDTH = $clog2(PIXELS_PER_LINE_O);
    logic [PPL_CNT_WIDTH-1:0] pixel_per_line_cnt;
    assign zero_pixel_per_line_cnt = (pixel_per_line_cnt == PIXELS_PER_LINE_O-1);

    logic [1:0] four_cnt;
    assign four_cnt_en = (pixel_write_i && pixel_addr_i[1:0] == 2'b0 && pixel_per_line_cnt == PIXELS_PER_LINE_O-1);
    
    logic [FB_ADDR_WIDTH_O-1:0] pixel_cnt;
    logic pixel_cnt_en;
    logic zero_pixel_cnt;
    assign pixel_cnt_en = (pixel_write_i && (pixel_addr_i[1:0] == 2'b0) && (four_cnt == 2'b00));
    assign zero_pixel_cnt = (pixel_cnt == PIXELS_PER_FRAME_O-1);


    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            pixel_cnt <= (FB_ADDR_WIDTH_O)*(1'b0);
        end else begin
            if (pixel_cnt_en) begin
                pixel_cnt <= (zero_pixel_cnt) ? (FB_ADDR_WIDTH_O)*(1'b0) : pixel_cnt + 1;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            four_cnt <= 2'b0;
        end else begin
            if (four_cnt_en) begin
                four_cnt <= four_cnt + 1;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            pixel_per_line_cnt <= (PPL_CNT_WIDTH)*(1'b0);
        end else begin
            if (pixel_write_i && pixel_addr_i[1:0] == 2'b0) begin
                pixel_per_line_cnt <= (zero_pixel_per_line_cnt) ? (PPL_CNT_WIDTH)*(1'b0) : pixel_per_line_cnt + 1;
            end
        end
    end


    assign fb_write_o = pixel_cnt_en;
    assign fb_addr_o = pixel_cnt;
    assign fb_data_o = pixel_data_i;

endmodule
