
if(is_me){

	// --- Gestion des controles (priorite : animation panier > IA solo > joueur) ---
	if(o_cc.basket_anim && o_cc.basket_phase == 1 && id == o_cc.basket_player){
		// Phase 1 : basket_player marche automatiquement vers le point d'inbound
		up = false; down = false; right = false; left = false;
		haxis = 0; vaxis = 0; act1 = false; act2 = false;
		if(point_distance(x, y, o_cc.basket_inbound_x, o_cc.basket_inbound_y) > 15){
			var _bd = point_direction(x, y, o_cc.basket_inbound_x, o_cc.basket_inbound_y);
			right = (dcos(_bd) >  0.4);
			left  = (dcos(_bd) < -0.4);
			up    = (-dsin(_bd) < -0.4);
			down  = (-dsin(_bd) >  0.4);
		}
	} else if(o_cc.basket_anim && !(o_cc.basket_phase == 2 && id == o_cc.basket_player)){
		// Bloquer tous les controles hors basket_player en phase 2
		up = false; down = false; right = false; left = false;
		haxis = 0; vaxis = 0; act1 = false; act2 = false;
	} else if(ekipa == 2 && global.playerNumber == 1){
		// IA du joueur principal equipe 2 en mode solo
		up = false; down = false; left = false; right = false;
		haxis = 0; vaxis = 0;
		act1 = false; act2 = false;

		var _ia_tx = x;
		var _ia_ty = y;

		// Délai de réaction IA : met à jour la cible toutes les ia_react_delay frames seulement
		ia_react_timer -= global.time;
		if(ia_react_timer <= 0){
			ia_react_timer = irandom_range(8, 22);
			dest_x = mbol ? o_cc.but1.x : (o_cc.bb.x + random_range(-18, 18));
			dest_y = mbol ? o_cc.but1.y : (o_cc.bb.y + random_range(-18, 18));
		}
		_ia_tx = dest_x; _ia_ty = dest_y;

		if(mbol){
			var _d_but = point_distance(x, y, o_cc.but1.x, o_cc.but1.y);
			var _shoot_range = 150 + (4 - global.difficulty) * 80;
			// Décision tir → windup visible (jauge se remplit avant le tir)
			if(!is_charging_tir && !is_charging_passe && _d_but < _shoot_range && c_a >= count_act && irandom(max(1,round(45/max(global.time,0.1)))) == 0){
				is_charging_tir = true; jauge_tir = 0;
			}
			if(is_charging_tir){
				jauge_tir += 2.8 * global.time;
				if(jauge_tir >= 65){ is_charging_tir = false; fire_tir = true; }
			}
			// Décision passe → windup visible
			if(!is_charging_tir && !is_charging_passe && c_a >= count_act && can_pass && can_act1 && irandom(max(1,round(90/max(global.time,0.1)))) == 0){
				is_charging_passe = true; jauge_passe = 0;
			}
			if(is_charging_passe){
				jauge_passe += 2.8 * global.time;
				if(jauge_passe >= 65){ is_charging_passe = false; fire_passe = true; }
			}
		} else {
			// Sans ballon : cible la balle libre ou le porteur adverse, avec imprécision
			if(o_cc.bb.pocesseur == -1){
				_ia_tx = o_cc.bb.x + random_range(-20, 20);
				_ia_ty = o_cc.bb.y + random_range(-20, 20);
			} else {
				_ia_tx = o_cc.bb.x;
				_ia_ty = o_cc.bb.y;
			}
			// Steal : collision + cooldown + petit délai de réaction aléatoire
			if(o_cc.bb.e_pocesseur == 1
			&& collision_circle(x, y, sprite_width/2 + 4, o_cc.bb, 1, 0)
			&& can_act1 && c_ia_steal >= count_ia_steal
			&& irandom(max(1, round(18/max(global.time,0.1)))) == 0){
				act1 = true;
				c_ia_steal = 0;
			}
		}
		if(c_ia_steal < count_ia_steal){ c_ia_steal += 1 * global.time; }
		if(point_distance(x, y, _ia_tx, _ia_ty) > 12){
			var _ia_dir = point_direction(x, y, _ia_tx, _ia_ty);
			right = (dcos(_ia_dir) >  0.4);
			left  = (dcos(_ia_dir) < -0.4);
			down  = (-dsin(_ia_dir) >  0.4);
			up    = (-dsin(_ia_dir) < -0.4);
		}
	} else {
		touche_match();

		if(mbol && c_a >= count_act){
			// --- Tir : tap bref = tire faible, maintien = charge précis ---
			if(act2){
				hold_act2_c += 1 * global.time;
				if(hold_act2_c > 5){
					is_charging_tir = true;
					jauge_tir += 3.5 * global.time;
					if(jauge_tir >= 100){ is_charging_tir = false; fire_tir = false; jauge_tir = 0; hold_act2_c = 0; }
				}
				act2 = false;
			} else {
				if(is_charging_tir){ is_charging_tir = false; fire_tir = true; }
				else if(hold_act2_c > 0){ fire_tir = true; jauge_tir = 28; }  // tap = tire faible
				hold_act2_c = 0;
			}

			// --- Passe : tap bref = passe molle, maintien = charge précis ---
			if(can_act && can_pass && can_act1){
				if(act1){
					hold_act1_c += 1 * global.time;
					if(hold_act1_c > 5){
						is_charging_passe = true;
						jauge_passe += 3.5 * global.time;
						if(jauge_passe >= 100){ is_charging_passe = false; fire_passe = false; jauge_passe = 0; hold_act1_c = 0; }
					}
					act1 = false;
				} else {
					if(is_charging_passe){ is_charging_passe = false; fire_passe = true; }
					else if(hold_act1_c > 0){ fire_passe = true; jauge_passe = 22; }  // tap = passe molle
					hold_act1_c = 0;
				}
			}
		} else if(!mbol){
			hold_act1_c = 0; hold_act2_c = 0;
			is_charging_tir = false; is_charging_passe = false;

			// Auto-approche steal : glisse vers la balle ennemie quand proche
			var _dist_ball = point_distance(x, y, o_cc.bb.x, o_cc.bb.y);
			if(o_cc.bb.e_pocesseur != ekipa && _dist_ball < 80 && can_act1){
				var _drift = 0.35 * (1.0 - _dist_ball / 80);
				var _drift_dir = point_direction(x, y, o_cc.bb.x, o_cc.bb.y);
				x += lengthdir_x(_drift, _drift_dir) * global.time;
				y += lengthdir_y(_drift, _drift_dir) * global.time;
			}

			// Tap sans ballon = pre-move SEULEMENT si hors de la zone de steal
			var _steal_zone = (o_cc.bb.e_pocesseur != ekipa && _dist_ball < sprite_width/2 + 8);
			if(!miandry && can_act && !_steal_zone){
				if(act2){ pm_action = (pm_action == 1) ? -1 : 1; pm_jauge = 60; act2 = false; }
				if(act1 && can_pass && can_act1){ pm_action = (pm_action == 0) ? -1 : 0; pm_jauge = 60; act1 = false; }
			}
			// Annuler pre-move si l'ennemi a le ballon
			if(o_cc.bb.e_pocesseur != ekipa){ pm_action = -1; pm_jauge = 0; }
		}
	}

	//test 3 points
	if(ekipa == 1){
		if(collision_circle(o_tr.x3pts_2,o_tr.y3pts,o_tr.r3pts,self,true,false)){
			pt3s = false;		}else{			pt3s = true;
		}
	}else{
		if(collision_circle(o_tr.x3pts_1,o_tr.y3pts,o_tr.r3pts,self,true,false)){
			pt3s = false;		}else{			pt3s = true;
		}
	}
	
	if(mbol){//drible
		if(o_cc.basket_anim && o_cc.basket_phase == 2 && id == o_cc.basket_player){
			// Inbound : balle tenue en hauteur, pas de rebond
			o_cc.bb.z = z + 60;
			o_cc.bb.limiteur_z = 0;
		} else {
			if(o_cc.bb.z <= o_cc.bb.z_tany){
				o_cc.bb.limiteur_z = 6;
			}
		}
		o_cc.bb.x = x+lengthdir_x(8,direction);
		o_cc.bb.y = y+lengthdir_y(8,direction);

		if(miandry_passe == true){
			miandry_passe = false;
		}
	}
}//fin is me
else if(is_me == false){
	if(miandry_passe == true){
		limiteur_speed = 0;
		speed = 0;
	}
}

