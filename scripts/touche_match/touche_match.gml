function touche_match() {
	var mandalo_touche = false;
	var mandalo_tactile = false;
	//KEYBOARD player 1 et player 2
	if(keyboard_check((key_direction[0])) == true
	){
		up = true;mandalo_touche=true;
	}else if(keyboard_check((key_direction[0])) == false){
		up = false;
	}

	if(keyboard_check((key_direction[1])) == true
	){
		down = true;mandalo_touche=true;
	}else if(keyboard_check((key_direction[1])) == false
	){
		down = false;
	}

	if(keyboard_check((key_direction[2])) == true
	){
		left = true;mandalo_touche=true;
	}else if(keyboard_check((key_direction[2])) == false){
		left = false;
	}

	if(keyboard_check((key_direction[3])) == true
	){
		right = true;mandalo_touche=true;
	}else if(keyboard_check((key_direction[3])) == false
	){
		right = false;
	}

	if(keyboard_check((key_action[0])) == true
	){
		act1 = true;mandalo_touche=true;
		
	}else if(keyboard_check((key_action[0])) == false){
		act1 = false;
	}

	if(keyboard_check((key_action[1])) == true){
		act2 = true;mandalo_touche=true;
	}else if(keyboard_check((key_action[1])) == false){
		act2 = false;
	}
	
	

	//INTERFACE TACTILE
	
	if(ekipa == 1 && o_cam.button_analogue == true && mandalo_touche == false && mandalo_tactile == false){
		dir = point_direction(o_cam.x_analogue_b,o_cam.y_analogue_b,o_cam.x_analogue_r,o_cam.y_analogue_r);
		mandalo_tactile = true;
	}

	if(ekipa == 1 && o_cam.button_action1 == true && mandalo_touche == false && mandalo_tactile == false){
		act1 = true;
		mandalo_tactile = true;
	}else if(o_cam.button_action1 == false && mandalo_touche == false && mandalo_tactile == false){
		act1 = false;
	}
	
	if(ekipa == 1 && o_cam.button_action2 == true && mandalo_touche == false && mandalo_tactile == false){
		act2 = true;
		mandalo_tactile = true;
	}else if(o_cam.button_action2 == false && mandalo_touche == false && mandalo_tactile == false){
		act2 = false;
	}
	
	

	//GAME PAD player 1
	if(ekipa == 1 && mandalo_tactile == false && mandalo_touche == false){ //ANALOGUE
		haxis = gamepad_axis_value(global.gp1, gp_axislh);
		vaxis = gamepad_axis_value(global.gp1, gp_axislv);
		dir = point_direction(0, 0, haxis, vaxis);
	}

	if(ekipa == 1  && mandalo_tactile == false && mandalo_touche == false){ //TOUCHE DIRECTIONNELLE
			if(
			gamepad_button_check(global.gp1,gp_padu) == true 
		){
			up = true;
		}else if(
			gamepad_button_check(global.gp1,gp_padu) == false){
			up = false;
		}

		if(
		gamepad_button_check(global.gp1,gp_padd) == true
		){
			down = true;
		}else if(
		gamepad_button_check(global.gp1,gp_padd) == false
		){
			down = false;
		}

		if(
		gamepad_button_check(global.gp1,gp_padl) == true
		){
			left = true;
		}else if(
		gamepad_button_check(global.gp1,gp_padl) == false){
			left = false;
		}

		if(
		gamepad_button_check(global.gp1,gp_padr) == true
		){
			right = true;
		}else if(
		gamepad_button_check(global.gp1,gp_padr) == false
		){
			right = false;
		}

		if(
		gamepad_button_check(global.gp1,gp_face1) == true
		){
			act1 = true;
		}else if(
		gamepad_button_check(global.gp1,gp_face1) == false
		){
			act1 = false;
		}

		if(
		gamepad_button_check(global.gp1,gp_face2) == true){
			act2 = true;
		}else if(
		gamepad_button_check(global.gp1,gp_face2) == false){
			act2 = false;
		}
	}
}

