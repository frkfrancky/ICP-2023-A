if(z > z_tany){
	limiteur_z += g*global.time;
}else if(z < z_tany){
	if(mety_maty == false){
		mety_maty = true;
	}
	z = z_tany;
	limiteur_z = abs(limiteur_z)/1.3;
	
	//frottement amin'ny tany
	if(limiteur_speed>0){
		limiteur_speed -= frot*global.time;
	}else if(limiteur_speed<0){
		limiteur_speed += frot*global.time;
	}
	z = z_tany+1;
}

z += z_speed;

z_speed = limiteur_z*global.time;
speed = limiteur_speed*global.time;


// maty le baolina
{
	var t_maty = 4; // niveau de tolerance

	if(point_distance_3d(x,y,z,o_cc.but2.x,o_cc.but2.y,-o_cc.but2.z)<t_maty){
		x = o_cc.but2.x;
		y = o_cc.but2.y;
		limiteur_speed = 0;
		if(mety_maty == true){
			if(mpamono.last_3pt == true){
				global.but_eq1 += 3;
			}else{
				global.but_eq1 += 2;
			}
		
		}
		mety_maty = false;
		e_pocesseur = 2;
	}
	if(point_distance_3d(x,y,z,o_cc.but1.x,o_cc.but1.y,-o_cc.but1.z)<t_maty){
		x = o_cc.but1.x;
		y = o_cc.but1.y;
		limiteur_speed = 0;
		if(mety_maty == true){
			if(mpamono.last_3pt == true){
				global.but_eq2 += 3;
			}else{
				global.but_eq2 += 2;
			}
		}
		mety_maty = false;
		e_pocesseur = 1;
	}
}

//Mitady ho faty
if(point_distance_3d(x,y,z,o_cc.but2.x,o_cc.but2.y,-o_cc.but2.z)<64){
	global.time = 0.3;
	if(o_cam.fov_y > 27){
		o_cam.fov_y -= 0.5;
	}
	
	
	if(o_cam.z_target > 3){
		o_cam.zt_p -= 0.3;
	}
	
}else{
	global.time = 1;
	if(o_cam.fov_y < 35){
		o_cam.fov_y += 0.1;
	}
	if(o_cam.z_target < 16){
		o_cam.zt_p += 0.1;
	}
	
}


//3d set /////////////////////////////
	//
im_angle_3d = point_direction(o_cam.x,o_cam.y,x,y)-180;
	//
vBuffTop = vertex_create_buffer();

vertex_begin(vBuffTop, global.vFormat);

var aal = 5;
var aal2 = 20;//20

var xx1 = x+lengthdir_x(aal,im_angle_3d+90);
var yy1 = y+lengthdir_y(aal,im_angle_3d+90);
var xx2 = x+lengthdir_x(aal,im_angle_3d+270);
var yy2 = y+lengthdir_y(aal,im_angle_3d+270);

vertex_create_face(vBuffTop,
	new Vec3 (xx1, yy1, z +aal2),
	new Vec3 (xx2, yy2, z +aal2),
	new Vec3 (xx2, yy2, z),
	new Vec3 (xx1, yy1, z),
	c_white, 1);
	
/*
new Vec3 (x-5, y, z +20),
	new Vec3 (x-5+10, y, z +20),
	new Vec3 (x-5+10, y,z),
	new Vec3 (x-5, y, z),
	*/

vertex_end(vBuffTop);
vertex_freeze(vBuffTop);
//3d end //////////////////////////////

//3d set /////////////////////////////
vBuffTop2 = vertex_create_buffer();

vertex_begin(vBuffTop2, global.vFormat);

vertex_create_face(vBuffTop2,
	new Vec3 (x-5, y, z +20),
	new Vec3 (x-5+10, y, z +20),
	new Vec3 (o_cc.but2.x, o_cc.but2.y, -o_cc.but2.z),
	new Vec3 (o_cc.but2.x-5, o_cc.but2.y, -o_cc.but2.z),
	c_white, 1);

vertex_end(vBuffTop2);
vertex_freeze(vBuffTop2);
//3d end //////////////////////////////