if(up || down || right || left 
|| (haxis != 0 || vaxis != 0) 
|| (o_cam.button_analogue == true && ekipa == 1)
&& is_me == true){
	
	
	if(limiteur_speed < sp*global.time){
		limiteur_speed += acc*global.time;
	}
	//speed = sp*global.time;
	
	if(up == true && down == false && right == false && left == false){
		dir = 90;
	}else if(up == true && down == false && right == true && left == false){
		dir = 45;
	}else if(up == true && down == false && right == false && left == true){
		dir = 135;
	}else if(up == false && down == false && right == false && left == true){
		dir = 180;
	}else if(up == false && down == true && right == false && left == true){
		dir = 225;
	}else if(up == false && down == true && right == false && left == false){
		dir = 270;
	}else if(up == false && down == true && right == true && left == false){
		dir = 315;
	}else if(up == false && down == false && right ==true && left == false){
		dir = 0;
	}
	
	if(angle_difference(dir,direction)>0.5){
		direction += ((tec*global.time)/1.5);
	}else if(angle_difference(dir,direction)<-0.5){
		direction -= ((tec*global.time)/1.5);
	}
	image_angle = direction;
}else{
	//speed = 0;
	if(limiteur_speed > 0 && is_me == true){
		limiteur_speed -= acc*global.time;
	}
}
//direction = limiteur_dir * global.time;
speed = limiteur_speed * global.time;
// Inbound phase 2 : direction libre mais pas de deplacement
if(o_cc.basket_anim && o_cc.basket_phase == 2 && is_me && id == o_cc.basket_player){
	limiteur_speed = 0;
	speed = 0;
}

