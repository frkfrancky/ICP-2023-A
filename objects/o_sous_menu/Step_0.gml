if(room == r_menu3){
	initialisation_menu3();
}

if(anim_start == true){
	if(room == r_menu1){
		for (var i = 0; i < 6; ++i) {
		    bt[i].y =  y+0+(i*96);
			bt[i].image_alpha = image_alpha;
		}
		glisser_fondu(48);
		
	}else if (room == r_menu2){
		for (var i = 0; i < 3; ++i) {
		    bt[i].y =  y+0+(i*96);
			bt[i].image_alpha = image_alpha;
		}
		glisser_fondu(32);
	}else if (room == r_menu3 && (mini_id == 1 || mini_id == 0)){
		for (var i = 0; i < get_count_categorie(); ++i) {
		    bt[i].y =  y-8+(i*72);
			bt[i].image_alpha = image_alpha;
		}

		glisser_fondu(136+48);
	}
}
//// REPOSITION DE CHAQUE BOUTON PAR RAPPORT A BT ZERO
if(room != r_menu3){
	if(is_array(bt)){
		for (var i = 0; i < array_length_1d(bt); ++i) {
		    bt[i].y = bt[0].y+(i*96);
		}
	}
}else{
	for (var i = 0; i < array_length_1d(bt); ++i) {
		if(i!=0){
			bt[i].y = bt[0].y+(i*72);
		}
	}	
}
//////////////////////////////////////////////////////////


