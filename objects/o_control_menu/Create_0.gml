touche();

//var camera= camera_get_active();
window_set_size(1280,720);
window_center();
window_set_color(c_black);
is_fullscreen = false;

can_press = true;


refmenu_x = 0;
refmenu_y = 50;






//TEXT SLIDING
my_os = 0;
if(os_type == os_windows){
	my_os = "windows";
}else if (os_type == os_android){
	my_os = "android";
}



	v_sliding = 2;
	nbr_text = 3;
	slide_space = 150;
	slide_color = #333333;

	text_sliding[0] = "Version Pre-Alpha du jeu, votre machine est: "+my_os+", version: "+string(os_version);
	text_sliding[1] = "Publicité numero 0000, test deuxieme texte de l'affichage 22222";
	text_sliding[2] = "Affichage 3 , test test test test";

	/*
	text_sliding[0] = "aaa";
	text_sliding[1] = "222";
	text_sliding[2] = "iii";*/
	

	x_sliding[0] = -10000;
	x_sliding[1] = -10000;
	x_sliding[2] = -10000;
	
	w_sliding[0] = x_sliding[0]+string_width(text_sliding[0])+slide_space;
	w_sliding[1] = x_sliding[1]+string_width(text_sliding[1])+slide_space;
	w_sliding[2] = x_sliding[2]+string_width(text_sliding[2])+slide_space;

	


