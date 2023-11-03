function get_by_team(argument0, argument1) {

	var id_equipe = argument0;//global equipe
	//var aniza = argument1;//identification player 1 or 2
	var one = data_base2();
	var membre = 0;
	var farany = 0;
	var mn = 0;
	var nm = 0;

	//--------RECHERCHE DES MEMBRES DE L'EQUIPE
	for (var i = 0; i < array_length_2d(one,2); ++i) {
		if(int64(one[2,i]) == id_equipe){
			if(one[4,i] == true && mn<5){
				farany[0,mn] = one[0,i];//id joueur
				farany[1,mn] = one[1,i];//nom joueur
				farany[2,mn] = one[3,i];//numero joueur
				farany[3,mn] = one[4,i];//major joueur
				farany[4,mn] = one[5,i];//vitesse joueur
				farany[5,mn] = one[6,i];//precision joueur
				farany[6,mn] = one[7,i];//puissance joueur
				farany[7,mn] = one[8,i];//defence joueur
				farany[8,mn] = one[9,i];//technique joueur
				mn++;
			}else{
				membre[0,nm] = one[0,i];//id joueur
				membre[1,nm] = one[1,i];//nom joueur
				membre[2,nm] = one[3,i];//numero joueur
				membre[3,nm] = one[4,i];//major
				membre[4,nm] = one[5,i];//vitesse
				membre[5,nm] = one[6,i];//precision
				membre[6,nm] = one[7,i];//puissance
				membre[7,nm] = one[8,i];//defence
				membre[8,nm] = one[9,i];//technique
				nm++;
			}
		
		}
	}


	if(is_array(membre)){
		for (var i = 0; i < array_length_2d(membre,0); ++i) {
		    farany[0,mn] = membre[0,i];//id joueur
			farany[1,mn] = membre[1,i];//nom joueur
			farany[2,mn] = membre[2,i];//numero joueur
			farany[3,mn] = membre[3,i];//major joueur
			farany[4,mn] = membre[4,i];//vitesse joueur
			farany[5,mn] = membre[5,i];//precision joueur
			farany[6,mn] = membre[6,i];//puissance joueur
			farany[7,mn] = membre[7,i];//defence joueur
			farany[8,mn] = membre[8,i];//technique joueur
			mn++;
		}
	}


	return farany;


}
