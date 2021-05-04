
module final_top(
    /*
	 'define H_SYNC_PULSE 112
	 'define H_BACK_PORCH 248
	 'define H_FRONT_PORCH 48
	 'define V_SYNC_PULSE 3
	 'define V_BACK_PORCH 38
	 'define V_FRONT_PORCH 1
*/

	 // Clock
    input clk_100,


    // ADAU_1761 interface
    output  AC_ADR0,            // I2C Address pin (DO NOT CHANGE)
    output  AC_ADR1,            // I2C Address pin (DO NOT CHANGE)

    output  AC_GPIO0,           // I2S Signals
    input   AC_GPIO1,           // I2S Signals
    input   AC_GPIO2,           // I2S Byte Clock
    input   AC_GPIO3,           // I2S Channel Clock

    output  AC_MCLK,            // Master clock (48MHz)
    output  AC_SCK,             // I2C SCK
    inout   AC_SDA,             // I2C SDA

    // LEDs
    output [7:0] leds,
    // DVI Interface

    // I2C
    output HDMI_SCL,
    inout  HDMI_SDA,

	 output hdmi_clk,
	 output hdmi_hsync,
	 output hdmi_vsync,
	 output [15:0] hdmi_d,
	 output hdmi_de,
	 // input hdmi_int,

	 input [8:1] sw,
    input btn_up,
    input btn_left,
    input btn_right,
    input btn_down,
	 input btn_center,
    input [2:0] pmod,
	 input pmod_btn,

    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);

   // Our reset
	wire reset = btn_up;
	 

    
	//  ****************************************************************************
	//      Button processor units
	//  ****************************************************************************
	parameter BPU_WIDTH = 20; //Parameter for testing. Setting it to 1 effectively disables it.
	
	wire down_button_debounced;
	button_press_unit #(.WIDTH(BPU_WIDTH)) down_button_press_unit(
		 .clk(clk_100),
		 .reset(reset),
		 .in(btn_down),
		 .out(down_button_debounced)
	);

	wire right_button_debounced;
	button_press_unit #(.WIDTH(BPU_WIDTH)) right_button_press_unit(
		 .clk(clk_100),
		 .reset(reset),
		 .in(btn_right),
		 .out(right_button_debounced)
	);

	wire left_button_debounced;
	button_press_unit #(.WIDTH(BPU_WIDTH)) left_button_press_unit(
		 .clk(clk_100),
		 .reset(reset),
		 .in(btn_left),
		 .out(left_button_debounced)
	);
	
	wire center_button_debounced;
	button_press_unit #(.WIDTH(BPU_WIDTH)) center_button_press_unit(
		 .clk(clk_100),
		 .reset(reset),
		 .in(btn_center),
		 .out(center_button_debounced)
	);

	wire scale_button;
	button_press_unit #(.WIDTH(BPU_WIDTH)) pmod_button_press_unit(
		 .clk(clk_100),
		 .reset(reset),
		 .in(pmod_btn),
		 .out(scale_button)
	);


//  ****************************************************************************
//      OUR MAGNUS OPUS
//  ****************************************************************************
	 wire [1:0] song;
    wire new_frame;
    wire [15:0] codec_sample, flopped_sample;
    wire new_sample, flopped_new_sample;
	 wire [55:0] to_display;
	 wire [1:0] master_state;
    magnus_opus magnus_opus(
		 //inputs
		 .clk(clk_100),
		 .reset(reset),
		 .switches(sw[8:1]),
		 .left_button(left_button_debounced),
		 .right_button(right_button_debounced),
		 .down_button(down_button_debounced),
		 .center_button(center_button_debounced),
		 .scale_button(scale_button),
		 .new_frame(new_frame),
		 .leds(leds),
		 
		 //outputs
		 .master_state(master_state),
		 .sample_out(codec_sample),
		 .new_sample_generated(new_sample),
		 .song(song),
		 .to_display(to_display)
    );
	 
	 assign leds = (master_state == 2'b10) ? {4{song}} : sw[8:1];

    dff #(.WIDTH(17)) sample_reg (
        .clk(clk_100),
        .d({new_sample, codec_sample}),
        .q({flopped_new_sample, flopped_sample})
    );


//  ****************************************************************************
//      Codec interface
//  ****************************************************************************

   wire [23:0] hphone_r = 0;
	wire [23:0] line_in_l = 0;
	wire [23:0] line_in_r =  0;

    adau1761_codec adau1761_codec(
        .clk_100(clk_100),
        .reset(reset),
        .AC_ADR0(AC_ADR0),
        .AC_ADR1(AC_ADR1),
        .I2S_MISO(AC_GPIO0),
        .I2S_MOSI(AC_GPIO1),
        .I2S_bclk(AC_GPIO2),
        .I2S_LR(AC_GPIO3),
        .AC_MCLK(AC_MCLK),
        .AC_SCK(AC_SCK),
        .AC_SDA(AC_SDA),
        .hphone_l({codec_sample, 8'h00}),
        .hphone_r(hphone_r),
        .line_in_l(line_in_l),
        .line_in_r(line_in_r),
        .new_sample(new_frame)
    );


//  ****************************************************************************
//      Display management -> do not touch!
//  ****************************************************************************

	// These signals are for determining which color to display
   wire [11:0] x;  // [0..1279]
   wire [11:0]  y;  // [0..1023]
   wire [11:0] x_q;
   wire [11:0] y_q;
   // Color to display at the given x,y
   wire [7:0]  r, g, b;
   wire [7:0] r_1, g_1, b_1;

	
	wire valid;
	vga_hdmi hdmi(
		.clk_100(clk_100),
      .color({r_1, g_1, b_1}),
      .vga_r(VGA_R),
      .vga_b(VGA_B),
      .vga_g(VGA_G),
      .vga_hs(VGA_HS),
      .vga_vs(VGA_VS),
      .hdmi_clk (hdmi_clk),
      .hdmi_hsync (hdmi_hsync),
      .hdmi_vsync (hdmi_vsync),
      .hdmi_d (hdmi_d),
      .hdmi_de (hdmi_de),
      .hdmi_scl (HDMI_SCL),
      .xpos(x),
      .ypos(y),
      .valid(valid),
      .hdmi_sda (HDMI_SDA)
	);

    display_top d_top (
		.clk(clk_100),
		.reset(reset),
		.new_sample(flopped_new_sample), // flopped_new_sample?
		.sample(flopped_sample),
      .x(x[10:0]),
      .y(y[9:0]),
		.valid(valid),
		.to_display(to_display),
		.vsync(hdmi_vsync),
		
		.r(r_1),
		.g(g_1),
		.b(b_1)
	);


endmodule