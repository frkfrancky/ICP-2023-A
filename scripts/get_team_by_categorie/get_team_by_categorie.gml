function get_team_by_categorie(argument0) {
	tadiaviko = argument0;

	eq = get_all_team();
	var res;
	var j = 0;
	for (var i = 0; i < array_length_2d(eq, 2); ++i) {
	    if(string(tadiaviko) == string(eq[2,i])){
			res[0,j] = eq[0,i];
			res[1,j] = eq[1,i];
			res[2,j] = eq[2,i];
			res[3,j] = eq[3,i];
			j++;
		}
	}

	return res;



}
