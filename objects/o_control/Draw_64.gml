
//draw_text(10,10,string(x));
draw_text(10,30,string(m));
draw_text(400,30,string(button_down_left));
draw_text(400,50,string(button_down_jump));
draw_text(400,70,string(button_down_right));
draw_text(400,90,string(button_down_down));
draw_text(400,110,string(button_down_up));

// on screen controls
draw_set_colour(c_white);											// set the button colour
draw_set_alpha(button_a);											// set alpha
draw_circle(button_x_left,button_y,button_r,false);					// draw left button
draw_circle(button_x_right,button_y,button_r,false);				// draw right button
draw_roundrect(button_x1,button_y1_up,button_x2,button_y2_up,false);		// draw up button
draw_roundrect(button_x1,button_y1_down,button_x2,button_y2_down,false);	// draw down button
draw_circle(button_x_jump,button_y,button_r,false);					// draw jump button
draw_set_alpha(1);	