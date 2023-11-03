//auto - pause
if(window_has_focus() == false){
	global.time = 0;
	is_pause = true;
}

if(is_pause == true){
	if(create_pause == false){
		create_pause = true;
		menu_p = instance_create_depth(room_width/2,room_height/2+40,-100,m_pause);
		menu_p.mpamorona = self;
	}
}


//akaiky player 1
for (var i = 0; i < 5; ++i) {
    if(ak1 != global.is_me1){
		break;
	}else{
		ak1 = eq1[i];
		ak1.akaiky = false;
	}
}
for (var i = 0; i < 5; ++i) {
	if(eq1[i].is_me == false){
		
		//if(abs(point_distance(eq1[i].x,eq1[i].y,global.is_me1.x,global.is_me1.y)) <= abs(point_distance(global.is_me1.x,global.is_me1.y,ak1.x,ak1.y))){
		var aa = point_direction(global.is_me1.x,global.is_me1.y,eq1[i].x,eq1[i].y);
		var bbb = point_direction(global.is_me1.x,global.is_me1.y,ak1.x,ak1.y);
		eq1[i].afficheo = string(angle_difference(aa,global.is_me1.dir));
		if(abs(angle_difference(aa,global.is_me1.dir)) <= abs(angle_difference(bbb, global.is_me1.dir))){
			ak1.akaiky = false;
			ak1 = eq1[i];
			key = i;
			ak1.akaiky = true;
		}
	}else{
		eq1[i].akaiky = false;
	}
}

//akaiky 2 player 2
for (var i = 0; i < 5; ++i) {
    if(ak2 != global.is_me2){
		break;
	}else{
		ak2 = eq2[i];
		ak2.akaiky = false;
	}
}
for (var i = 0; i < 5; ++i) {
	if(eq2[i].is_me == false){
		if(abs(point_distance(eq2[i].x,eq2[i].y,global.is_me2.x,global.is_me2.y)) <= abs(point_distance(global.is_me2.x,global.is_me2.y,ak2.x,ak2.y))){
			ak2.akaiky = false;
			ak2 = eq2[i];
			ak2.akaiky = true;
		}
	}else{
		eq2[i].akaiky = false;
	}
}


//IA + tactique;
if(bb.e_pocesseur == -1){
	
}else if(bb.e_pocesseur == 1){
	//equipe 1 attaque
	for (var i = 0; i < 5; ++i) {
	    tt1[i].x = o_tr.x+1007-tac1[2,i];
		tt1[i].y = o_tr.y+494-tac1[3,i];
		tt1[i].rayon = tac1[4,i];
	}

	//equipe 2 défense
	for (var i = 0; i < 5; ++i) {
	    tt2[i].x = o_tr.x+1007-tic2[2,i];
		tt2[i].y = o_tr.y+494-tic2[3,i];
	}
	
}else if(bb.e_pocesseur == 2){
	//equipe 2 attaque
	for (var i = 0; i < 5; ++i) {
	    tt2[i].x = o_tr.x+tic1[2,i];
		tt2[i].y = o_tr.y+tic1[3,i];
	}
	
	//equipe 1 defense
	for (var i = 0; i < 5; ++i) {
	    tt1[i].x = o_tr.x+tac2[2,i];
		tt1[i].y = o_tr.y+tac2[3,i];
	}
}


//Affectation point equipe 1 et equipe 2
if(possesseur_ballon != o_b.pocesseur && o_b.pocesseur != -1){ 
	ds_list_add(listako1,0);
	ds_list_add(listako1,1);
	ds_list_add(listako1,2);
	ds_list_add(listako1,3);
	ds_list_add(listako1,4);

	for(var i = 0; i < array_length(tt1);++i){
		tt1[i].olona = -1;
	}

	//equipe 1 -- START ---
	while(ds_list_size(listako1) != 0){
		var ol = ds_list_find_value(listako1,0);

		var point0 = 0;
		var prio = ds_priority_create();
		
		for (var i = 0; i < array_length(tt1); ++i) {
			var ka = point_distance(eq1[ol].x,eq1[ol].y,tt1[i].x,tt1[i].y);
		    ds_priority_add(prio,tt1[i].index,ka);
		}
		
		while(true){
			point0 = ds_priority_find_min(prio);
			//show_message(string(point0));
			if(tt1[point0].olona == -1){
				tt1[point0].olona = eq1[ol].index;
				ds_list_delete(listako1,0);
				break;
			}else{
				if(point_distance(eq1[ol].x,eq1[ol].y,tt1[point0].x,tt1[point0].y)
									>
					point_distance(eq1[tt1[point0].olona].x,eq1[tt1[point0].olona].y,tt1[point0].x,tt1[point0].y)){
						ds_list_add(listako1, tt1[point0].olona);
						tt1[point0].olona = eq1[ol].index;
						ds_list_delete(listako1,0);
						break;
					}	
			}
			ds_priority_delete_min(prio);
		}
	}
	for (var i = 0; i < array_length(eq1); ++i) {
		for(var j = 0; j < array_length(tt2); ++j){
			if(tt1[j].olona == eq1[i].index){
				//show_message("player "+string(i)+" => point "+string(j));
				eq1[i].point_tt = j;
				break;
			}
		}
	}
	//equipe 1 ---- END ---------
	
	//equipe 2 -- START ---
	ds_list_add(listako2,0);
	ds_list_add(listako2,1);
	ds_list_add(listako2,2);
	ds_list_add(listako2,3);
	ds_list_add(listako2,4);

	for(var i = 0; i < array_length(tt2);++i){
		tt2[i].olona = -1;
	}
	
	while(ds_list_size(listako2) != 0){
		var ol = ds_list_find_value(listako2,0);
		var point0 = 0;
		var prio = ds_priority_create();
		
		for (var i = 0; i < array_length(tt2); ++i) {
			var ka = point_distance(eq2[ol].x,eq2[ol].y,tt2[i].x,tt2[i].y);
		    ds_priority_add(prio,tt2[i].index,ka);
		}
		
		while(true){
			point0 = ds_priority_find_min(prio);
		
			if(tt2[point0].olona == -1){
				tt2[point0].olona = eq2[ol].index;
				ds_list_delete(listako2,0);
				break;
			}else{
				if(point_distance(eq2[ol].x,eq2[ol].y,tt2[point0].x,tt2[point0].y)
									<
					point_distance(eq2[tt2[point0].olona].x,eq2[tt2[point0].olona].y,tt2[point0].x,tt2[point0].y)){
						ds_list_add(listako2, tt2[point0].olona);
						tt2[point0].olona = eq2[ol].index;
						ds_list_delete(listako2,0);
						break;
					}	
			}
			ds_priority_delete_min(prio);
		}
	}
	for (var i = 0; i < array_length(eq2); ++i) {
		for(var j = 0; j < array_length(tt2); ++j){
			if(tt2[j].olona == eq2[i].index){
				eq2[i].point_tt = tt2[j].olona;
				break;
			}
		}
	}
	//equipe 2 ---- END ---------
	
	possesseur_ballon = o_b.pocesseur;
}
