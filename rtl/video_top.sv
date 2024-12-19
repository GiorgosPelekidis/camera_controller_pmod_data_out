module video_top (
  input  logic        clk_i,
  input  logic        rst_n_i,

  input  logic        start_cam_i,

  // To camera I/O
  input  logic [7:0]  data_i,

  inout  logic        sda_io,
  output logic        scl_o,

  input  logic        vsync_i,
  input  logic        href_i,
  input  logic        pclk_i,
  output logic        xclk_o,

  // To PMOD's
  output logic        pmod_write_en_o,
  output logic        pmod_sof_o,
  output logic        pmod_clk_o,
  output logic [3:0]  pmod_data_o,

  // // To VGA I/O
  // output logic        hsync_o,
  // output logic        vsync_o,
  // output logic [3:0]  red_o,
  // output logic [3:0]  green_o,
  // output logic [3:0]  blue_o,

  // Debug
  output logic [15:0] LED
);


logic cen_s;
logic done_s;
logic vsync_reg_s;
logic vsync_negedge_s;
logic write_f_en_s;

logic cam_write_s;
logic fb_write_s;

logic [18:0] cam_addr_s;
logic [14:0] fb_addr_s;
logic [14:0] vga_addr_s;

logic [3:0]  cam_data_s;
logic [3:0]  fb_data_s;
logic [3:0]  vga_data_s;

camera_controller camera_controller_0 (
  .*,

  .fb_addr_o (cam_addr_s),
  .fb_data_o (cam_data_s),
  .fb_wr_o   (cam_write_s)
);

frame_downscaler_by_four downscale_frame (
    .*,

    .pixel_write_i(cam_write_s),
    .pixel_addr_i(cam_addr_s),
    .pixel_data_i(cam_data_s),
    .fb_write_o(fb_write_s),
    .fb_addr_o(fb_addr_s),
    .fb_data_o(fb_data_s)
);

blk_mem_gen_0 frame_buffer_0 (
  .clka (clk_i),
  .wea  (fb_write_s),
  .addra(fb_addr_s),
  .dina (fb_data_s),

  .clkb (clk_i),
  .addrb(vga_addr_s),
  .doutb(vga_data_s)
);

pixel_transfer pt_inst (
    .*,
    .fb_addr_o(vga_addr_s),
    .fb_data_i(vga_data_s),
    .write_en_o(pmod_write_en_o),
    .sof_o(pmod_sof_o),
    .data_o(pmod_data_o)
);


assign pmod_clk_o = clk_i;

// vga_controller vga_controller_0 (
//   .*,
//   .fb_addr_o(vga_addr_s),
//   .fb_data_i(vga_data_s)
// );


endmodule