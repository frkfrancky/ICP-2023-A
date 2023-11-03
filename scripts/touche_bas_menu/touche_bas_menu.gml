function touche_bas_menu() {
	if(o_control_menu.can_press == true){
		if((room != r_menu3 && room != r_menu4) || (room == r_menu3 && global.playerNumber == 1)
			|| (room == r_menu4 && global.playerNumber == 1) ){
			if(keyboard_check_pressed((global.player1[1])) == true
			|| keyboard_check_pressed((global.player2[1])) == true
			|| keyboard_check_pressed(vk_down) == true
			|| gamepad_button_check_pressed(global.gp1,gp_padd) == true
			|| gamepad_button_check_pressed(global.gp2,gp_padd) == true)
			{
				return true;
			}else if(keyboard_check_pressed((global.player1[1])) == false
			|| keyboard_check_pressed((global.player2[1])) == false
			|| keyboard_check_pressed(vk_down) == false
			|| gamepad_button_check_pressed(global.gp1,gp_padd) == false
			|| gamepad_button_check_pressed(global.gp2,gp_padd) == false)
			{
				return false;
			}
		}else if (room == r_menu3 && global.playerNumber == 2){
			if(mini_id == 4 || mini_id == 0 ){
				if(keyboard_check_pressed((global.player1[1])) == true
				|| gamepad_button_check_pressed(global.gp1,gp_padd) == true)
				{
					return true;
				}else if(keyboard_check_pressed((global.player1[1])) == false
				|| gamepad_button_check_pressed(global.gp1,gp_padd) == false)
				{
					return false;
				}
			}else if (mini_id == 5 || mini_id == 1){
				if(keyboard_check_pressed((global.player2[1])) == true
				|| gamepad_button_check_pressed(global.gp2,gp_padd) == true)
				{
					return true;
				}else if(keyboard_check_pressed((global.player2[1])) == false
				|| gamepad_button_check_pressed(global.gp2,gp_padd) == false)
				{
					return false;
				}
			}
		}else if (room == r_menu4 && global.playerNumber == 2){
			if(mini_id == 0){
				if(keyboard_check_pressed((global.player1[1])) == true
				|| gamepad_button_check_pressed(global.gp1,gp_padd) == true)
				{
					return true;
				}else if(keyboard_check_pressed((global.player1[1])) == false
				|| gamepad_button_check_pressed(global.gp1,gp_padd) == false)
				{
					return false;
				}
			}else if (mini_id == 1){
				if(keyboard_check_pressed((global.player2[1])) == true
				|| gamepad_button_check_pressed(global.gp2,gp_padd) == true)
				{
					return true;
				}else if(keyboard_check_pressed((global.player2[1])) == false
					|| gamepad_button_check_pressed(global.gp2,gp_padd) == false)
				{
					return false;
				}
			}
		}
	}


}
