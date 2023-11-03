if(is_player){
	if(keyboard_check(ord(key_direction[0]))==true){
		if(keyboard_check(ord(key_direction[2]))==false 
		&& keyboard_check(ord(key_direction[3]))==false){
			vspeed = -sp;
		}else if(keyboard_check(ord(key_direction[2]))==false 
		|| keyboard_check(ord(key_direction[3]))==false){
			vspeed = -sp*sin(45);
		}
	}else if(keyboard_check(ord(key_direction[1]))==true){
		if(keyboard_check(ord(key_direction[2]))==false 
		&& keyboard_check(ord(key_direction[3]))==false){
			vspeed = sp;
		}else if(keyboard_check(ord(key_direction[2]))==false 
		|| keyboard_check(ord(key_direction[3]))==false){
			vspeed = sp*sin(45);
		}
	}else if(keyboard_check(ord(key_direction[0]))==false 
			|| keyboard_check(ord(key_direction[1]))==false){
		vspeed = 0;
	}
	if(keyboard_check(ord(key_direction[2]))==true){
		if(keyboard_check(ord(key_direction[0]))==false 
		&& keyboard_check(ord(key_direction[1]))==false){
			hspeed = -sp;
		}else if(keyboard_check(ord(key_direction[0]))==false 
		|| keyboard_check(ord(key_direction[1]))==false){
			hspeed = -sp*cos(45);
		}
	}else if(keyboard_check(ord(key_direction[3]))==true){
		if(keyboard_check(ord(key_direction[0]))==false 
		&& keyboard_check(ord(key_direction[1]))==false){
			hspeed = sp;
		}else if(keyboard_check(ord(key_direction[0]))==false 
		|| keyboard_check(ord(key_direction[1]))==false){
			hspeed = sp*cos(45);
		}
	}else if(keyboard_check(ord(key_direction[2]))==false 
			|| keyboard_check(ord(key_direction[3]))==false){
		hspeed = 0;
	}
	
	if(keyboard_check(ord(key_action[0]))==true && possesseur == true){
		alarm_set(0,20);
		possesseur = false;
		o_camera.bal.hspeed = pass_force;
		o_camera.bal.ballon.hspeed = pass_force;
		o_camera.bal.ballon.vspeed = -20;
		can_poss = false;
		o_camera.bal.is_drible = false;
		o_camera.proche1 = -1;
		//o_camera.bal.ballon.phy_angular_velocity = 180;
	}
	
	if(keyboard_check(ord(key_action[1]))==true && possesseur == true){
		alarm_set(0,20);
		possesseur = false;
		o_camera.bal.direction = point_direction(x,y,o_camera.perso[o_camera.proche1].x,o_camera.perso[o_camera.proche1].y);
		o_camera.bal.speed = pass_force;

		/*o_camera.bal.ballon.hspeed = pass_force;
		o_camera.bal.ballon.vspeed = -10+(pass_force/2);;*/
		can_poss = false;
		o_camera.bal.is_drible = false;
		o_camera.proche1 = -1;
		//o_camera.bal.ballon.phy_angular_velocity = 180;
	}
	
	
}

//drible
	if(possesseur == true && can_poss == false && o_camera.bal.is_drible == true){
		o_camera.bal.hspeed = hspeed;
		o_camera.bal.vspeed = vspeed;
		o_camera.bal.ballon.hspeed = hspeed;
		o_camera.bal.ballon.vspeed = vspeed;
		o_camera.bal.x = x;
		o_camera.bal.y = y;
		if((o_camera.bal.y-o_camera.bal.ballon.y)<1 ){
			variation = -1;
		}else if((o_camera.bal.y-o_camera.bal.ballon.y)>=32){
			variation = 1;
		}
		o_camera.bal.ballon.y += variation*4;
	}

if(collision_circle(x,y,16,o_camera.bal.ballon,1,0) 
	&& (collision_depth(depth,o_camera.bal.ballon.depth)) 
		&& can_poss == true && possesseur == false
			&& o_camera.bal.can_poss == true){
		o_camera.bal.can_poss = false;
		o_camera.bal.is_drible = true;
		for (var i = 0; i < array_length_1d(o_camera.perso); ++i) {
			if(i == mini_id){
				is_player = true;
				possesseur = true;
				can_poss = false;
				o_camera.possesseur_mini_id = i;
			}else{
				o_camera.perso[i].is_player = false;
				o_camera.perso[i].possesseur = false;
				o_camera.perso[i].can_poss = true;
				o_camera.perso[i].speed = 0;
			}
		}		
}
if(o_camera.bal.is_drible == false){
	o_camera.possesseur_mini_id = -1;
}

depth = 192-y;
