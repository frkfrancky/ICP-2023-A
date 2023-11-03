if(anim_start){
	for (var i = 0; i < array_length_1d(bt); ++i) {
		bt[i].y =  y+0+(i*58);
		bt[i].image_alpha = image_alpha;
	}
	glisser_fondu(136+32);
	
	//anim_start = false;
}

if(is_array(bt)){
	for (var i = 0; i < array_length_1d(bt); ++i) {
	    bt[i].y = bt[0].y+(i*58);
	}
}

if(array_length_1d(bt) > 5){
	for (var i = 0; i < array_length_1d(bt); ++i) {
		if(((bt[i].y - (y+sprite_height-50)) >= 0) || ((bt[i].y - y) < 0)){
			bt[i].visible = false;
			bt[i].x = -1000;
		}else{
			bt[i].visible = true;
			bt[i].x = x+8;
		}
	}
	if((bt[0].y - y)  > 48){
		bt[0].y = y+16;
	}
	if((bt[array_length_1d(bt)-1].y - y)  < 48){
		bt[0].y = y+48+(-58*(array_length_1d(bt)-1));
	}
}

if((touche_haut_menu() || enfonce_haut == true) && is_focus && index_focused>=0){
	if(index_focused == 0){
		if(array_length_1d(bt) > 6){
			bt[index_focused].is_focus = false;
			index_focused = array_length_1d(bt)-1;
			bt[0].y = y+16+(-58*(index_focused+1));
		}else{
			bt[index_focused].is_focus = false;
			index_focused = array_length_1d(bt)-1;
		}
	}else if(bt[index_focused].is_focus && bt[index_focused-1].y<y){
		bt[0].y = y+16+(-58*(index_focused-1));//TEST DE LA PREMIERE ELEMENT DU TABLEAU
		bt[index_focused].is_focus = false;
		index_focused -= 1;
	}else{
		bt[index_focused].is_focus = false;
		index_focused -= 1;
	}
	
}
if((touche_bas_menu() || enfonce_bas == true) && is_focus && index_focused<(array_length_1d(bt))){
	if(index_focused == (array_length_1d(bt)-1)){//FIN DU TABLEAU RESET INDEX
		if(array_length_1d(bt) > 6){
			bt[index_focused].is_focus = false;
			index_focused = 0;
			bt[0].y = y+16+(-58*(index_focused-1));
		}else{
			bt[index_focused].is_focus = false;
			index_focused = 0;
		}
	}else if(bt[index_focused].is_focus && bt[index_focused+1].visible==false){
		bt[0].y = y+16+(-58*(index_focused+1));//TEST DE LA DERNIERE ELEMENT DU TABLEAU
		bt[index_focused].is_focus = false;
		index_focused += 1;
	}else{
		bt[index_focused].is_focus = false;
		index_focused += 1;
	}
}
if(touche_enter_menu() && is_focus){
	alarm_set(1,1);
}
if(touche_back_menu() && is_focus){
	if(index_selected > 0){
		bt[index_selected].is_select = false;
		index_selected = -1;
		if(mini_id == 0){
			o_control_menu.mn[2].data2 = 0;
		}else if(mini_id == 1){
			o_control_menu.mn[3].data2 = 0;
		}
	}else if(index_focused == 0){
		//show_message("quitter?");
		o_control_menu.mn[0].is_focus = false;
		o_control_menu.mn[1].is_focus = false;
		mss = instance_create_depth(room_width/2,room_height/2+40,-100,confirm);
		mss.mpamorona = id;
	}else{
		bt[index_focused].is_focus = false;
		index_focused = 0;
		bt[0].y = y+16+(-58*(index_focused-1));
	}
}

if(is_array(bt)){
	bt[index_focused].is_focus = true;
	if(index_focused != 0){
		if(mini_id == 0){
			o_control_menu.mn[2].data = bt[index_focused].data;
		}else if(mini_id == 1){
			o_control_menu.mn[3].data = bt[index_focused].data;
		}
	}else{
		if(mini_id == 0){
			o_control_menu.mn[2].data = 0;
		}else if(mini_id == 1){
			o_control_menu.mn[3].data = 0;
		}
	}
}


//TOUCHES ENFONCEES ///////////////////////////
if(touche_bas2() == true && time_presse <= 30){
	if(time_presse<30){
		time_presse += 1;
	}else{
		if(espacement<7){
			enfonce_bas = false;
			espacement += 1;
		}else{
			espacement = 0;
			enfonce_bas = true;
		}
	}
}else{
	time_presse = 0;
	espacement = 0;
	enfonce_bas = false;
}

if(touche_haut2() == true && time_presse2 <= 30){
	if(time_presse2<30){
		time_presse2 += 1;
	}else{
		if(espacement2<7){
			enfonce_haut = false;
			espacement2 += 1;
		}else{
			espacement2 = 0;
			enfonce_haut = true;
		}
	}
}else{
	time_presse2 = 0;
	espacement2 = 0;
	enfonce_haut = false;
}
////////////////////////////////////////////////
glisser(0)
