function transfert_joueur(argument0) {
	//menu 4
	//AFAMADIKA///////
	var a_j = argument0;//valeur 0 ou 1 correspond au mini_id

	if(a_j == 0){
		var temporaire = bt[index_focused].data;
		for (var i = 0; i < (array_length_2d(global.membre1,0)); ++i) {
			if(bt[index_selected].data[6] == global.membre1[0,i]){//test id
				//PHASE 1
				global.membre1[0,i] = temporaire[6];//id
				global.membre1[1,i] = temporaire[8];//anarana
				global.membre1[2,i] = temporaire[7];//numero
				global.membre1[3,i] = temporaire[0];//major
				global.membre1[4,i] = temporaire[1];//vitesse
				global.membre1[5,i] = temporaire[2];//precision
				global.membre1[6,i] = temporaire[3];//puissance
				global.membre1[7,i] = temporaire[4];//defense
				global.membre1[8,i] = temporaire[5];//technique
				break;
			}
		}
		for (var i = 0; i < (array_length_2d(global.membre1,0)); ++i) {
			if(bt[index_focused].data[6] == global.membre1[0,i]){//test id
				//PHASE 2
				global.membre1[0,i] = bt[index_selected].data[6];//id
				global.membre1[1,i] = bt[index_selected].data[8];//anarana
				global.membre1[2,i] = bt[index_selected].data[7];//numero
				global.membre1[3,i] = bt[index_selected].data[0];//major
				global.membre1[4,i] = bt[index_selected].data[1];//vitesse
				global.membre1[5,i] = bt[index_selected].data[2];//precision
				global.membre1[6,i] = bt[index_selected].data[3];//puissance
				global.membre1[7,i] = bt[index_selected].data[4];//defense
				global.membre1[8,i] = bt[index_selected].data[5];//technique
				bt[index_focused].data = bt[index_selected].data;
				bt[index_focused].anarana = bt[index_selected].anarana;
				bt[index_selected].data = temporaire;
				bt[index_selected].anarana = temporaire[8];
				break;
			}
		}
	}else if(a_j == 1){
		var temporaire = bt[index_focused].data;
		for (var i = 0; i < (array_length_2d(global.membre2,0)); ++i) {
			if(bt[index_selected].data[6] == global.membre2[0,i]){//test id
				//PHASE 1
				global.membre2[0,i] = temporaire[6];//id
				global.membre2[1,i] = temporaire[8];//anarana
				global.membre2[2,i] = temporaire[7];//numero
				global.membre2[3,i] = temporaire[0];//major
				global.membre2[4,i] = temporaire[1];//vitesse
				global.membre2[5,i] = temporaire[2];//precision
				global.membre2[6,i] = temporaire[3];//puissance
				global.membre2[7,i] = temporaire[4];//defense
				global.membre2[8,i] = temporaire[5];//technique
				break;
			}
		}
		for (var i = 0; i < (array_length_2d(global.membre2,0)); ++i) {
			if(bt[index_focused].data[6] == global.membre2[0,i]){//test id
				//PHASE 2
				global.membre2[0,i] = bt[index_selected].data[6];//id
				global.membre2[1,i] = bt[index_selected].data[8];//anarana
				global.membre2[2,i] = bt[index_selected].data[7];//numero
				global.membre2[3,i] = bt[index_selected].data[0];//major
				global.membre2[4,i] = bt[index_selected].data[1];//vitesse
				global.membre2[5,i] = bt[index_selected].data[2];//precision
				global.membre2[6,i] = bt[index_selected].data[3];//puissance
				global.membre2[7,i] = bt[index_selected].data[4];//defense
				global.membre2[8,i] = bt[index_selected].data[5];//technique
				bt[index_focused].data = bt[index_selected].data;
				bt[index_focused].anarana = bt[index_selected].anarana;
				bt[index_selected].data = temporaire;
				bt[index_selected].anarana = temporaire[8];
				break;
			}
		}
	}


}