if(is_me == false){//IA + tactic
	image_angle = direction;
	// Annuler pre-move si l'adversaire a le ballon
	if(o_cc.bb.e_pocesseur != ekipa){ pm_action = -1; pm_jauge = 0; }

	// Pendant l'animation panier : basket_player et basket_support ignorent la tactique
	// Chasse du ballon libre : ball_chaser_eq1/eq2 ignorent aussi la tactique
	if(o_cc.basket_anim && (id == o_cc.basket_player || id == o_cc.basket_support)){
		is_idle = false;
		dir = point_direction(x, y, dest_x, dest_y);
		if(point_distance(x, y, dest_x, dest_y) > 10){
			if(limiteur_speed < sp * global.time){
				limiteur_speed += acc * global.time;
			}
		} else {
			limiteur_speed = 0;
			speed = 0;
		}
		if(angle_difference(dir, direction) > 0){
			direction += ((tec * global.time) / 1);
		} else if(angle_difference(dir, direction) < 0){
			direction -= ((tec * global.time) / 1);
		}
	} else if(o_cc.bb.pocesseur == -1 && (id == o_cc.ball_chaser_eq1 || id == o_cc.ball_chaser_eq2)){
		// Foncer vers le ballon libre — s'arrêter quand en contact
		is_idle = false;
		var _bchase_d = point_distance(x, y, o_cc.bb.x, o_cc.bb.y);
		if(_bchase_d > 28){
			dest_x = o_cc.bb.x;
			dest_y = o_cc.bb.y;
			dir = point_direction(x, y, dest_x, dest_y);
			if(limiteur_speed < sp * global.time){
				limiteur_speed += acc * global.time;
			}
			if(angle_difference(dir, direction) > 0){
				direction += ((tec * global.time) / 1);
			} else if(angle_difference(dir, direction) < 0){
				direction -= ((tec * global.time) / 1);
			}
		} else {
			limiteur_speed = 0;
			speed = 0;  // en contact : attendre la balle, ne pas osciller
		}
	} else {

	var _pt_x = 0; var _pt_y = 0; var _r = 0;
	if(ekipa == 1){
		_pt_x = o_cc.tt1[point_tt].x;
		_pt_y = o_cc.tt1[point_tt].y;
		_r    = o_cc.tt1[point_tt].rayon;
	}
	if(ekipa == 2){
		_pt_x = o_cc.tt2[point_tt].x;
		_pt_y = o_cc.tt2[point_tt].y;
		_r    = o_cc.tt2[point_tt].rayon;
	}

	// Délai de réaction tactique : mise à jour de destination throttlée
	ia_react_timer -= global.time;
	var _can_react = (ia_react_timer <= 0);
	// Le point tactique a bougé loin ET réaction possible → nouvelle destination
	var _point_moved = point_distance(dest_x, dest_y, _pt_x, _pt_y) > _r * 2 + 1 && _can_react;

	if(is_idle){
		// Attente sur place
		c_idle += 1 * global.time;
		limiteur_speed = 0;
		speed = 0;
		if(c_idle >= count_idle || _point_moved){
			is_idle = false;
			c_idle  = 0;
			// Nouvelle destination + nouvelle vitesse aléatoire
			dest_x  = _pt_x + random_range(-_r, _r);
			dest_y  = _pt_y + random_range(-_r, _r);
			sp_bot  = random_range(0.6, 1.0) * sp;
			ia_react_timer = irandom_range(10, 28);  // nouveau délai aléatoire
		}
	}else{
		// En déplacement
		if(_point_moved){
			dest_x = _pt_x + random_range(-_r, _r);
			dest_y = _pt_y + random_range(-_r, _r);
			sp_bot = random_range(0.6, 1.0) * sp;
		}
		dir = point_direction(x, y, dest_x, dest_y);

		if(point_distance(x, y, dest_x, dest_y) > 10){
			if(limiteur_speed > sp_bot * global.time){
				limiteur_speed -= acc * global.time;
			}else if(limiteur_speed < sp_bot * global.time){
				limiteur_speed += acc * global.time;
			}
		}else{
			// Arrivé : déclencher une pause aléatoire (60 à 240 frames)
			limiteur_speed = 0;
			speed          = 0;
			is_idle        = true;
			c_idle         = 0;
			count_idle     = random_range(10, 45);
		}

		if(angle_difference(dir, direction) > 0){
			direction += ((tec * global.time) / 1);
		}else if(angle_difference(dir, direction) < 0){
			direction -= ((tec * global.time) / 1);
		}
	}
	} // fin else (hors animation panier)

	// Interception passe lobée : sauter si la balle haute passe près
	if(o_cc.bb.pocesseur == -1 && o_cc.bb.z > 60
	&& o_cc.bb.e_pocesseur != ekipa && !is_jumping){
		var _dbal = point_distance(x, y, o_cc.bb.x, o_cc.bb.y);
		if(_dbal < 80){
			is_jumping = true;
			jump_vz = clamp(o_cc.bb.z / 25, 2, 5) * global.time;
		}
	}
}

