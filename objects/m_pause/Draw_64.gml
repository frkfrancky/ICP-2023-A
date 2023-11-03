/// @description Insérez la description ici
// Vous pouvez écrire votre code dans cet éditeur

	if(load == true){
		swal();
	}

	draw_self();
	draw_set_color($4C4C4C);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);
	draw_set_alpha(alpha2);
	draw_text_transformed(x,y-48,"Pause",0.75,0.75,0);
	
	if(image_alpha == 0 && sens == -1 ){
		mpamorona.menu_p = 0;
		mpamorona.create_pause = false;
		instance_destroy(self);
	}
	
	image_alpha = alpha2;
	if(load == false){
		o_control_menu.can_press = true;
		instance_destroy(self);
	}

/*
	if(is_array(bt)){
	bt[0].y = y+(sprite_height/2)-50;
	bt[1].y = y+(sprite_height/2)-50;
	}*/





