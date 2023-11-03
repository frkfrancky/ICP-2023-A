if(room != intro && room != video){
	draw_set_color(c_white);
	draw_set_alpha(1);
	if (room == r_menu3){
		//draw_text(16,16,"left_spr:"+string(mn[0].bt[mn[0].index_focused].left_spr));
	}
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	draw_text_transformed(room_width - 10,room_height-10,"pre-alpha version",0.5,0.5,1);
	draw_set_halign(fa_left);
	draw_text_transformed(20,20,string(room_get_name(room))+"; fps="+string(fps),0.5,0.5,1);
	/*if(os_type == os_windows){
		draw_set_halign(fa_left);
		draw_text_transformed(10,room_height-10,"windows "+string(room_height)+" "+string(os_device),0.5,0.5,1);
	}else if (os_type == os_android){
		draw_set_halign(fa_left);
		draw_text_transformed(10,room_height-10,"android "+string(os_version)+" "+string(os_device),0.5,0.5,1);
	}*/
	
	
	///TEXT SLIDING
	draw_set_alpha(0.7);
	draw_rectangle_color(0,room_height-70,room_width,room_height-10,c_black,c_black,c_black,c_black,false);
	//draw_rectangle_color(x_sliding,room_height-60,x_sliding+string_width(text_sliding),room_height-20,c_red,c_red,c_red,c_red,false);
	draw_set_alpha(1);
	
	
	
	/*if((x_sliding+string_width(text_sliding))<0 || (x_sliding<0 && x_sliding+string_width(text_sliding)<room_width )){
		x_sliding = room_width;
	}*/
	for (var i = 0; i < nbr_text; ++i) {
	    //if(is_go[i] == true){
			x_sliding[i] -= v_sliding;
		//}
		
		if(((x_sliding[i]+string_width(text_sliding[i])+slide_space<0))){

			if(i == 0){
				if((x_sliding[nbr_text-1]+string_width(text_sliding[nbr_text-1])) > room_width){
					x_sliding[i] =  x_sliding[nbr_text-1]+string_width(text_sliding[nbr_text-1])+slide_space;
				}else{
					x_sliding[i] = room_width+slide_space;
				}
				
			}else{
				x_sliding[i] =  x_sliding[i-1]+string_width(text_sliding[i-1])+slide_space;
			}
		}
		

		draw_set_alpha(0.2);
		draw_rectangle_color(x_sliding[i],room_height-60,x_sliding[i]+string_width(text_sliding[i])+50,room_height-20,slide_color,slide_color,slide_color,slide_color,false);
		draw_set_alpha(1);
		draw_text_transformed(x_sliding[i]+25,room_height-20,text_sliding[i],1,1,0);
	}
	

	

	if(room == r_menu4){

	}


}else if(room == intro){
	draw_set_color(c_black);
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_left);
	draw_set_font(my_font_big);
	draw_text_transformed(20,20,string(room_get_name(room))+"; fps="+string(fps),0.5,0.5,1);
}
