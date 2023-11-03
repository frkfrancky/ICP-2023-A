function get_player_by_id(argument0) {
	ideany = argument0;
	anarany = "vide";
	for (var i = 0; i < array_length_2d(joueur, 0); ++i) {
	    if(int64(ideany) == joueur[0,i]){
			anarany = joueur[1,i];
			break;
		}
	}
	return anarany;


}
