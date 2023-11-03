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

	if(room == r_menu4){
	
		if(x < 528){ //menu 0
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
		}else{
			for (var i = 0; i < array_length_1d(o_control_menu.mn[1].bt); ++i) {
				if(o_control_menu.mn[1].bt[i].is_focus == true){
					o_control_menu.mn[1].bt[i].is_focus = false;
					break;
				}
			}
		
			is_focus = true;

			for (var i = 0; i < array_length_1d(o_control_menu.mn[1].bt); ++i) {
				if(o_control_menu.mn[1].bt[i].is_focus == true){
					o_control_menu.mn[1].index_focused = i;
				
					break;
				}
			}
		}
	}
}
