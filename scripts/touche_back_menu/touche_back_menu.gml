function touche_back_menu() {
	if(o_control_menu.can_press == true){
		if(room != r_menu3 || (room == r_menu3 && global.playerNumber == 1)){
			if(keyboard_check_pressed((global.player1[5])) == true
				|| keyboard_check_pressed((global.player2[5])) == true
				|| keyboard_check_pressed(vk_escape) == true
				|| gamepad_button_check_pressed(global.gp1,gp_face2) == true
				|| gamepad_button_check_pressed(global.gp2,gp_face2) == true)
			{
					return true;
			}else if(keyboard_check_pressed((global.player1[5])) == false
				|| keyboard_check_pressed((global.player2[5])) == false
				|| keyboard_check_pressed(vk_escape) == false
				|| gamepad_button_check_pressed(global.gp1,gp_face2) == false
				|| gamepad_button_check_pressed(global.gp2,gp_face2) == false)
			{
				return false;
			}
		}
		else if (room == r_menu3 && global.playerNumber == 2){
			if(mini_id == 4 || mini_id == 0 ){
				if(keyboard_check_pressed((global.player1[5])) == true
				|| gamepad_button_check_pressed(global.gp1,gp_face2) == true)
				{
					return true;
				}else if(keyboard_check_pressed((global.player1[5])) == false
				|| gamepad_button_check_pressed(global.gp1,gp_face2) == false)
				{
					return false;
				}
			}else if (mini_id == 5 || mini_id == 1){
				if(keyboard_check_pressed((global.player2[5])) == true
					|| gamepad_button_check_pressed(global.gp2,gp_face2) == true)
				{
					return true;
				}else if(keyboard_check_pressed((global.player2[5])) == false
				|| gamepad_button_check_pressed(global.gp2,gp_face2) == false)
				{
					return false;
				}
			}
		}
	}


}
