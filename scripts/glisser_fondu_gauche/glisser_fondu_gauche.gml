function glisser_fondu_gauche(argument0) {

	xany = argument0;

	//image_alpha;
	if(anim_start == true){
		x += 10;
		image_alpha += 0.1;
		if(x >= xany){
			anim_start = false;
		}
	}


}
