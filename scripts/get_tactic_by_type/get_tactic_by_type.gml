function get_tactic_by_type(argument0) {
	data_base3();
	tadiaviko = argument0;
	
	var res;
	var j = 0;
	for (var i = 0; i < array_length_2d(pts, 2); ++i) {
	    if(string(tadiaviko) == string(pts[0,i])){
			res[0,j] = pts[0,i];//id tactic
			res[1,j] = pts[1,i];//joueur
			res[2,j] = pts[2,i];//x
			res[3,j] = pts[3,i];//y
			res[4,j] = pts[4,i];//rayon d'action
			j++;
		}
	}

	return res;
}

