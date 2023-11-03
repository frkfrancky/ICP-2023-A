function initialisation_menu4() {
	var xi = 128;
	var yi = 32;
	mn[0] = instance_create_depth(48+xi,236+yi,-5,o_sous_menu2); mn[0].mini_id = 0;
	mn[1] = instance_create_depth(528+xi,236+yi,-5,o_sous_menu2); mn[1].mini_id = 1;

	mn[0].jou = get_by_team(global.equipe1,1);
	mn[1].jou = get_by_team(global.equipe2,2);
	
	global.membre1 = mn[0].jou;
	global.membre2 = mn[1].jou;

	if(is_array(mn[0].jou)){//LISTE DES BOUTONS DE J1
		mn[0].bt[0] = instance_create_depth(mn[0].x+8,mn[0].y+8,-5,o_bt1);
		mn[0].bt[0].anarana = "READY";
		mn[0].bt[0].mini_id = 0;
		mn[0].bt[0].data = 0;
		var chi = 1;
		for (var i=0; i < array_length_2d(mn[0].jou,0); ++i) {
		    mn[0].bt[chi] = instance_create_depth(mn[0].x+8,mn[0].y+8+(i*58),-5,o_bt1);
			mn[0].bt[chi].anarana = mn[0].jou[1,i];
			mn[0].bt[chi].mini_id = chi;
			mn[0].bt[chi].data[0] = mn[0].jou[3,i];//major
		
			mn[0].bt[chi].data[1] = mn[0].jou[4,i];//vitesse
			mn[0].bt[chi].data[2] = mn[0].jou[5,i];//precision
			mn[0].bt[chi].data[3] = mn[0].jou[6,i];//puissance
			mn[0].bt[chi].data[4] = mn[0].jou[7,i];//defense
			mn[0].bt[chi].data[5] = mn[0].jou[8,i];//technique
		
			mn[0].bt[chi].data[6] = mn[0].jou[0,i];//id
			mn[0].bt[chi].data[7] = mn[0].jou[2,i];//numero
			mn[0].bt[chi].data[8] = mn[0].jou[1,i];//anarana
			//show_message(string(mn[0].bt[chi].data[7]));
			chi++;
		}
		mn[0].bt[0].is_focus = true;
		mn[0].index_focused = 0;
	
		if(global.playerNumber == 1 || global.playerNumber == 2){
			mn[0].is_focus = true;
		}
	}

	if(is_array(mn[1].jou)){//LISTE DES BOUTONS DE J2
		mn[1].bt[0] = instance_create_depth(mn[1].x+8,mn[1].y+8,-5,o_bt1);
		mn[1].bt[0].anarana = "READY";
		mn[1].bt[0].mini_id = 0;
		var chi = 1;
		for (var i = 0; i < array_length_2d(mn[1].jou,0); ++i) {
		    mn[1].bt[chi] = instance_create_depth(mn[1].x+8,mn[1].y+8+(i*58),-5,o_bt1);
			mn[1].bt[chi].anarana = mn[1].jou[1,i];
			mn[1].bt[chi].mini_id = chi;
		
			mn[1].bt[chi].data[0] = mn[1].jou[3,i];
			mn[1].bt[chi].data[1] = mn[1].jou[4,i];
			mn[1].bt[chi].data[2] = mn[1].jou[5,i];
			mn[1].bt[chi].data[3] = mn[1].jou[6,i];
			mn[1].bt[chi].data[4] = mn[1].jou[7,i];
			mn[1].bt[chi].data[5] = mn[1].jou[8,i];
		
			mn[1].bt[chi].data[6] = mn[1].jou[0,i];
			mn[1].bt[chi].data[7] = mn[1].jou[2,i];
			mn[1].bt[chi].data[8] = mn[1].jou[1,i];//anarana
			chi++;
		}
		mn[1].bt[0].is_focus = true;
		mn[1].index_focused = 0;
	
		if(global.playerNumber == 2){
			mn[1].is_focus = true;
		}
	}



	//indicateur de l'equipe
	mn[2] = instance_create_depth(-52+xi,8+yi,-5,o_sous_menu3);	mn[2].mini_id = 2;
	mn[3] = instance_create_depth(628+xi,8+yi,-5,o_sous_menu3);	mn[3].mini_id = 3;
	
	//bouton retour
	bt = instance_create_depth(32,512+yi,-6,o_bt2);


}