if((act1 == true || fire_passe) && mbol == true && c_a >= count_act && can_act == true && can_pass == true && can_act1 == true){//passe
	var _is_human_pass = fire_passe;
	var _jp = _is_human_pass ? jauge_passe : 65;  // IA : jauge fixe à 65%
	fire_passe  = false;
	jauge_passe = 0;

	can_pass = false;
	can_act = false;
	can_act1 = false;

	miandry = true;
	mbol = false;
	o_cc.bb.pocesseur = -1;
	var target = 0;
	// Déviation angulaire : jauge basse = imprécis (30°), jauge haute = précis (2°)
	var _pass_dev = lerp(30, 2, _jp / 100);
	if(ekipa == 1){
		o_cc.bb.direction = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.ak1.x,o_cc.ak1.y)
		                    + random_range(-_pass_dev, _pass_dev);
		o_cc.ak1.miandry_passe = true;
		target = o_cc.ak1;
	}else if(ekipa == 2){
		o_cc.bb.direction = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.ak2.x,o_cc.ak2.y)
		                    + random_range(-_pass_dev, _pass_dev);
		o_cc.ak2.miandry_passe = true;
		target = o_cc.ak2;
	}

	o_cc.bb.x = x + lengthdir_x(8+10, o_cc.bb.direction);
	o_cc.bb.y = y + lengthdir_y(8+10, o_cc.bb.direction);

	var d = point_distance(o_cc.bb.x, o_cc.bb.y, target.x, target.y);

	// Puissance de passe : fixe (stat joueur), indépendante de la jauge
	// Jauge contrôle uniquement la précision et l'interceptionabilité
	o_cc.bb.intercept_chance = lerp(90, 10, _jp / 100);
	o_cc.bb.is_pass = true;

	// Détection ennemi entre passeur et receveur → passe lobée
	var _lob = false;
	var _pass_angle = o_cc.bb.direction;
	var _enemy_list = (ekipa == 1) ? o_cc.eq2 : o_cc.eq1;
	for(var _li = 0; _li < 5; ++_li){
		var _ed = point_distance(x, y, _enemy_list[_li].x, _enemy_list[_li].y);
		var _ea = abs(angle_difference(point_direction(x, y, _enemy_list[_li].x, _enemy_list[_li].y), _pass_angle));
		if(_ed < d && _ea < 35){
			_lob = true;
			break;
		}
	}

	if(_lob){
		var _lob_spd = clamp((d * 3.0) / 273, 2.5, 5.0) * passe_power;
		o_cc.bb.z = 60;
		o_cc.bb.limiteur_speed = _lob_spd;
		o_cc.bb.limiteur_z = 5 + (d / 260);
	} else {
		var _pass_spd = ((d < 100) ? 4.5 : 6.0) * passe_power;
		o_cc.bb.z = 50;
		o_cc.bb.limiteur_speed = _pass_spd;
		o_cc.bb.limiteur_z = 4;
	}
	c_a = 0;
	c_p = 0;
	c_a1 = 0;
}

