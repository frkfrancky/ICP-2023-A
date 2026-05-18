depth = -5;
image_speed = 0;

is_pressed = false;
is_focus = true;
//choix = 0;//sous menu na sous room am room 3
mini_id = -1;
debut = false;
can_press = true;
anim_start = true;
image_alpha = 0;

is_ready = false;

time_presse = 0;
time_presse2 = 0;
enfonce_bas = false;
enfonce_haut = false;
espacement = 0;
espacement2 = 0;


drag_offsetY = 0;
index_focused = 0;

if(room == r_menu1){
	for (var i = 0; i < 7; ++i) {
	    bt[i] = instance_create_depth(x+16, y+global.e_bt+(i*96), -6, o_bt);
		bt[i].mini_id = i;
		bt[i].image_alpha = 0;
	}
	bt[0].soratra = "Match Rapide";    bt[0].ico = icm1;
	bt[1].soratra = "Championnat";     bt[1].ico = icm1;
	bt[2].soratra = "Paramètres";      bt[2].ico = icm6;
	bt[3].soratra = "Crédit";          bt[3].ico = icm5;
	bt[4].soratra = "Demo test";       bt[4].ico = icm3;
	bt[5].soratra = "Outils";          bt[5].ico = icm3;
	bt[6].soratra = "Exit";            bt[6].ico = icm2;
}
if(room == r_menu2){
	for (var i = 0; i < 3; ++i) {
	    bt[i] = instance_create_depth(x+16, y+16+(i*96), -6, o_bt);
		bt[i].mini_id = i;
		bt[i].image_alpha = 0;
	}
	bt[0].soratra = "One player";	bt[0].ico = icm1;
	bt[1].soratra = "Two player";	bt[0].ico = icm1;
	bt[2].soratra = "Back";			bt[0].ico = icm4;
}
if(room == r_menu3){
	is_set1 = false;
	is_set2 = false;

}
if(room == r_menu5){
	for (var i = 0; i < 2; ++i) {
	    bt[i] = instance_create_depth(x+16, y+global.e_bt+(i*96), -6, o_bt);
		bt[i].mini_id = i;
		bt[i].image_alpha = 0;
	}
	bt[0].soratra = "Terrain 1";  bt[0].ico = icm3; bt[0].soratra2 = "Terrain disponible";
	bt[1].soratra = "Retour";     bt[1].ico = icm4;
}
if(room == r_outils){
	for (var i = 0; i < 3; ++i) {
	    bt[i] = instance_create_depth(x+16, y+global.e_bt+(i*96), -6, o_bt);
		bt[i].mini_id = i;
		bt[i].image_alpha = 0;
	}
	bt[0].soratra = "Éditeur Anim";  bt[0].ico = icm3;
	bt[1].soratra = "Éditeur Niveau"; bt[1].ico = icm3;
	bt[2].soratra = "Retour";         bt[2].ico = icm4;
}


