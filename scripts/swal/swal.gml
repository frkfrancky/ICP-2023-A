function swal() {
	//mess.image_alpha = alpha;
	draw_set_alpha(alpha);
	draw_set_color(c_black);
	draw_rectangle(0,0,room_width,room_height,false);

	if(alpha < 0.625 || sens < 0){
		alpha = alpha + 0.05 * sens;
	}
	if(alpha2 < 1 || sens < 0){
		alpha2 = alpha2 + 0.1 * sens;
		y = y - 5 * sens;
	}
	if(sens == -1 && alpha <= 0){
		load = false;
	}



}
