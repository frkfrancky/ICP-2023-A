draw_self();

draw_set_font(my_font_big);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if(room != r_menu3){
	
	draw_text_color(x+x_soratra,y+16,soratra,c_white,c_white,c_white,c_white,image_alpha);
}else{
	if(icon == 0){		
		draw_text(x+16,y+16,soratra);
	}else{
		//draw_sprite_part_ext(bt[i].mini_log,0,bt[i].left_spr,bt[i].top_spr,128,128,bt[i].x+16,bt[i].y,0.5,0.5,-1,1);
		draw_sprite_ext(icon,0,x+16,y,0.5,0.5,0,-1,1);
		draw_text(x+128,y+16,soratra);
	}
}

if(is_focus == true){
	if(room != r_menu3){
		x_soratra = 50;
	}
	
	for (var i = 0; i < 4; ++i) {
	    draw_rectangle(x+i,y+i,x+sprite_width-i,y+sprite_height-i,true);
	}

}else{
	if(room != r_menu3){
		x_soratra = 16;
	}
}
