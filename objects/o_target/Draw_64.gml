/// @description Insérez la description ici
// Vous pouvez écrire votre code dans cet éditeur
if(camera_libre){

	draw_set_color(c_green);
	draw_set_alpha(1);
	draw_text_transformed(room_width - 120, 60, "camera libre", 0.7, 0.7, 0);
	draw_set_color(c_white);
	draw_text_transformed(room_width - 120, 80, "x_cam="+string(o_cam.x), 0.7, 0.7, 0);
	draw_text_transformed(room_width - 120, 100, "y_cam="+string(o_cam.y), 0.7, 0.7, 0);
	draw_set_color(c_white);
}