if((act2 == true || fire_tir) && mbol == true && c_a >= count_act){//tir
	var _is_human_shot = fire_tir;
	var _jt = _is_human_shot ? jauge_tir : 65;  // IA : jauge fixe à 65%
	fire_tir  = false;
	jauge_tir = 0;

	can_act = false;
	miandry = true;
	mbol = false;
	o_cc.bb.pocesseur = -1;
	o_cc.bb.mpamono = self;
	last_3pt = pt3s;

	// Saut automatique au tir
	if(!is_jumping){
		if(pt3s == true){
			if(irandom(2) > 0){ is_jumping = true; jump_vz = random_range(2, 4); }
		} else {
			var _ej = (ekipa == 1) ? o_cc.eq2 : o_cc.eq1;
			for(var _ji = 0; _ji < 5; ++_ji){
				var _jd = point_distance(x, y, _ej[_ji].x, _ej[_ji].y);
				if(_jd < 70){
					is_jumping = true;
					jump_vz = lerp(5, 3, _jd / 70);
					break;
				}
			}
		}
	}

	var d = 0;
	if(ekipa == 1){
		d = point_distance(o_cc.bb.x,o_cc.bb.y,o_cc.but2.x,o_cc.but2.y);
	}else if(ekipa == 2){
		d = point_distance(o_cc.bb.x,o_cc.bb.y,o_cc.but1.x,o_cc.but1.y);
	}

	// Calcul déviation et puissance selon jauge
	var _deviation  = 0;
	var _power_mult = 1;

	if(_is_human_shot){
		var _green_center = 65;
		var _green_half   = 25 * (precision / 100);
		var _green_min    = _green_center - _green_half;
		var _green_max    = _green_center + _green_half;

		if(_jt < 40){
			_deviation  = lerp(35, 10, _jt / 40);
			_power_mult = lerp(0.55, 0.88, _jt / 40);
		} else if(_jt > 90){
			_deviation  = lerp(8, 22, (_jt - 90) / 10);
			_power_mult = lerp(1.08, 1.35, (_jt - 90) / 10);
		} else {
			if(_jt >= _green_min && _jt <= _green_max){
				_deviation = 0; _power_mult = 1;
			} else {
				var _dist_g = min(abs(_jt - _green_min), abs(_jt - _green_max));
				var _max_g  = max(_green_min - 40, 90 - _green_max, 1);
				_deviation  = (_dist_g / _max_g) * 15;
				_power_mult = 1;
			}
		}
	} else {
		// IA : précision selon difficulté
		var _ia_dev = (4 - global.difficulty) * 7;
		_deviation  = random(_ia_dev);
		_power_mult = 1;
	}

	var _dir_basket;
	if(ekipa == 1){
		_dir_basket = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.but2.x,o_cc.but2.y);
	} else {
		_dir_basket = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.but1.x,o_cc.but1.y);
	}
	if(_deviation > 0){ _dir_basket += random_range(-_deviation, _deviation); }
	o_cc.bb.direction = _dir_basket;

	o_cc.bb.z = alavany + 1;
	var _base_spd = (d * 4.0) / 273;
	o_cc.bb.limiteur_speed = _base_spd * _power_mult;
	o_cc.bb.limiteur_z = (-o_cc.but2.z - o_cc.bb.z) * (o_cc.bb.limiteur_speed / d) - (o_cc.bb.g / 2) * ((d / o_cc.bb.limiteur_speed) + 1);
	c_a = 0;
}

