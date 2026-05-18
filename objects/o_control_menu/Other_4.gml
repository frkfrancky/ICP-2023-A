if(room == r_menu1 || room == r_menu2){
	can_press = true;
	mn[0] = instance_create_depth(48+refmenu_x,132+refmenu_y,-5,o_sous_menu);
}else if(room == r_menu3){
	can_press = true;
	xx = 128;
	yyy = 32;
	mn[0] = instance_create_depth(48+xx,236+yyy,-5,o_sous_menu); mn[0].sprite_index = s_back4; mn[0].mini_id = 0;
	mn[1] = instance_create_depth(528+xx,236+yyy,-5,o_sous_menu); mn[1].sprite_index = s_back4; mn[1].mini_id = 1;
	
	yy = -10000;
	mn[4] = instance_create_depth(48+yy+xx,136+yyy,-5,o_sous_menu); mn[4].sprite_index = s_back4;mn[4].mini_id = 4;
	mn[5] = instance_create_depth(528+yy+xx,136+yyy,-5,o_sous_menu); mn[5].sprite_index = s_back4;mn[5].mini_id = 5;
	
	if(global.playerNumber == 1){
		mn[0].is_focus = true;
		mn[1].is_focus = false;
		mn[4].is_focus = false;
		mn[5].is_focus = false;
	}else if (global.playerNumber == 2){
		mn[0].is_focus = true;
		mn[1].is_focus = true;
		mn[4].is_focus = false;
		mn[5].is_focus = false;
	}
	
	//indicateur de l'equipe
	mn[2] = instance_create_depth(-52+xx,8+yyy,-5,o_sous_menu3);mn[2].mini_id = 2;
	mn[3] = instance_create_depth(628+xx,8+yyy,-5,o_sous_menu3);mn[3].mini_id = 3;
	
	//bouton retour
	bt = instance_create_depth(32,512+64,-6,o_bt2);
}else if(room == r_menu4){
	can_press = false;
	mess = instance_create_depth((room_width/2),(room_height/2)+30,-100,alert);
	//mess.image_alpha = alpha;

	initialisation_menu4();
}else if(room == r_menu5){
	can_press = true;
	mn[0] = instance_create_depth(48+refmenu_x, 132+refmenu_y, -5, o_sous_menu);
}else if(room == r_outils){
	can_press = true;
	mn[0] = instance_create_depth(48+refmenu_x, 132+refmenu_y, -5, o_sous_menu);
}else if(room == titre){
	music = instance_create_depth(room_width, room_height, -10,o_control_music);
}

