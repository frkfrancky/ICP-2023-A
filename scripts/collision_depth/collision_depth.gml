function collision_depth(argument0, argument1) {
	//argument0 depth perso, argument1 depth ballon
	marina = false;
	if(abs(argument0-argument1) <= 5){
		marina = true;
	}else{
		marina = false;
	}
	return marina;


}
