global.playerNumber = 1;

global.time = 1;

//variable pour le menu pause
is_pause = false;
create_pause = false;
menu_p = 0;

touche();
key = 0;
possesseur_ballon = -1;

//Equipe 1
for (var i = 0; i < 5; ++i) {
    eq1[i] = instance_create_depth(60,40+(i*40),-1,o_p);
	eq1[i].ekipa = 1;
	eq1[i].index = i;
	eq1[i].point_tt = i;
	eq1[i].key_direction[0] = global.player1[0];
	eq1[i].key_direction[1] = global.player1[1];
	eq1[i].key_direction[2] = global.player1[2];
	eq1[i].key_direction[3] = global.player1[3];

	eq1[i].key_action[0] = global.player1[4];
	eq1[i].key_action[1] = global.player1[5];
}
global.is_me1 = eq1[0];
eq1[0].is_me = true;
ak1 = eq1[1];

for (var i = 0; i < 5; ++i) {
    tt1[i] = instance_create_depth(120,40+(i*40),-1,o_point);
	tt1[i].index = i;
	tt1[i].ekipa = 1;
}

listako1 = ds_list_create(); //index anle olona



//Equipe 2
for (var i = 0; i < 5; ++i) {
    eq2[i] = instance_create_depth(500,40+(i*40),-1,o_p);
	eq2[i].ekipa = 2;
	eq2[i].index = i;
	eq2[i].image_index = 1;
	eq2[i].key_direction[0] = global.player2[0];
	eq2[i].key_direction[1] = global.player2[1];
	eq2[i].key_direction[2] = global.player2[2];
	eq2[i].key_direction[3] = global.player2[3];

	eq2[i].key_action[0] = global.player2[4];
	eq2[i].key_action[1] = global.player2[5];
}
global.is_me2 = eq2[0];
eq2[0].is_me = true;
ak2 = eq2[1];

for (var i = 0; i < 5; ++i) {
    tt2[i] = instance_create_depth(520,40+(i*40),-1,o_point);
	tt2[i].loko = c_yellow;
	tt2[i].index = i;
	tt2[i].ekipa = 2;
}

listako2 = ds_list_create(); //index anle olona


//baolina
bb = instance_create_depth(400, 200, -1, o_b);

but1 = instance_create_depth(o_tr.x+28, o_tr.y+250,-188, o_cerc);
but1.aniza = 1;
but2 = instance_create_depth(o_tr.x+979, o_tr.y+250,-188, o_cerc);
but2.aniza = 2;

//terrain: o_tr

//score:
global.but_eq1 = 0;
global.but_eq2 = 0;

//difficulte IA (1=facile, 2=normal, 3=difficile)
global.difficulty = 3;

// Animation récupération après panier
basket_anim      = false;
basket_phase     = 0;   // 0=marche vers balle, 1=marche vers inbound, 2=attend passe
basket_timer     = 0;
basket_player    = -1;  // joueur qui ramasse et remet en jeu
basket_support   = -1;  // 2e joueur qui se positionne pour recevoir
basket_side      = 0;   // equipe qui remet en jeu (1 ou 2)
basket_inbound_x = 0;
basket_inbound_y = 0;
basket_cooldown  = 0;   // délai après inbound avant rush offensif

ball_chaser_eq1 = -1;  // bot eq1 qui chasse le ballon libre
ball_chaser_eq2 = -1;  // bot eq2 qui chasse le ballon libre

// Hors-terrain (out of bounds)
oob_anim       = false;
oob_timer      = 0;
oob_inbound_x  = 0;
oob_inbound_y  = 0;
oob_side       = 0;       // équipe qui remet en jeu
oob_fade       = 0.0;     // alpha du fondu noir (0=transparent, 1=opaque)
oob_fade_state = 0;       // 0=rien, 1=fondu vers noir, 2=maintien, 3=retour


//tactic
tac1 = get_tactic_by_type("1");
tac2 = get_tactic_by_type("2");

tic1 = get_tactic_by_type("1");
tic2 = get_tactic_by_type("2");