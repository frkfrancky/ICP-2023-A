function test_gamepade() {
	var gp_num = gamepad_get_device_count();
	
	for (var i = 0; i < gp_num; i++;)
	   {	
		   
		   if(gamepad_is_connected(i)){
				if(gamepad_is_connected(global.gp1)==false){
					global.gp1 = i;
					//show_message("gamepad 1 connected - " + string(global.gp1))
				}
				
				if(gamepad_is_connected(global.gp1)==true && gamepad_is_connected(global.gp2)==false && i != global.gp1){
					global.gp2 = i;
					//show_message("gamepad 2 connected - " + string(global.gp2))
				}
		   }
	   }
	   
	

}