///LIMITATION DES BOUTONS EN CAS DE FIN DU TABLEAU OU DEBUT
if(array_length_1d(bt) > 5 && is_focus){
	for (var i = 0; i < array_length_1d(bt); ++i) {
	    if(((bt[i].y - (y+sprite_height-63)) >= 0) || ((bt[i].y - y) < 0)){
			bt[i].visible = false;
			bt[i].x = -1000;
		}else{
			bt[i].visible = true;
			bt[i].x = x+16;
		}
	}
	
	if((bt[0].y - y)  > 48){
		bt[0].y = y+48;
	}
	
	if(room != r_menu3){		
		if((bt[array_length_1d(bt)-1].y - y)  < 48){
			bt[0].y = y+48+(-96*(array_length_1d(bt)-1));
		}
	}else{
		if((bt[array_length_1d(bt)-1].y - y)  < 48){
			bt[0].y = y+48+(-72*(array_length_1d(bt)-1));
		}
	}
}
////////////////////////////////////////////////

	bt[index_focused].is_focus = true;


	if((touche_haut_menu() || enfonce_haut == true) && is_focus && index_focused>=0){
		if(room != r_menu3){
			if(index_focused == 0){
				bt[index_focused].is_focus = false;
				index_focused = array_length_1d(bt)-1;
				//bt[0].y = y+16+(-96*(index_focused+1));
			}else if(bt[index_focused].is_focus && bt[index_focused-1].y<y && index_focused != 0){
				bt[0].y = y+16+(-96*(index_focused-1));
				bt[index_focused].is_focus = false;
				index_focused -= 1;
			}else{
				bt[index_focused].is_focus = false;
				index_focused -= 1;
			}
	
		}else if (room == r_menu3 && is_ready == false){
			if(index_focused == 0){
				
				if(array_length_1d(bt) > 5){
					bt[index_focused].is_focus = false;
					index_focused = array_length_1d(bt)-1;
					bt[0].y = y+16+(-72*(index_focused+1));
				}else{
					bt[index_focused].is_focus = false;
					index_focused = array_length_1d(bt)-1;
				}
				
			}else if(bt[index_focused].is_focus && bt[index_focused-1].y<y){
				bt[0].y = y+16+(-72*(index_focused-1));
				bt[index_focused].is_focus = false;
				index_focused -= 1;
			}else{
				bt[index_focused].is_focus = false;
				index_focused -= 1;
			}
			if(mini_id == 4){
				var nomm = bt[index_focused].soratra;
				var minieq = get_team_by_name_and_cate(nomm, global.cat1);
				o_control_menu.mn[2].afficher = minieq;
				o_control_menu.mn[2].text = nomm;
			}
			if(mini_id == 5){
				var nomm = bt[index_focused].soratra;
				var minieq = get_team_by_name_and_cate(nomm, global.cat2);
				o_control_menu.mn[3].afficher = minieq;
				o_control_menu.mn[3].text = nomm;
			}
			
		}
		
		
	}
	
	if((touche_bas_menu() || enfonce_bas == true) && is_focus && index_focused<(array_length_1d(bt))){
		if(room != r_menu3){
			if(index_focused == (array_length_1d(bt)-1)){
				bt[index_focused].is_focus = false;
				index_focused = 0;
			}else if(bt[index_focused].is_focus && bt[index_focused+1].visible==false){
				bt[0].y = y+16+(-96*(index_focused+1));//TEST DE LA DERNIERE ELEMENT DU TABLEAU
				bt[index_focused].is_focus = false;
				index_focused += 1;
			}else{
				bt[index_focused].is_focus = false;
				index_focused += 1;
			}
			
		}else if (room == r_menu3 && is_ready == false){
			if(index_focused == (array_length_1d(bt)-1)){//FIN DU TABLEAU RESET INDEX
				if(array_length_1d(bt) > 5){
					bt[index_focused].is_focus = false;
					index_focused = 0;
					bt[0].y = y+16+(-72*(index_focused-1));
				}else{
					bt[index_focused].is_focus = false;
					index_focused = 0;
				}
			}else if(bt[index_focused].is_focus && bt[index_focused+1].visible==false){
				bt[0].y = y+16+(-72*(index_focused+1));//TEST DE LA DERNIERE ELEMENT DU TABLEAU
				bt[index_focused].is_focus = false;
				index_focused += 1;
			}else{
				bt[index_focused].is_focus = false;
				index_focused += 1;
			}


			if(mini_id == 4){
				var nomm = bt[index_focused].soratra;
				var minieq = get_team_by_name_and_cate(nomm, global.cat1);
				o_control_menu.mn[2].afficher = minieq;
				o_control_menu.mn[2].text = nomm;
			}
			if(mini_id == 5){
				var nomm = bt[index_focused].soratra;
				var minieq = get_team_by_name_and_cate(nomm, global.cat2);
				o_control_menu.mn[3].afficher = minieq;
				o_control_menu.mn[3].text = nomm;
			}
		}
		
	}
	
	
	
	if(touche_back_menu() && is_focus && index_focused<(array_length_1d(bt))){
		if(room == r_menu2){
			room_goto(r_menu1);
		}
		if(room == r_menu3){
			if(global.playerNumber == 1){
				if(o_control_menu.mn[0].is_focus == true){
					room_goto(r_menu2);
				}else if (o_control_menu.mn[4].is_focus == true){
					
					//NIVOA////////////////////////
					o_control_menu.mn[4].visible = false;
					o_control_menu.mn[4].x += 10000;
					///////////////////////////////
					
					is_focus = false;
					o_control_menu.mn[0].is_focus = true;
					o_control_menu.mn[0].visible = true;
					o_control_menu.mn[0].x = 48+128;
					
					for (var i = 0; i < array_length_1d(o_control_menu.mn[0].bt); ++i) {
						 o_control_menu.mn[0].bt[i].x = 48+16+128;
					}
					for (var i = 0; i < array_length_1d(o_control_menu.mn[4].bt); ++i) {
						 o_control_menu.mn[4].bt[i].x = 10000;
					}
					is_ready = false;
					
				}else if (o_control_menu.mn[1].is_focus == true) {
					o_control_menu.mn[4].is_focus = true;
					o_control_menu.mn[1].is_focus = false;
					//is_set1 = false;
					//show_message("2");
				}else if(o_control_menu.mn[5].is_focus == true){
					o_control_menu.mn[1].is_focus = true;
					
					o_control_menu.mn[5].visible = false;
					
					o_control_menu.mn[5].is_focus = false;
					o_control_menu.mn[5].x += 10000;
					o_control_menu.mn[1].x = 528+128;
					o_control_menu.mn[1].visible = true;
					//o_control_menu.mn[0].bt[0].x = 528+16;
					for (var i = 0; i < array_length_1d(o_control_menu.mn[1].bt); ++i) {
						 o_control_menu.mn[1].bt[i].x = 528+16+128;
					}
					
					for (var i = 0; i < array_length_1d(o_control_menu.mn[5].bt); ++i) {
						 o_control_menu.mn[5].bt[i].x = 10000;
					}
					is_ready = false;
				}
			}else if(global.playerNumber == 2){
				if(mini_id == 4 && o_control_menu.mn[4].is_focus == true){
					x += 10000;
					o_control_menu.mn[4].is_focus = false;
					o_control_menu.mn[0].is_focus = true;
					o_control_menu.mn[0].visible = true;
					o_control_menu.mn[0].x = 48+128;
					//o_control_menu.mn[0].bt[0].x = 48+16;
					for (var i = 0; i < array_length_1d(o_control_menu.mn[0].bt); ++i) {
						 o_control_menu.mn[0].bt[i].x = 48+16+128;
					}
					
					for (var i = 0; i < array_length_1d(o_control_menu.mn[4].bt); ++i) {
						 o_control_menu.mn[4].bt[i].x = 10000;
					}
					is_ready = false;
					//show_message("4 to 0");
				}else if(mini_id == 5 && o_control_menu.mn[5].is_focus == true){
					x += 10000;
					o_control_menu.mn[5].is_focus = false;
					o_control_menu.mn[1].is_focus = true;
					o_control_menu.mn[1].visible = true;
					o_control_menu.mn[1].x = 528+128;
					//o_control_menu.mn[0].bt[0].x = 528+16;
					for (var i = 0; i < array_length_1d(o_control_menu.mn[1].bt); ++i) {
						 o_control_menu.mn[1].bt[i].x = 528+16+128;
					}
					
					for (var i = 0; i < array_length_1d(o_control_menu.mn[5].bt); ++i) {
						 o_control_menu.mn[5].bt[i].x = 10000;
					}
					is_ready = false;
					//show_message("5 to 1");
				}else if(o_control_menu.mn[1].is_focus == true && o_control_menu.mn[0].is_focus == true){
					
					room_goto(r_menu2);
				}
			}
		}
	}


