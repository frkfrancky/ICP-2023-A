function get_team_by_name_and_cate(argument0, argument1) {
	tadiaviko = argument0; //NOM
	tadiaviko2 = argument1; //CATEGORIE

	eq = get_all_team();
	var res;

	//
	for (var i = 0; i < array_length_2d(eq, 1); ++i) {
	    if(tadiaviko == eq[1,i] && tadiaviko2 == eq[2,i]){
			res = eq[3,i];
		}
	}
	/////////////


	return res;



}
