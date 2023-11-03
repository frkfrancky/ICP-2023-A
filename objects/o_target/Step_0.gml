
if(camera_libre == false){
	y = y_dep;
	acc = abs(o_cc.bb.x - x)/10;

	if(x < o_cc.bb.x){
		x+= 1*acc;
	}

	if(x > o_cc.bb.x){
		x-= 1*acc;
	}
}else{
	if(keyboard_check(vk_numpad4)){
		x-= 5;
	}else if(keyboard_check(vk_numpad6)){
		x+= 5;
	}else if(keyboard_check(vk_numpad8)){
		y-= 5;
	}else if(keyboard_check(vk_numpad2)){
		y+= 5;
	}else if(keyboard_check(vk_numpad7)){
		direction += 1;
	}else if(keyboard_check(vk_numpad9)){
		direction -= 1;
	}else if(keyboard_check(vk_numpad1)){
		o_cam.fov_y +=1;
	}else if(keyboard_check(vk_numpad3)){
		if(o_cam.fov_y>=2){
			o_cam.fov_y -=1;
		}
	}
	
	image_angle = direction;
	var d = abs(point_distance(x,y,o_cam.x,o_cam.y));
	o_cam.x = x+lengthdir_x(d,direction);
	o_cam.y = y+lengthdir_y(d,direction);
	/*o_cam.x = x+d*cos(direction);
	o_cam.y = y+d*sin(direction);*/
}
