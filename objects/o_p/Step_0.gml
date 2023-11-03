
if(is_me){
	touche_match();
	
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
		//is_me = true;
		if(o_cc.bb.z <= o_cc.bb.z_tany){
			o_cc.bb.limiteur_z = 6;
		}
		
		o_cc.bb.x = x+lengthdir_x(16,direction);
		o_cc.bb.y = y+lengthdir_y(16,direction);

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

if(is_me == false){//IA + tactic
	image_angle = direction;
	
	if(ekipa == 1){
			var d_x = o_cc.tt1[point_tt].x+(random_range(-o_cc.tt1[point_tt].rayon,-o_cc.tt1[point_tt].rayon));
			var d_y = o_cc.tt1[point_tt].y+(random_range(-o_cc.tt1[point_tt].rayon,-o_cc.tt1[point_tt].rayon));;
			dest_x = d_x;
			dest_y = d_y;
			dir = point_direction(x,y,dest_x,dest_y);
	}
	if(ekipa == 2){
			var d_x = o_cc.tt2[point_tt].x+(random_range(-o_cc.tt2[point_tt].rayon,-o_cc.tt2[point_tt].rayon));
			var d_y = o_cc.tt2[point_tt].y+(random_range(-o_cc.tt2[point_tt].rayon,-o_cc.tt2[point_tt].rayon));;
			dest_x = d_x;
			dest_y = d_y;
			dir = point_direction(x,y,dest_x,dest_y);
	}
	
	if(point_distance(x,y,dest_x,dest_y) > 10){
		if(limiteur_speed > sp*global.time){
			limiteur_speed -= acc*global.time;
		}else
		if(limiteur_speed < sp*global.time){
			limiteur_speed += acc*global.time;
		}
	}else{
		speed = 0;
	}
	
	if(angle_difference(dir,direction)>0){
		direction += ((tec*global.time)/1);
	}else if(angle_difference(dir,direction)<0){
		direction -= ((tec*global.time)/1);
	}
}

if(act1 == true && mbol == true && c_a >= count_act){//passe
	can_act = false;
	miandry = true;
	mbol = false;
	o_cc.bb.pocesseur = -1;
	var target = 0;
	if(ekipa == 1){
		o_cc.bb.direction = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.ak1.x,o_cc.ak1.y);
		o_cc.ak1.miandry_passe = true;
		target = o_cc.ak1;
	}else if(ekipa == 2){
		o_cc.bb.direction = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.ak2.x,o_cc.ak2.y);
		o_cc.ak2.miandry_passe = true;
		target = o_cc.ak2;
	}
	
	o_cc.bb.x = x+lengthdir_x(16+15,o_cc.bb.direction);//repositionner ballon
	o_cc.bb.y = y+lengthdir_y(16+15,o_cc.bb.direction);
	
	o_cc.bb.z = 50;
	o_cc.bb.limiteur_speed = 7;
	o_cc.bb.limiteur_z = 5;
	var d = point_distance(o_cc.bb.x,o_cc.bb.y,target.x,target.y);
	if(d < 100){
		o_cc.bb.limiteur_speed = 5;
		o_cc.bb.limiteur_z = 5;
	}else{
		
	}
	//show_message(string(d))
	//o_cc.bb.speed = 7;
	c_a = 0;
}

if(act2 == true && mbol == true && c_a >= count_act){//tir
	can_act = false;
	miandry = true;
	mbol = false;
	o_cc.bb.pocesseur = -1;
	o_cc.bb.mpamono = self;
	last_3pt = pt3s;
	
	var d = 0;
	if(ekipa == 1){
		o_cc.bb.direction = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.but2.x,o_cc.but2.y);
		d = point_distance(o_cc.bb.x,o_cc.bb.y,o_cc.but2.x,o_cc.but2.y);
	}else if(ekipa == 2){
		o_cc.bb.direction = point_direction(o_cc.bb.x,o_cc.bb.y,o_cc.but1.x,o_cc.but1.y);
		d = point_distance(o_cc.bb.x,o_cc.bb.y,o_cc.but1.x,o_cc.but1.y);
	}
	
	o_cc.bb.z = alavany+1;
	
	o_cc.bb.limiteur_speed = (d*6.5)/273;
	o_cc.bb.limiteur_z = (-o_cc.but2.z - (o_cc.bb.z))*(o_cc.bb.limiteur_speed/d) - ((o_cc.bb.g) / 2)*((d/o_cc.bb.limiteur_speed)+1);
	//o_cc.bb.speed = 7;
	c_a = 0;

}

if((collision_circle(x,y,sprite_width/2,o_cc.bb,1,0) < 0 && miandry == true)
	|| ((o_cc.bb.z>=z && o_cc.bb.z<= (z+alavany)) && miandry == true) ){
	can_act = true;
	miandry = false;
}

if(collision_circle(x,y,sprite_width/2,o_cc.bb,1,0) 
&& can_act == true && o_cc.bb.pocesseur == -1
&& (o_cc.bb.z>=z && o_cc.bb.z<= (z+alavany))){//test collision baolina
	//o_cc.bb.pocesseur.is_me = false;
	
	o_cc.bb.pocesseur = id;
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
}

if(c_a < count_act){
	c_a++;
}

