//steep 
// process on screen button presses
for(i=0;i<4;i++){																			// loop through available mouse devices
	if(device_mouse_check_button(i,mb_left)){												// check if the device is being pressed
		touche_mobile(i);																	// process that device
	}
}

if(button_analogue == true){
	if(abs(point_distance(x_analogue_r,y_analogue_r,x_analogue_b,y_analogue_b))>64){
		x_analogue = lengthdir_x(64,point_direction(x_analogue_b,y_analogue_b,x_analogue_r,y_analogue_r))+x_analogue_b;
		y_analogue = lengthdir_y(64,point_direction(x_analogue_b,y_analogue_b,x_analogue_r,y_analogue_r))+y_analogue_b;
	}else{
		x_analogue = x_analogue_r;
		y_analogue = y_analogue_r;
	}
		

	x_analogue_r = device_mouse_x(d_analogue);
	y_analogue_r = device_mouse_y(d_analogue);
}

// reset all buttons when any have been let go
if((device_mouse_check_button_released(0,mb_left)) || (device_mouse_check_button_released(1,mb_left))  || (device_mouse_check_button_released(2,mb_left))  || (device_mouse_check_button_released(3,mb_left)) ){
//if(device_mouse_check_button_released(d_analogue,mb_left)){
	button_analogue = false;
	d_analogue = -1;
	x_analogue = x_analogue_b;
	y_analogue = y_analogue_b;
	x_analogue_r = x_analogue_b;
	y_analogue_r = y_analogue_b;
	
	button_pressed = false;
	button_down_left = false;
	button_down_right = false;
	button_down_up = false;
	button_down_down = false;	
	
	button_action1 = false;
	button_action2 = false;
}

// Proxy o_match_camera lighting and shader variables for match gameplay
if (instance_exists(o_match_camera)) {
	lit_dir = o_match_camera.lit_dir;
	lit_color = o_match_camera.lit_color;
	lit_amb = o_match_camera.lit_amb;
	lit_rim = o_match_camera.lit_rim;
	u_ldir = o_match_camera.u_ldir;
	u_lcol = o_match_camera.u_lcol;
	u_lamb = o_match_camera.u_lamb;
	u_lrim = o_match_camera.u_lrim;
	u_pl0 = o_match_camera.u_pl0;
	u_pl1 = o_match_camera.u_pl1;
	u_pl0col = o_match_camera.u_pl0col;
	u_pl1col = o_match_camera.u_pl1col;
	u_pl2 = o_match_camera.u_pl2;
	u_pl2col = o_match_camera.u_pl2col;
	u_pl2rad = o_match_camera.u_pl2rad;
	u_plcol = o_match_camera.u_plcol;
	u_plrad = o_match_camera.u_plrad;
	u_sprpos = o_match_camera.u_sprpos;
	u_flat_normal = o_match_camera.u_flat_normal;
}
