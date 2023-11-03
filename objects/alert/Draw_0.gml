if(load == true){
	swal();
}

draw_self();
draw_set_color($4C4C4C);
draw_set_valign(fa_middle);
draw_set_halign(fa_center);
draw_set_alpha(alpha2);
draw_text_transformed(x,y,"loading data ...",0.75,0.75,0);
image_alpha = alpha2;
if(load == false){
	o_control_menu.can_press = true;
	instance_destroy(self);
}
