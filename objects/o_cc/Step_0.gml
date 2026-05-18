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


// ===== ANIMATION RECUPERATION APRES PANIER =====
if(basket_anim && is_pause == false){

	if(basket_phase == 0 && basket_timer == 0){
		// Initialisation : choisir basket_player (plus proche balle) et basket_support
		var _best   = -1; var _best_d  = 999999;
		var _best2  = -1; var _best2_d = 999999;
		if(basket_side == 1){
			for(var _i = 0; _i < 5; ++_i){
				var _d = point_distance(eq1[_i].x, eq1[_i].y, bb.x, bb.y);
				if(_d < _best_d){ _best_d = _d; _best = eq1[_i]; }
			}
			for(var _i = 0; _i < 5; ++_i){
				if(eq1[_i] != _best){
					var _d2 = point_distance(eq1[_i].x, eq1[_i].y, basket_inbound_x, basket_inbound_y);
					if(_d2 < _best2_d){ _best2_d = _d2; _best2 = eq1[_i]; }
				}
			}
			// Vider is_me de l'equipe qui remet (basket_player redevient bot)
			for(var _i = 0; _i < 5; ++_i){ eq1[_i].is_me = false; }
		} else {
			for(var _i = 0; _i < 5; ++_i){
				var _d = point_distance(eq2[_i].x, eq2[_i].y, bb.x, bb.y);
				if(_d < _best_d){ _best_d = _d; _best = eq2[_i]; }
			}
			for(var _i = 0; _i < 5; ++_i){
				if(eq2[_i] != _best){
					var _d2 = point_distance(eq2[_i].x, eq2[_i].y, basket_inbound_x, basket_inbound_y);
					if(_d2 < _best2_d){ _best2_d = _d2; _best2 = eq2[_i]; }
				}
			}
			for(var _i = 0; _i < 5; ++_i){ eq2[_i].is_me = false; }
		}
		basket_player  = _best;
		basket_support = _best2;
		basket_player.is_idle  = false;
		basket_support.is_idle = false;
		bb.pocesseur   = -1;
		bb.e_pocesseur = basket_side;
	}

	basket_timer += 1;

	if(basket_phase == 0){
		// Phase 0 : basket_player marche vers la balle
		if(instance_exists(basket_player)){
			basket_player.dest_x  = bb.x;
			basket_player.dest_y  = bb.y;
			basket_player.is_idle = false;
			// Support se positionne près du point d'inbound
			if(instance_exists(basket_support)){
				var _sx = basket_inbound_x + (basket_side == 1 ? 90 : -90);
				basket_support.dest_x  = _sx;
				basket_support.dest_y  = basket_inbound_y;
				basket_support.is_idle = false;
			}
			// Quand basket_player a la balle → phase 1
			if(basket_player.mbol == true){
				if(basket_side == 1){
					for(var _i = 0; _i < 5; ++_i){ eq1[_i].is_me = false; }
					basket_player.is_me = true;
					global.is_me1 = basket_player;
				} else {
					for(var _i = 0; _i < 5; ++_i){ eq2[_i].is_me = false; }
					basket_player.is_me = true;
					global.is_me2 = basket_player;
				}
				basket_phase = 1;
				basket_timer = 0;
			}
		} else {
			basket_anim = false;
		}

	} else if(basket_phase == 1){
		// Phase 1 : basket_player marche automatiquement vers inbound (controles bloques sauf direction)
		if(instance_exists(basket_support)){
			var _sx = basket_inbound_x + (basket_side == 1 ? 90 : -90);
			basket_support.dest_x  = _sx;
			basket_support.dest_y  = basket_inbound_y;
			basket_support.is_idle = false;
		}
		// Quand basket_player arrive au point → phase 2 (passe manuelle)
		if(!instance_exists(basket_player) || basket_player.mbol == false){
			basket_anim      = false;
			basket_phase     = 0;
			basket_timer     = 0;
			basket_cooldown  = 120;
		} else if(point_distance(basket_player.x, basket_player.y, basket_inbound_x, basket_inbound_y) < 20){
			basket_phase = 2;
			basket_timer = 0;
		}

	} else if(basket_phase == 2){
		// Phase 2 : basket_player controle par le joueur, attend la passe
		if(instance_exists(basket_support)){
			var _sx = basket_inbound_x + (basket_side == 1 ? 90 : -90);
			basket_support.dest_x  = _sx;
			basket_support.dest_y  = basket_inbound_y;
			basket_support.is_idle = false;
		}
		// Fin quand basket_player a passe (mbol devient false)
		if(!instance_exists(basket_player) || basket_player.mbol == false){
			basket_anim      = false;
			basket_phase     = 0;
			basket_timer     = 0;
			basket_cooldown  = 120;
		}
	}
}
// ===== FIN ANIMATION PANIER =====

