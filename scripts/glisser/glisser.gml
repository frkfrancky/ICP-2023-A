function glisser(argument0) {
	device = argument0;
	if(device_mouse_y_to_gui(device) == clamp(device_mouse_y_to_gui(device),y,y+480)){								
		if(device_mouse_x_to_gui(device) == clamp(device_mouse_x_to_gui(device),x,x+448)){				
			is_pressed = true;																		
		}else{
			is_pressed = false;
		}
	}else{
			is_pressed = false;
		}


}
