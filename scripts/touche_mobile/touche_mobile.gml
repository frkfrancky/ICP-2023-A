/// scrCheckPress(device,x1,y1,x2,y2);
function touche_mobile(argument0) {

	device = argument0;

	if(device_mouse_y_to_gui(device) == clamp(device_mouse_y_to_gui(device),y_analogue-r_analogue,y_analogue+r_analogue)){								// check to see if the mouse is within the y button area
		if(device_mouse_x_to_gui(device) == clamp(device_mouse_x_to_gui(device),(x_analogue-100)-r_analogue,(x_analogue+100)+r_analogue)){				// check if it is in the left button
				// left
				d_analogue = device;
				button_pressed = true;																												// highlight buttons
				button_analogue = true;	
				//show_message("left");			// activate button
		}
	}
	
	if(device_mouse_y_to_gui(device) == clamp(device_mouse_y_to_gui(device),y_action1-r_actions,y_action1+r_actions)){								// check to see if the mouse is within the y button area
		if(device_mouse_x_to_gui(device) == clamp(device_mouse_x_to_gui(device),(x_action1-100)-r_actions,(x_action1+100)+r_actions)){				// check if it is in the left button
				// left
				d_action1 = device;
				button_pressed = true;																												// highlight buttons
				button_action1 = true;
		}
	}
	
	if(device_mouse_y_to_gui(device) == clamp(device_mouse_y_to_gui(device),y_action2-r_actions,y_action2+r_actions)){								// check to see if the mouse is within the y button area
		if(device_mouse_x_to_gui(device) == clamp(device_mouse_x_to_gui(device),(x_action2-100)-r_actions,(x_action2+100)+r_actions)){				// check if it is in the left button
				// left
				d_action2 = device;
				button_pressed = true;																												// highlight buttons
				button_action2 = true;
		}
	}


}