// ===== HORS-TERRAIN (OUT OF BOUNDS) =====
// Limites légèrement en dehors des lignes visibles (pas de mur — balle libre)
var _bx1 = o_tr.x - 30;  var _bx2 = o_tr.x + 1040;
var _by1 = o_tr.y - 30;  var _by2 = o_tr.y + 530;
if(!basket_anim && !oob_anim){
	if(bb.x < _bx1 || bb.x > _bx2 || bb.y < _by1 || bb.y > _by2){
		oob_anim  = true;
		oob_timer = 0;
		oob_side  = (bb.e_pocesseur == 1) ? 2 : 1;
		// Point d'inbound = là où la balle a franchi la ligne (clamped aux vraies lignes)
		oob_inbound_x = clamp(bb.x, o_tr.x + 25, o_tr.x + 982);
		oob_inbound_y = clamp(bb.y, o_tr.y + 15, o_tr.y + 479);
		// Toujours fondu noir — couvre aussi bien le cas proche que lointain
		oob_fade_state = 1;
	}
}
if(oob_anim){
	oob_timer += global.time;
	if(oob_fade_state == 1){         // fondu vers noir
		oob_fade = min(oob_fade + 0.07, 1.0);
		if(oob_fade >= 1.0){ oob_fade_state = 2; oob_timer = 0; }
	} else if(oob_fade_state == 2){  // écran noir : reposition balle, bref maintien
		bb.x = oob_inbound_x; bb.y = oob_inbound_y; bb.z = 0;
		bb.limiteur_speed = 0; bb.limiteur_z = 0;
		bb.pocesseur = -1;
		if(oob_timer > 20){ oob_fade_state = 3; }
	} else if(oob_fade_state == 3){  // retour transparent
		oob_fade = max(oob_fade - 0.07, 0.0);
		if(oob_fade <= 0){
			oob_fade_state = 0;
			// Déclencher l'inbound
			basket_anim      = true;
			basket_phase     = 0;
			basket_timer     = 0;
			basket_side      = oob_side;
			basket_inbound_x = oob_inbound_x + (oob_side == 1 ? 35 : -35);
			basket_inbound_y = oob_inbound_y;
			oob_anim  = false;
			oob_timer = 0;
		}
	}
}
// ===== FIN HORS-TERRAIN =====

