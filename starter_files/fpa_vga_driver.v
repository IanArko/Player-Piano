//=============================================================================
// VGA display driver for Floating Point Adder
//
// Uses TCGROM to display characters based on current screen location
//
// Updated: 2012/01/29
//=============================================================================

`include "dvi_defines.v"

module fpa_vga_driver(
    input clk, 

    input [7:0] aIn,
    input [7:0] bIn,
    input [7:0] result,

    input [`log2NUM_COLS-1:0] XPos, 
    input [`log2NUM_ROWS-1:0] YPos, 
    input Valid, 

    output wire [5:0] vga_rgb
);

    wire [7:0] tcgrom_d, tcgrom_q;
    reg        color;
    reg  [5:0] char_selection;
    wire [5:0] char_selection_q;
    reg  [5:0] char_color;
    wire [5:0] char_color_q, char_color_2_q;
    wire       lineValid;
     
//=============================================================================
//  Hook up the VGA modules and define the output colors
//=============================================================================
    // Display the correct characters
    always @* begin
        char_selection = 6'b100000;
        char_color = 6'b111111;  // RRBBGG

        case (YPos[`log2NUM_ROWS-1:6])
            // Dummy line to silence ISE warnings; doesn't display anything
            0: char_color = {XPos[2:0], YPos[2:0]};

            // First row of text
            //3: begin
				  1: begin
                char_color = 6'b101010;
                case (XPos[`log2NUM_COLS-1:6])
                    0:  char_selection = 6'd06; //F
                    1:  char_selection = 6'd12; //L
                    2:  char_selection = 6'd15; //O
                    3:  char_selection = 6'd01; //A
                    4:  char_selection = 6'd20; //T
                    5:  char_selection = 6'd09; //I
                    6:  char_selection = 6'd14; //N
                    7:  char_selection = 6'd07; //G

                    9:  char_selection = 6'd16; //P
                    10: char_selection = 6'd15; //O
                    11: char_selection = 6'd09; //I
                    12: char_selection = 6'd14; //N
                    13: char_selection = 6'd20; //T

                    15: char_selection = 6'd01; //A
                    16: char_selection = 6'd04; //D
                    17: char_selection = 6'd04; //D
                    18: char_selection = 6'd05; //E
                    19: char_selection = 6'd18; //R
                    default: char_selection = 6'b100000;
                endcase
            end

            // aIn
            //6: begin
				  3: begin
                if (XPos[`log2NUM_COLS-1:6] < 8)
                    char_color = 6'b001100;
                else if (!aIn[4])  // Not normalized
                    char_color = 6'b110000;
                else
                    char_color = 6'b111111;
                case (XPos[`log2NUM_COLS-1:6])
                    5:  char_selection = 6'd01; //A
                    6:  char_selection = 6'd09; //I
                    7:  char_selection = 6'd14; //N

                    9:  char_selection = 6'd48 | aIn[7];
                    10: char_selection = 6'd48 | aIn[6];
                    11: char_selection = 6'd48 | aIn[5];

                    13: char_selection = 6'd48 | aIn[4];
                    14: char_selection = 6'd48 | aIn[3];
                    15: char_selection = 6'd48 | aIn[2];
                    16: char_selection = 6'd48 | aIn[1];
                    17: char_selection = 6'd48 | aIn[0];

                    default: char_selection = 6'b100000;
                endcase
            end

            // bIn
            //8: begin
				  5: begin
                if (XPos[`log2NUM_COLS-1:6] < 8)
                    char_color = 6'b001100;
                else if (!bIn[4])  // Not normalized
                    char_color = 6'b110000;
                else
                    char_color = 6'b111111;
                case (XPos[`log2NUM_COLS-1:6])
                    3:  char_selection = 6'd43; //+

                    5:  char_selection = 6'd02; //B
                    6:  char_selection = 6'd09; //I
                    7:  char_selection = 6'd14; //N

                    9:  char_selection = 6'd48 | bIn[7];
                    10: char_selection = 6'd48 | bIn[6];
                    11: char_selection = 6'd48 | bIn[5];

                    13: char_selection = 6'd48 | bIn[4];
                    14: char_selection = 6'd48 | bIn[3];
                    15: char_selection = 6'd48 | bIn[2];
                    16: char_selection = 6'd48 | bIn[1];
                    17: char_selection = 6'd48 | bIn[0];

                    default: char_selection = 6'b100000;
                endcase
            end

            // Result
            //11: begin
					8: begin
                if (XPos[`log2NUM_COLS-1:6] < 8)
                    char_color = 6'b000011;
                else if (!result[4] || result < aIn || result < bIn)
                    // not normalized, or result is less than the inputs
                    char_color = 6'b110000;
                else if (&result)  // result is saturated
                    char_color = 6'b111100;
                else
                    char_color = 6'b111111;
                case (XPos[`log2NUM_COLS-1:6])
                    2:  char_selection = 6'd18; //R
                    3:  char_selection = 6'd05; //E
                    4:  char_selection = 6'd19; //S
                    5:  char_selection = 6'd21; //U
                    6:  char_selection = 6'd12; //L
                    7:  char_selection = 6'd20; //T

                    9:  char_selection = 6'd48 | result[7];
                    10: char_selection = 6'd48 | result[6];
                    11: char_selection = 6'd48 | result[5];

                    13: char_selection = 6'd48 | result[4];
                    14: char_selection = 6'd48 | result[3];
                    15: char_selection = 6'd48 | result[2];
                    16: char_selection = 6'd48 | result[1];
                    17: char_selection = 6'd48 | result[0];

                    default: char_selection = 6'b100000;
                endcase
            end
        endcase
    end

    // Add the addition horizontal line
    assign lineValid  = (XPos[`log2NUM_COLS-1:6] >=  2)
                     && (XPos[`log2NUM_COLS-1:6] <= 17)
                     && (YPos[`log2NUM_ROWS-1:4] == 28); //39

    // Register the output of the tcgrom
    tcgrom tcgrom(.addr({char_selection_q, YPos[5:3]}), .data(tcgrom_d));

    always @* begin     
        case (XPos[5:3])
            3'h0 : color = tcgrom_q[7];
            3'h1 : color = tcgrom_q[6];
            3'h2 : color = tcgrom_q[5];
            3'h3 : color = tcgrom_q[4];
            3'h4 : color = tcgrom_q[3];
            3'h5 : color = tcgrom_q[2];
            3'h6 : color = tcgrom_q[1];
            3'h7 : color = tcgrom_q[0];                            
        endcase 
    end  

    // Generates the RGB signals based on raster position
    assign vga_rgb = lineValid ? 6'b111111
                     : ((Valid && color) ? char_color_2_q : 6'b0);

    //For character display
    dff #(8) tcgrom_reg (.clk(clk), .d(tcgrom_d), .q(tcgrom_q));
    dff #(6) char_selection_reg (.clk(clk), .d(char_selection), .q(char_selection_q));
    dff #(6) char_color_reg (.clk(clk), .d(char_color), .q(char_color_q));
    dff #(6) char_color_2_reg (.clk(clk), .d(char_color_q), .q(char_color_2_q));

endmodule