for (var i = 0; i < array_length_1d(bt); ++i) {
    if((bt[i].image_index == 1 or (i==index_focused && touche_enter_menu())) && can_press == true){
		if(room == r_menu1){
			if(bt[i].mini_id==0){
				room_goto(r_menu2);
			}
			if(bt[i].mini_id==1){
				room_goto(r_terrain);
			}
			if(bt[i].mini_id==3){
				//room_goto(intro);
				game_restart();
			}
			if(bt[i].mini_id==4){
				room_goto(test);
			}
		}
		if(room == r_menu2){
			if(bt[i].mini_id==0){
				global.playerNumber = 1;
				room_goto(r_menu3);
			}
			if(bt[i].mini_id==1){
				global.playerNumber = 2;
				room_goto(r_menu3);				
			}
			if(bt[i].mini_id==2){
				room_goto(r_menu1);
			}
		}
		if(room == r_menu3){
			//player 1
			
			if(global.playerNumber == 1){
				if(mini_id == 0 || mini_id == 1){
					//is_focus = false;
					if(mini_id == 0 && (o_control_menu.mn[0].is_focus == true)){
						alarm_set(1, 1);
					}else if(mini_id == 1 && (o_control_menu.mn[1].is_focus == true)){
						alarm_set(1, 1);
					}
					
				}else if(mini_id == 4 || mini_id == 5){
					if(mini_id == 4 && (o_control_menu.mn[4].is_focus == true)){
						alarm_set(1, 1);
					}else if(mini_id == 5 && (o_control_menu.mn[5].is_focus == true)){
						alarm_set(1, 1);
					}
					
				}
				
			}
			
			
			//////////////
			if(global.playerNumber == 2){
				if(mini_id == 0 || mini_id == 1){
					//is_focus = false;
					if(mini_id == 0 && (o_control_menu.mn[0].is_focus == true)){
						alarm_set(1,1);
						
					}else if(mini_id == 1 && (o_control_menu.mn[1].is_focus == true)){
						alarm_set(1,1);
					}

				}else if (mini_id == 4 || mini_id == 5){
					if(mini_id == 4 && (o_control_menu.mn[4].is_focus == true)){
						//global.equipe1 = index_focused;
						alarm_set(1,1);
					}else if(mini_id == 5 && (o_control_menu.mn[5].is_focus == true)){
						//global.equipe2 = index_focused;
						alarm_set(1,1);
					}
					
				}
			}
		}

		
	}
}

if(room == r_menu3 && o_control_menu.mn[4].is_ready == true && o_control_menu.mn[5].is_ready == true){
	room_goto(r_menu4);
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


glisser(0);
