draw_self();

if(is_select == true){
	draw_set_color($5EDB67);
	draw_set_alpha(0.5);
	draw_rectangle(x,y,x+sprite_width,y+sprite_height,false);
	draw_set_alpha(10);
	draw_set_color(c_white);
}

draw_set_font(my_font_big);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text_color(x+96,y+16,anarana,c_white,c_white,c_white,c_white,image_alpha);



if(is_focus == true && image_alpha >= 0.5){
	draw_rectangle(x,y,x+sprite_width,y+sprite_height,true);
}


if(is_array(data)){
	if(mini_id > 0 && mini_id <= 5){
		image_index = 1;
	}
	draw_text_color(x+16,y+16,data[7],c_white,c_white,c_white,c_white,image_alpha);
	var somme = int64(data[1])+int64(data[2])+int64(data[3])+int64(data[4])+int64(data[5]);
	draw_text_color(x+sprite_width-48,y+16,string(somme),c_black,c_black,c_black,c_black,image_alpha);
}
if(mini_id == 0){
	image_index = 2;
}

if(room == r_menu4){
	
}
