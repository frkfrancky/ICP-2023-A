image_index = 0;
if(room == r_menu3){
	room_goto(r_menu2);
}if(room == r_terrain){
	room_goto(r_menu1);
}if(room == r_menu4 && is_focus == true){
	o_control_menu.mn[0].is_focus = false;
	o_control_menu.mn[1].is_focus = false;
	is_focus = false;
	mss = instance_create_depth(room_width/2,room_height/2+40,-100,confirm);
	mss.mpamorona = id;
}
