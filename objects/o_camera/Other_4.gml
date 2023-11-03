repere_terrain_y = 192;
//mandalo_v = "tsia";
//perso
perso[0] = instance_create_depth(600,500,0,o_perso);
perso[1] = instance_create_depth(500,590,0,o_perso);
perso[2] = instance_create_depth(664,364,0,o_perso);//perso[2].possesseur=true;perso[2].can_poss=false;
perso[3] = instance_create_depth(300,364,0,o_perso);
perso[4] = instance_create_depth(696,400,0,o_perso);


for (var i = 0; i < 5; ++i) {
    perso[i].mini_id = i;
	perso[i].equipe = 0;
	perso[i].next_pass = false;
}

perso[0].is_player = true;

//accesoires
bal = instance_create_depth(800,300,0,o_ombre_ballon);

//passe:
possesseur_mini_id = -1;
proche1 = 1;
//proche2 = 6;
