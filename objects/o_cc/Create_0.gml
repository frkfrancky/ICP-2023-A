
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

//tactic
tac1 = get_tactic_by_type("1");
tac2 = get_tactic_by_type("2");

tic1 = get_tactic_by_type("1");
tic2 = get_tactic_by_type("2");