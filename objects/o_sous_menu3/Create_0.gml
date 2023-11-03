left_spr =0;
top_spr =0;
text = "";
afficher = e1;
data = 0;
data2 = 0;
anim_start = true;
mini_id = -1;
image_alpha = 0;

if(x < 528){//menu 3
	text = get_name_team_by_id(global.equipe1) ;
	afficher = get_profile_team_by_id(global.equipe1);
}else{
	text = get_name_team_by_id(global.equipe2) ;
	afficher = get_profile_team_by_id(global.equipe2);
}
