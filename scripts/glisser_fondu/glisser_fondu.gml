function glisser_fondu(argument0) {

	yany = argument0;

	//image_alpha;
	if(anim_start == true){
		y -= 10;
		image_alpha += 0.1;
		if(y <= yany){
			anim_start = false;
		}
	}


}
