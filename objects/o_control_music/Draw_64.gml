	// AUDIO TEST
	
	if(is_display){
		
	draw_set_alpha(0.8);
	draw_rectangle_color(xx1,yy1,xx2,yy2,c_white,c_white,c_white,c_white,false);
	draw_set_alpha(1);
	
	draw_set_color(c_gray);
	draw_set_valign(fa_top);
	draw_set_halign(fa_right)
	var padding = 8;
	draw_set_font(music_titre);
	draw_text(xx2-padding, yy1+8+padding, titre_mosika);
	;
	draw_set_font(music_artist);
	draw_text(xx2-padding, yy1+32+padding, artiste_mosika);
	
	//draw_text(room_width - 50, room_height - 80, string(audio_sound_length(mosika)));

	var prog_sound = (audio_sound_get_track_position(mosika)*(xx2-xx1-2*plus))/audio_sound_length(mosika);
	var rep_x = 0;
	var rep_y = -8;
	
	draw_rectangle(rep_x+xx1+plus,rep_y+yy2-16, rep_x+xx2-plus, rep_y+yy2-plus,true);
	draw_rectangle(rep_x+xx1+plus,rep_y+yy2-16, rep_x+xx1+plus+prog_sound, rep_y+yy2-plus,false);
	
	//réinitialisation des parametres
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_center);
	draw_set_font(my_font_big);
	}
	