if(basket_cooldown > 0){
	basket_cooldown -= 1 * global.time;
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
	/*if(eq2[i].is_me == false){
		if(abs(point_distance(eq2[i].x,eq2[i].y,global.is_me2.x,global.is_me2.y)) <= abs(point_distance(global.is_me2.x,global.is_me2.y,ak2.x,ak2.y))){
			ak2.akaiky = false;
			ak2 = eq2[i];
			ak2.akaiky = true;
		}
	}else{
		eq2[i].akaiky = false;
	}*/
	
	if(eq2[i].is_me == false){
		
		//if(abs(point_distance(eq1[i].x,eq1[i].y,global.is_me1.x,global.is_me1.y)) <= abs(point_distance(global.is_me1.x,global.is_me1.y,ak1.x,ak1.y))){
		var aa = point_direction(global.is_me2.x,global.is_me2.y,eq2[i].x,eq2[i].y);
		var bbb = point_direction(global.is_me2.x,global.is_me2.y,ak2.x,ak2.y);
		eq2[i].afficheo = string(angle_difference(aa,global.is_me2.dir));
		if(abs(angle_difference(aa,global.is_me2.dir)) <= abs(angle_difference(bbb, global.is_me2.dir))){
			ak2.akaiky = false;
			ak2 = eq2[i];
			key = i;
			ak2.akaiky = true;
		}
	}else{
		eq2[i].akaiky = false;
	}
}


// Equipe 1 (humain) : main player = plus proche du ballon quand l'équipe 1 n'a pas la balle
if(!basket_anim && bb.e_pocesseur != 1){
	var _cur_d1 = point_distance(global.is_me1.x, global.is_me1.y, bb.x, bb.y);
	var _new_me1 = global.is_me1;
	for(var _i = 0; _i < 5; ++_i){
		var _d = point_distance(eq1[_i].x, eq1[_i].y, bb.x, bb.y);
		if(_d < _cur_d1 - 30){ _cur_d1 = _d; _new_me1 = eq1[_i]; }
	}
	if(_new_me1 != global.is_me1){
		global.is_me1.is_me = false;
		global.is_me1       = _new_me1;
		_new_me1.is_me      = true;
	}
}

// IA equipe 2 (solo) : main player = toujours le plus proche du ballon (hysteresis 30px)
if(global.playerNumber == 1 && !basket_anim && bb.e_pocesseur != 2){
	var _cur_d = point_distance(global.is_me2.x, global.is_me2.y, bb.x, bb.y);
	var _new_me2 = global.is_me2;
	for(var _i = 0; _i < 5; ++_i){
		var _d = point_distance(eq2[_i].x, eq2[_i].y, bb.x, bb.y);
		if(_d < _cur_d - 30){
			_cur_d  = _d;
			_new_me2 = eq2[_i];
		}
	}
	if(_new_me2 != global.is_me2){
		global.is_me2.is_me = false;
		global.is_me2       = _new_me2;
		_new_me2.is_me      = true;
	}
}

// Joueurs bots qui chassent le ballon libre
if(bb.pocesseur == -1 && !basket_anim){
	var _cmin1 = 999999; ball_chaser_eq1 = -1;
	for(var _i = 0; _i < 5; ++_i){
		if(eq1[_i].is_me == false){
			var _d = point_distance(eq1[_i].x, eq1[_i].y, bb.x, bb.y);
			if(_d < _cmin1){ _cmin1 = _d; ball_chaser_eq1 = eq1[_i]; }
		}
	}
	var _cmin2 = 999999; ball_chaser_eq2 = -1;
	for(var _i = 0; _i < 5; ++_i){
		if(eq2[_i].is_me == false){
			var _d = point_distance(eq2[_i].x, eq2[_i].y, bb.x, bb.y);
			if(_d < _cmin2){ _cmin2 = _d; ball_chaser_eq2 = eq2[_i]; }
		}
	}
} else {
	ball_chaser_eq1 = -1;
	ball_chaser_eq2 = -1;
}

//IA + tactique;
var _mid_x = o_tr.x + 503;  // milieu du terrain en X
var _mid_y = o_tr.y + 247;  // milieu du terrain en Y

