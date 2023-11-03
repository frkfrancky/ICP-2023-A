//TOUCHE ENTRER MENU 3 DECALAGE 1 STEEP

if(global.playerNumber == 1){
	if(mini_id == 0 || mini_id == 1){
		if(mini_id == 0 && (o_control_menu.mn[0].is_focus == true)){
	
			o_control_menu.mn[4].is_focus = true;
			o_control_menu.mn[4].visible = true;
			o_control_menu.mn[4].x = 48+128;
			o_control_menu.mn[0].is_focus = false;
			o_control_menu.mn[0].visible = false;
			
			o_control_menu.mn[0].x += 0+128;
			for (var i = 0; i < array_length_1d(o_control_menu.mn[0].bt); ++i) {
				o_control_menu.mn[0].bt[i].x += 10000;
			}
			var nomcat = o_control_menu.mn[0].bt[index_focused].soratra;
			global.cat1 = get_id_categorie_by_name(nomcat);
			reload_equipe();
						
		}else if(mini_id == 1 && (o_control_menu.mn[1].is_focus == true)){
			o_control_menu.mn[5].is_focus = true;
			o_control_menu.mn[5].visible = true;
			o_control_menu.mn[5].x = 528+128;
			o_control_menu.mn[1].is_focus = false;
			o_control_menu.mn[1].visible = false;
			
			o_control_menu.mn[1].x += 0+128;
			for (var i = 0; i < array_length_1d(o_control_menu.mn[1].bt); ++i) {
				o_control_menu.mn[1].bt[i].x += 10000;
			}
			var nomcat = o_control_menu.mn[1].bt[index_focused].soratra;
			global.cat2 = get_id_categorie_by_name(nomcat);
			reload_equipe();
		}
	}else if(mini_id == 4 || mini_id == 5){
		if(mini_id == 4 && (o_control_menu.mn[4].is_focus == true)){
			o_control_menu.mn[1].is_focus = true;
			o_control_menu.mn[4].is_focus = false;
			
			is_set1 = true;
			is_ready = true;
			var nomeq = string(o_control_menu.mn[4].bt[index_focused].soratra);
			global.equipe1 = get_id_by_name_and_cate(nomeq,global.cat1);
			
		}else if(mini_id == 5 && (o_control_menu.mn[5].is_focus == true)){
			is_set2 = true;
			var nomeq = string(o_control_menu.mn[5].bt[index_focused].soratra);
			global.equipe2 = get_id_by_name_and_cate(nomeq,global.cat2);
			//show_message(string(global.equipe2));
			is_ready = true;
			//room_goto(r_menu4);
		}
	}
}
//TOUCHE ENTRER MENU 3 DECALAGE 1 STEEP

if(global.playerNumber == 2){
	if(mini_id == 0 || mini_id == 1){
		if(mini_id == 0 && (o_control_menu.mn[0].is_focus == true)){
			o_control_menu.mn[4].is_focus = true;
			o_control_menu.mn[4].visible = true;
			o_control_menu.mn[4].x = 48+128;
						
			o_control_menu.mn[0].is_focus = false;
			o_control_menu.mn[0].visible = false;
			
			//x += 1000;
			for (var i = 0; i < array_length_1d(bt); ++i) {
				bt[i].x += 10000;
			}
			var nomcat = o_control_menu.mn[0].bt[index_focused].soratra;
			global.cat1 = get_id_categorie_by_name(nomcat);
			reload_equipe();
			
						
		}else if(mini_id == 1 && (o_control_menu.mn[1].is_focus == true)){
			o_control_menu.mn[5].is_focus = true;
			o_control_menu.mn[5].visible = true;
			o_control_menu.mn[5].x = 528+128;
			
			o_control_menu.mn[1].is_focus = false;
			o_control_menu.mn[1].visible = false;
			
			//x += 1000;
			for (var i = 0; i < array_length_1d(bt); ++i) {
				bt[i].x += 10000;
			}
			var nomcat = o_control_menu.mn[1].bt[index_focused].soratra;
			global.cat2 = get_id_categorie_by_name(nomcat);
			reload_equipe();
		}
	}
	else if(mini_id == 4 || mini_id == 5){
		if(mini_id == 4 && (o_control_menu.mn[4].is_focus == true)){
			//is_set1 = true;
			var nomeq = string(o_control_menu.mn[4].bt[index_focused].soratra);
			global.equipe1 = get_id_by_name_and_cate(nomeq,global.cat1);
			is_ready = true;
		}else if(mini_id == 5 && (o_control_menu.mn[5].is_focus == true)){
			//is_set2 = true;
			is_ready = true;
			var nomeq = string(o_control_menu.mn[5].bt[index_focused].soratra);
			global.equipe2 = get_id_by_name_and_cate(nomeq,global.cat2);
			//room_goto(r_menu4);
		}
	}
}