if(miandry == true
&& collision_circle(x,y,sprite_width/2,o_cc.bb,1,0) < 0
&& point_distance(x,y,o_cc.bb.x,o_cc.bb.y) > 50){
	can_act = true;
	miandry = false;
}


// Interception passe ennemie : probabilité selon intercept_chance
var _bb_is_pass = variable_instance_exists(o_cc.bb, "is_pass") && o_cc.bb.is_pass;
var _bb_ic      = variable_instance_exists(o_cc.bb, "intercept_chance") ? o_cc.bb.intercept_chance : 0;
var _can_intercept = true;
if(_bb_is_pass && ekipa != o_cc.bb.e_pocesseur){
	// Ennemi tente d'intercepter une passe adverse
	_can_intercept = (random(100) < _bb_ic);
}

if(collision_circle(x,y,sprite_width/2,o_cc.bb,1,0) //test collision baolina
&& can_act == true && o_cc.bb.pocesseur == -1
&& (o_cc.bb.z>=z && o_cc.bb.z<= (z+alavany))
&& fanina == false
&& _can_intercept
&& (o_cc.basket_anim == false || id == o_cc.basket_player)){
	//o_cc.bb.pocesseur.is_me = false;
	
	o_cc.bb.pocesseur = id;
	if(ekipa == 1){
		o_cc.bb.e_pocesseur = 1;
		for (var i = 0; i < 5; ++i) {//desactiver is me
			o_cc.eq1[i].is_me = false;
			o_cc.eq1[i].miandry_passe = false;
			global.is_me1 = id;
		}
	}else if(ekipa == 2){
		o_cc.bb.e_pocesseur = 2;
		for (var i = 0; i < 5; ++i) {//desactiver is me
			o_cc.eq2[i].is_me = false;
			o_cc.eq2[i].miandry_passe = false;
			global.is_me2 = id;
		}
	}
	for(var i=0; i<5; ++i){
		o_cc.eq1[i].miandry_passe = false;
		o_cc.eq2[i].miandry_passe = false;
	}
	is_me = true;
	mbol = true;

	o_cc.bb.is_pass = false;
	o_cc.bb.intercept_chance = 0;

	// Exécuter le pre-move que j'avais programmé avant la réception
	if(pm_action != -1){
		c_a = count_act;
		if(pm_action == 1){ fire_tir   = true; jauge_tir   = pm_jauge; }
		else               { fire_passe = true; jauge_passe = pm_jauge; }
	}
	pm_action = -1; pm_jauge = 0; pm_target = -1;

	// Saut automatique à la réception si ennemi très proche
	// Pas de saut si pre-move va tirer/passer immédiatement (évite le sautillement)
	if(!is_jumping && pm_action == -1){
		var _catch_team = (ekipa == 1) ? o_cc.eq2 : o_cc.eq1;
		for(var _ci = 0; _ci < 5; ++_ci){
			var _cd = point_distance(x, y, _catch_team[_ci].x, _catch_team[_ci].y);
			if(_cd < 55){
				is_jumping = true;
				jump_vz = lerp(5, 2.5, _cd / 55);
				break;
			}
		}
	}
}


