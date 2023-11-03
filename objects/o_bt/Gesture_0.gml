if(o_control_menu.can_press == true){
	image_index = 1;
	alarm_set(0,1);

	if(room == r_menu1 || room == r_menu2){
		for (var i = 0; i < array_length_1d(o_control_menu.mn[0].bt); ++i) {
			if(o_control_menu.mn[0].bt[i].is_focus == true){
				o_control_menu.mn[0].bt[i].is_focus = false;
				break;
			}
		}
		is_focus = true;
	
		for (var i = 0; i < array_length_1d(o_control_menu.mn[0].bt); ++i) {
			if(o_control_menu.mn[0].bt[i].is_focus == true){
				o_control_menu.mn[0].index_focused = i;
				break;
			}
		}
	
	}

	if(room == r_menu3){
	
		if(x < 528){ //menu 4
			for (var i = 0; i < array_length_1d(o_control_menu.mn[4].bt); ++i) {
				if(o_control_menu.mn[4].bt[i].is_focus == true){
					o_control_menu.mn[4].bt[i].is_focus = false;
					break;
				}
			}
			is_focus = true;
			for (var i = 0; i < array_length_1d(o_control_menu.mn[4].bt); ++i) {
				if(o_control_menu.mn[4].bt[i].is_focus == true){
					o_control_menu.mn[4].index_focused = i;
			
					var nomm = o_control_menu.mn[4].bt[i].soratra;
					var minieq = get_team_by_name_and_cate(nomm, global.cat1);
			
					o_control_menu.mn[2].afficher = minieq;
					o_control_menu.mn[2].text = nomm;
			
					break;
				}
			}
		}else{
			for (var i = 0; i < array_length_1d(o_control_menu.mn[5].bt); ++i) {
				if(o_control_menu.mn[5].bt[i].is_focus == true){
					o_control_menu.mn[5].bt[i].is_focus = false;
					break;
				}
			}
		
			is_focus = true;

			for (var i = 0; i < array_length_1d(o_control_menu.mn[5].bt); ++i) {
				if(o_control_menu.mn[5].bt[i].is_focus == true){
					o_control_menu.mn[5].index_focused = i;
				
					var nomm = o_control_menu.mn[5].bt[i].soratra;
					var minieq = get_team_by_name_and_cate(nomm, global.cat2);
			
					o_control_menu.mn[3].afficher = minieq;
					o_control_menu.mn[3].text = nomm;
				
					break;
				}
			}
		}
	}
}