if(bb.e_pocesseur == -1){

}else if(bb.e_pocesseur == 1){
	//equipe 1 attaque — positions statiques
	for (var i = 0; i < 5; ++i) {
	    tt1[i].x = o_tr.x+1007-tac1[2,i];
		tt1[i].y = o_tr.y+494-tac1[3,i];
		tt1[i].rayon = tac1[4,i];
	}
	//equipe 2 défense — positions statiques
	for (var i = 0; i < 5; ++i) {
	    tt2[i].x = o_tr.x+1007-tic2[2,i];
		tt2[i].y = o_tr.y+494-tic2[3,i];
		tt2[i].rayon = tic2[4,i];
	}
	// --- Positions dynamiques intermédiaires ---
	// Eq1 (offensif) : joueurs 3 et 4 se positionnent entre le milieu et la balle
	tt1[3].x = lerp(_mid_x, bb.x, 0.6);
	tt1[3].y = lerp(_mid_y - 90, bb.y, 0.4);
	tt1[3].rayon = 60;
	tt1[4].x = lerp(_mid_x, bb.x, 0.6);
	tt1[4].y = lerp(_mid_y + 90, bb.y, 0.4);
	tt1[4].rayon = 60;
	// Eq2 (défensif) : joueurs 3 et 4 couvrent entre la balle et leur panier (droite)
	tt2[3].x = lerp(bb.x, o_tr.x + 979, 0.4);
	tt2[3].y = lerp(bb.y, _mid_y - 80, 0.5);
	tt2[3].rayon = 48;
	tt2[4].x = lerp(bb.x, o_tr.x + 979, 0.4);
	tt2[4].y = lerp(bb.y, _mid_y + 80, 0.5);
	tt2[4].rayon = 48;

}else if(bb.e_pocesseur == 2){
	//equipe 2 attaque — positions statiques
	for (var i = 0; i < 5; ++i) {
	    tt2[i].x = o_tr.x+tic1[2,i];
		tt2[i].y = o_tr.y+tic1[3,i];
		tt2[i].rayon = tic1[4,i];
	}
	//equipe 1 défense — positions statiques
	for (var i = 0; i < 5; ++i) {
	    tt1[i].x = o_tr.x+tac2[2,i];
		tt1[i].y = o_tr.y+tac2[3,i];
		tt1[i].rayon = tac2[4,i];
	}
	// --- Positions dynamiques intermédiaires ---
	// Eq2 (offensif) : joueurs 3 et 4 se positionnent entre le milieu et la balle
	tt2[3].x = lerp(_mid_x, bb.x, 0.6);
	tt2[3].y = lerp(_mid_y - 90, bb.y, 0.4);
	tt2[3].rayon = 60;
	tt2[4].x = lerp(_mid_x, bb.x, 0.6);
	tt2[4].y = lerp(_mid_y + 90, bb.y, 0.4);
	tt2[4].rayon = 60;
	// Eq1 (défensif) : joueurs 3 et 4 couvrent entre la balle et leur panier (gauche)
	tt1[3].x = lerp(bb.x, o_tr.x + 28, 0.4);
	tt1[3].y = lerp(bb.y, _mid_y - 80, 0.5);
	tt1[3].rayon = 48;
	tt1[4].x = lerp(bb.x, o_tr.x + 28, 0.4);
	tt1[4].y = lerp(bb.y, _mid_y + 80, 0.5);
	tt1[4].rayon = 48;
}

// Cooldown post-inbound : l'équipe qui vient de remettre garde ses positions défensives
if(basket_cooldown > 0){
	if(basket_side == 1){
		// Team 1 vient de remettre : garder en défense (positions comme si team 2 attaque)
		for(var _i = 0; _i < 5; ++_i){
			tt1[_i].x     = o_tr.x + tac2[2,_i];
			tt1[_i].y     = o_tr.y + tac2[3,_i];
			tt1[_i].rayon = tac2[4,_i];
		}
	} else if(basket_side == 2){
		// Team 2 vient de remettre : garder en défense (positions comme si team 1 attaque)
		for(var _i = 0; _i < 5; ++_i){
			tt2[_i].x     = o_tr.x + 1007 - tic2[2,_i];
			tt2[_i].y     = o_tr.y + 494  - tic2[3,_i];
			tt2[_i].rayon = tic2[4,_i];
		}
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