if(collision_circle(x,y,sprite_width/2,o_cc.bb,1,0) //mangalatra baolina (cas an'ilay olona mangalatra)
&& can_act == true && o_cc.bb.e_pocesseur != ekipa
&& (o_cc.bb.z>=z && o_cc.bb.z<= (z+alavany))
&& act1 == true && can_act1 = true
&& o_cc.basket_anim == false){
	
	can_pass = false;
	can_act1 = false;
	if(o_cc.bb.pocesseur != -1 && instance_exists(o_cc.bb.pocesseur)){
		o_cc.bb.pocesseur.fanina  = true;
		o_cc.bb.pocesseur.mbol    = false;
		o_cc.bb.pocesseur.miandry = true;
	}
	o_cc.bb.pocesseur = -1;
	
	if(ekipa == 1){
		o_cc.bb.e_pocesseur = 1;
		for (var i = 0; i < 5; ++i) {//desactiver is me
			o_cc.eq1[i].is_me = false;
			o_cc.eq1[i].miandry_passe = false;
			global.is_me1 = id;
			//o_cc.eq1[i].speed = 0;
			
		}
	}else if(ekipa == 2){
		o_cc.bb.e_pocesseur = 2;
		for (var i = 0; i < 5; ++i) {//desactiver is me
			o_cc.eq2[i].is_me = false;
			o_cc.eq2[i].miandry_passe = false;
			global.is_me2 = id;
			//o_cc.eq2[i].speed = 0;
		}
	}
	for(var i=0; i<5; ++i){
		o_cc.eq1[i].miandry_passe = false;
		o_cc.eq2[i].miandry_passe = false;
	}
	is_me = true;
	mbol = true;
	c_a1 = 0;
}


// Collision physique joueur-joueur : séparation radiale mutuelle (toutes équipes)
// Chaque joueur se repousse s'il chevauche un autre — crée l'effet "bounce/bousculade"
var _col_r = 22;  // rayon de collision joueur (pixels)
for(var _coli = 0; _coli < 5; ++_coli){
	var _co1 = o_cc.eq1[_coli];
	var _co2 = o_cc.eq2[_coli];
	var _colist = [_co1, _co2];
	for(var _coj = 0; _coj < 2; ++_coj){
		var _co = _colist[_coj];
		if(!instance_exists(_co) || _co == self) continue;
		var _cd = point_distance(x, y, _co.x, _co.y);
		if(_cd < _col_r && _cd > 0.5){
			// Pousser self dans la direction opposée à _co
			var _pdir = point_direction(_co.x, _co.y, x, y);
			var _pamt = (_col_r - _cd) * 0.45;
			x += lengthdir_x(_pamt, _pdir);
			y += lengthdir_y(_pamt, _pdir);
		}
	}
}

//COMPTEUR
if(fanina == true){
	if(c_f < count_fanina){
		c_f = c_f+(1*global.time);
	}else{
		fanina = false;
	}
}

if(c_a < count_act){
	c_a = c_a+(1*global.time);
}

if(can_pass == false){
	if(c_p < count_pass){
	c_p = c_p+(1*global.time);
	}else{
		can_pass = true;
	}
}

if(can_act1 == false){
	if(c_a1 < count_act1){
		c_a1 = c_a1+(1*global.time);
	}else{
		can_act1 = true;
	}
}

// Physique du saut
if(is_jumping){
	jump_vz -= 0.25 * global.time;  // gravité légère
	z += jump_vz * global.time;
	if(z <= z_ground){
		z          = z_ground;
		jump_vz    = 0;
		is_jumping = false;
	}
} else {
	z = z_ground;
}

// === AVANCEMENT DU TEMPS D'ANIMATION ===
var _moving = (speed > 0.5 || abs(haxis) > 0.1 || abs(vaxis) > 0.1);
anim_current = _moving ? "run" : "idle";
if (variable_global_exists("char_fk") && variable_struct_exists(global.anim_lib, anim_current)) {
    var _alen = global.anim_lib[$ anim_current].length;
    anim_time = (anim_time + global.time / _alen) mod 1.0;
}
