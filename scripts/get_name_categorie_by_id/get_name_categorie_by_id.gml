function get_name_categorie_by_id(argument0) {
	tadiaviko = argument0;

	eq = get_all_team();
	res = "vide";
	for (var i = 0; i < array_length_2d(eq, 0); ++i) {
	    if(tadiaviko == eq[0,i]){
			res = eq[1,i];
			break;
		}
	}

	return res;



}
