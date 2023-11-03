function reload_equipe() {
	/*for (var i = 0; i < array_length_1d(bt); ++i) {
	    instance_destroy(bt[i]);
	}*/

	if(mini_id == 0 || mini_id == 1){
		var cat;
		var in;
		if(mini_id == 0){
			cat = global.cat1;
			in = 4;
		}else{
			cat = global.cat2;
			in = 5;
		}
		if(cat == 0){
			cat = 1;
		}
	
		res = get_team_by_categorie(cat);	
	
		for (var i = 0; i < array_length_1d(o_control_menu.mn[in].bt); ++i) {
		    instance_destroy(o_control_menu.mn[in].bt[i]);
		}
	
		o_control_menu.mn[in].bt = 0;
		o_control_menu.mn[in].index_focused = 0;
	
	
	
	
		for (var i = 0; i < array_length_2d(res,1); ++i) {
			o_control_menu.mn[in].bt[i] = instance_create_depth(x+16, y+8+(i*72), -6, o_bt);
			o_control_menu.mn[in].bt[i].mini_id = i;
			o_control_menu.mn[in].bt[i].soratra = res[1,i];
			o_control_menu.mn[in].bt[i].icon = res[3,i];
		}
	
		var nomm = o_control_menu.mn[in].bt[0].soratra;
		var minieq = get_team_by_name_and_cate(nomm, cat);
	
		o_control_menu.mn[in-2].afficher = minieq;
		o_control_menu.mn[in-2].text = nomm;
	
	}


}
