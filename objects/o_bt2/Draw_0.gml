draw_self();

draw_set_font(my_font_big);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if(room == r_menu3 || room == r_menu4){
	draw_text(x+16,y+13,"<  Back");
}else if (room == r_terrain){
	x=o_ombre_ballon.x-400;
	y=o_ombre_ballon.y+180;
	draw_text(x+16,y+13,"Menu");
}


if(is_focus == true){
	draw_rectangle(x,y,x+sprite_width,y+sprite_height,true);
}
