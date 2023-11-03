x = bal.x;
y = bal.y;

if (bal.can_poss == false && bal.is_drible == false){
	//mandalo_v = "eny";
	//alarm_set(0,20);
	bal.can_poss = true;
}


	//DETECTEUR DE PASSE
	//equipe 0
	if(possesseur_mini_id != -1){
		if(proche1 == -1){
			proche1 = 1;
		}
		for (var i = 0; i < 5; ++i) {
			if(perso[i].is_player == false){
				if(abs(point_distance(perso[i].x,perso[i].y,perso[possesseur_mini_id].x,perso[possesseur_mini_id].y)) <
				abs(point_distance(perso[proche1].x,perso[proche1].y,perso[possesseur_mini_id].x,perso[possesseur_mini_id].y))){
					proche1 = i;
				}
			}
		}
	}
