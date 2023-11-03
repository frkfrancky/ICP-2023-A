function initialisation_menu3() {
	if(debut == false){
		if(mini_id == 0 || mini_id == 1){
			res = get_all_categorie();
		
			for (var i = 0; i < array_length_2d(res,0); ++i) {
				bt[i] = instance_create_depth(x+16, y+16+(i*72), -6, o_bt);
				bt[i].mini_id = i;
				bt[i].image_alpha = 0;
				bt[i].soratra = res[1,i];
			}
		
		}
	
		if(mini_id == 4 || mini_id == 5){//BBG
			var cat;
			if(mini_id == 4){
				cat = global.cat1;
			}else{
				cat = global.cat2;
			}
			if(cat == 0){
				cat = 1;
			}
			res = get_team_by_categorie(cat);
			for (var i = 0; i < array_length_2d(res,1); ++i) {
			    bt[i] = instance_create_depth(x+16, y+16+(i*96), -6, o_bt);
				bt[i].mini_id = i;
			}
		
			for(var i = 0; i < array_length_2d(res,1); ++i) {
				bt[i].soratra = res[1,i];
				bt[i].icon = res[3,i];
			}
		
			image_alpha = 1;
		}
	
		debut = true;
	}


}
