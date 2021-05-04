module piano_display(
   input [10:0] x,
	input [9:0] y,
	input [55:0] to_display,
	
	output white_key,
	output black_key,
	output play
);
	
	/* define some bit map variables */
	wire white_key_lower_y_dim = y > 920;
	wire white_key_upper_y_dim = 780 <= y & y <= 920;
	wire black_key_y_dim = 780 <= y & y <= 920;
	
	/* define all notes */
	wire [64:0] notes = {six_B, six_As, six_A, 
								five_Gs, five_G, five_Fs, five_F, five_E, five_Ds, five_D, five_Cs, five_C, five_B, five_As, five_A,
								four_Gs, four_G, four_Fs, four_F, four_E, four_Ds, four_D, four_Cs, four_C, four_B, four_As, four_A,
								three_Gs, three_G, three_Fs, three_F, three_E, three_Ds, three_D, three_Cs, three_C, three_B, three_As, three_A,
								two_Gs, two_G, two_Fs, two_F, two_E, two_Ds, two_D, two_Cs, two_C, two_B, two_As, two_A,
								one_Gs, one_G, one_Fs, one_F, one_E, one_Ds, one_D, one_Cs, one_C, one_B, one_As, one_A, 
								1'b0}; // this is needed to line up the indices
								
	wire one_A = ((11'd10 < x & x < 11'd44) & white_key_lower_y_dim) | ((11'd10 < x & x < 11'd32) & white_key_upper_y_dim);
	wire one_As = ((11'd32 < x & x < 11'd56) & black_key_y_dim);
	wire one_B = ((11'd44 < x & x < 11'd78) & white_key_lower_y_dim) | ((11'd56 < x & x < 11'd78) & white_key_upper_y_dim);
	wire one_C = ((11'd78 < x & x < 11'd112) & white_key_lower_y_dim) | ((11'd78 < x & x < 11'd100) & white_key_upper_y_dim);
	wire one_Cs = ((11'd100 < x & x < 11'd124) & black_key_y_dim);
	wire one_D = ((11'd112 < x & x < 11'd146) & white_key_lower_y_dim) | ((11'd124 < x & x < 11'd134) & white_key_upper_y_dim);
	wire one_Ds = ((11'd134 < x & x < 11'd158) & black_key_y_dim);
	wire one_E = ((11'd146 < x & x < 11'd180) & white_key_lower_y_dim) | ((11'd158 < x & x < 11'd180) & white_key_upper_y_dim);
	wire one_F = ((11'd180 < x & x < 11'd214) & white_key_lower_y_dim) | ((11'd180 < x & x < 11'd202) & white_key_upper_y_dim);
	wire one_Fs = ((11'd202 < x & x < 11'd226) & black_key_y_dim);
	wire one_G = ((11'd214 < x & x < 11'd248) & white_key_lower_y_dim) | ((11'd226 < x & x < 11'd236) & white_key_upper_y_dim);
	wire one_Gs =((11'd236 < x & x < 11'd260) & black_key_y_dim);
	
	wire two_A = ((11'd248 < x & x < 11'd282) & white_key_lower_y_dim) | ((11'd260 < x & x < 11'd270) & white_key_upper_y_dim);
	wire two_As = ((11'd270 < x & x < 11'd294) & black_key_y_dim);
	wire two_B = ((11'd282 < x & x < 11'd316) & white_key_lower_y_dim) | ((11'd294 < x & x < 11'd316) & white_key_upper_y_dim);
	wire two_C = ((11'd316 < x & x < 11'd350) & white_key_lower_y_dim) | ((11'd316 < x & x < 11'd338) & white_key_upper_y_dim);
	wire two_Cs = ((11'd338 < x & x < 11'd362) & black_key_y_dim);
	wire two_D = ((11'd350 < x & x < 11'd384) & white_key_lower_y_dim) | ((11'd362 < x & x < 11'd372) & white_key_upper_y_dim);
	wire two_Ds = ((11'd372 < x & x < 11'd396) & black_key_y_dim);
	wire two_E = ((11'd384 < x & x < 11'd418) & white_key_lower_y_dim) | ((11'd396 < x & x < 11'd418) & white_key_upper_y_dim);
	wire two_F = ((11'd418 < x & x < 11'd452) & white_key_lower_y_dim) | ((11'd418 < x & x < 11'd440) & white_key_upper_y_dim);
	wire two_Fs = ((11'd440 < x & x < 11'd464) & black_key_y_dim);
	wire two_G = ((11'd452 < x & x < 11'd486) & white_key_lower_y_dim) | ((11'd464 < x & x < 11'd474) & white_key_upper_y_dim);
	wire two_Gs = ((11'd474 < x & x < 11'd498) & black_key_y_dim);

	wire three_A = ((11'd486 < x & x < 11'd520) & white_key_lower_y_dim) | ((11'd498 < x & x < 11'd508) & white_key_upper_y_dim);
	wire three_As = ((11'd508 < x & x < 11'd532) & black_key_y_dim);
	wire three_B = ((11'd520 < x & x < 11'd554) & white_key_lower_y_dim) | ((11'd532 < x & x < 11'd554) & white_key_upper_y_dim);
	wire three_C = ((11'd554 < x & x < 11'd588) & white_key_lower_y_dim) | ((11'd554 < x & x < 11'd576) & white_key_upper_y_dim);
	wire three_Cs = ((11'd576 < x & x < 11'd600) & black_key_y_dim);
	wire three_D = ((11'd588 < x & x < 11'd622) & white_key_lower_y_dim) | ((11'd600 < x & x < 11'd610) & white_key_upper_y_dim);
	wire three_Ds = ((11'd610 < x & x < 11'd634) & black_key_y_dim);
	wire three_E = ((11'd622 < x & x < 11'd656) & white_key_lower_y_dim) | ((11'd634 < x & x < 11'd656) & white_key_upper_y_dim);
	wire three_F = ((11'd656 < x & x < 11'd690) & white_key_lower_y_dim) | ((11'd656 < x & x < 11'd678) & white_key_upper_y_dim);
	wire three_Fs = ((11'd678 < x & x < 11'd702) & black_key_y_dim);
	wire three_G = ((11'd690 < x & x < 11'd724) & white_key_lower_y_dim) | ((11'd702 < x & x < 11'd712) & white_key_upper_y_dim);
	wire three_Gs = ((11'd712 < x & x < 11'd736) & black_key_y_dim);

	wire four_A = ((11'd724 < x & x < 11'd758) & white_key_lower_y_dim) | ((11'd736 < x & x < 11'd746) & white_key_upper_y_dim);
	wire four_As = ((11'd746 < x & x < 11'd770) & black_key_y_dim);
	wire four_B = ((11'd758 < x & x < 11'd792) & white_key_lower_y_dim) | ((11'd770 < x & x < 11'd792) & white_key_upper_y_dim);
	wire four_C = ((11'd792 < x & x < 11'd826) & white_key_lower_y_dim) | ((11'd792 < x & x < 11'd814) & white_key_upper_y_dim);
	wire four_Cs = ((11'd814 < x & x < 11'd838) & black_key_y_dim);
	wire four_D = ((11'd826 < x & x < 11'd860) & white_key_lower_y_dim) | ((11'd838 < x & x < 11'd848) & white_key_upper_y_dim);
	wire four_Ds = ((11'd848 < x & x < 11'd872) & black_key_y_dim);
	wire four_E = ((11'd860 < x & x < 11'd894) & white_key_lower_y_dim) | ((11'd872 < x & x < 11'd894) & white_key_upper_y_dim);
	wire four_F = ((11'd894 < x & x < 11'd928) & white_key_lower_y_dim) | ((11'd894 < x & x < 11'd916) & white_key_upper_y_dim);
	wire four_Fs = ((11'd916 < x & x < 11'd940) & black_key_y_dim);
	wire four_G = ((11'd928 < x & x < 11'd962) & white_key_lower_y_dim) | ((11'd940 < x & x < 11'd950) & white_key_upper_y_dim);
	wire four_Gs = ((11'd950 < x & x < 11'd974) & black_key_y_dim);

	wire five_A = ((11'd962 < x & x < 11'd996) & white_key_lower_y_dim) | ((11'd974 < x & x < 11'd984) & white_key_upper_y_dim);
	wire five_As = ((11'd984 < x & x < 11'd1008) & black_key_y_dim);
	wire five_B = ((11'd996 < x & x < 11'd1030) & white_key_lower_y_dim) | ((11'd1008 < x & x < 11'd1030) & white_key_upper_y_dim);
	wire five_C = ((11'd1030 < x & x < 11'd1064) & white_key_lower_y_dim) | ((11'd1030 < x & x < 11'd1052) & white_key_upper_y_dim);
	wire five_Cs = ((11'd1052 < x & x < 11'd1076) & black_key_y_dim);
	wire five_D = ((11'd1064 < x & x < 11'd1098) & white_key_lower_y_dim) | ((11'd1076 < x & x < 11'd1086) & white_key_upper_y_dim);
	wire five_Ds = ((11'd1086 < x & x < 11'd1110) & black_key_y_dim);
	wire five_E = ((11'd1098 < x & x < 11'd1132) & white_key_lower_y_dim) | ((11'd1110 < x & x < 11'd1132) & white_key_upper_y_dim);
	wire five_F = ((11'd1132 < x & x < 11'd1166) & white_key_lower_y_dim) | ((11'd1132 < x & x < 11'd1154) & white_key_upper_y_dim);
	wire five_Fs = ((11'd1154 < x & x < 11'd1178) & black_key_y_dim);
	wire five_G = ((11'd1166 < x & x < 11'd1200) & white_key_lower_y_dim) | ((11'd1178 < x & x < 11'd1188) & white_key_upper_y_dim);
	wire five_Gs = ((11'd1188 < x & x < 11'd1212) & black_key_y_dim);

	wire six_A = ((11'd1200 < x & x < 11'd1234) & white_key_lower_y_dim) | ((11'd1212 < x & x < 11'd1222) & white_key_upper_y_dim);
	wire six_As = ((11'd1222 < x & x < 11'd1246) & black_key_y_dim);
	wire six_B = ((11'd1234 < x & x < 11'd1268) & white_key_lower_y_dim) | ((11'd1246 < x & x < 11'd1268) & white_key_upper_y_dim);	
	
	/* define white/black notes */
	assign white_key = 	one_A | one_B | one_C | one_D | one_E | one_F | one_G |
								two_A | two_B | two_C | two_D | two_E | two_F | two_G |
								three_A | three_B | three_C | three_D | three_E | three_F | three_G |
								four_A | four_B | four_C | four_D | four_E | four_F | four_G |
								five_A | five_B | five_C | five_D | five_E | five_F | five_G |
								six_A | six_B;
							
	assign black_key = 	one_As | one_Cs | one_Ds | one_Fs | one_Gs |
								two_As | two_Cs | two_Ds | two_Fs | two_Gs |
								three_As | three_Cs | three_Ds | three_Fs | three_Gs |
								four_As | four_Cs | four_Ds | four_Fs | four_Gs |
								five_As | five_Cs | five_Ds | five_Fs | five_Gs |
								six_As;
	
	/* -----------------------------------------------------------------------------
		Dynamic Notes Display Control
	----------------------------------------------------------------------------- */
	
	wire [5:0] note_to_display_1 = to_display[54:49]; // 	|samples = 55
	wire sample_live_1 = to_display[55];
	wire [5:0] note_to_display_2 = to_display[47:42]; // 48
	wire sample_live_2 = to_display[48];
	wire [5:0] note_to_display_3 = to_display[40:35]; // 41
	wire sample_live_3 = to_display[41];
	wire [5:0] note_to_display_4 = to_display[33:28]; // 34
	wire sample_live_4 = to_display[34];
	wire [5:0] note_to_display_5 = to_display[26:21]; // 27
	wire sample_live_5 = to_display[27];
	wire [5:0] note_to_display_6 = to_display[19:14]; // 20
	wire sample_live_6 = to_display[20];
	wire [5:0] note_to_display_7 = to_display[12:7]; // 13
	wire sample_live_7 = to_display[13];
	wire [5:0] note_to_display_8 = to_display[5:0]; // 6
	wire sample_live_8 = to_display[6];

	
	assign play = 	(notes[note_to_display_1] & sample_live_1) |
						(notes[note_to_display_2] & sample_live_2) |
						(notes[note_to_display_3] & sample_live_3) |
						(notes[note_to_display_4] & sample_live_4) |
						(notes[note_to_display_5] & sample_live_5) |
						(notes[note_to_display_6] & sample_live_6) |
						(notes[note_to_display_7] & sample_live_7) |
						(notes[note_to_display_8] & sample_live_8);

endmodule
