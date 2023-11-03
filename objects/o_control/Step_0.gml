//steep 
// process on screen button presses
for(i=0;i<4;i++){																			// loop through available mouse devices
	if(device_mouse_check_button(i,mb_left)){												// check if the device is being pressed
		scrCheckPress(i);																	// process that device
	}
}

// reset all buttons when any have been let go
if((device_mouse_check_button_released(0,mb_left)) || (device_mouse_check_button_released(1,mb_left))  || (device_mouse_check_button_released(2,mb_left))  || (device_mouse_check_button_released(3,mb_left)) ){
	button_pressed = false;
	button_down_left = false;
	button_down_right = false;
	button_down_up = false;
	button_down_down = false;
}
