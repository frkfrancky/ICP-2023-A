if(room == test){
	draw_self();

	draw_set_font(my_font_big);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);

	if(room == r_menu4){
		if(image_index == 0){
			draw_set_color(c_white);
		}else if(image_index == 1){
			draw_set_color($4C4C4C);
		}
		draw_text_transformed(x+(sprite_width/2),y+13,soratra,0.75,0.75,0);
	}

	if(is_focus == true){
		draw_rectangle(x,y,x+sprite_width,y+sprite_height,true);
	}
}
