function get_id_categorie_by_name(argument0) {
	tadiaviko = argument0;

	eq = get_all_team();
	res = -1;
	for (var i = 0; i < array_length_2d(eq, 1); ++i) {
	    if(tadiaviko == cat[1,i]){
			res = eq[0,i];
			break;
		}
	}

	return res;



}
