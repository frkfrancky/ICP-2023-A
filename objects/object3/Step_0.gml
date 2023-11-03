if(keyboard_check(ord("Z"))){
	y-=3;
}else if (keyboard_check(ord("S"))){
	y+=3;
}
if (keyboard_check(ord("Q"))){
	x-=3;
}else if (keyboard_check(ord("D"))){
	x+=3;
}
if(keyboard_check(ord("P"))){
}else{
	if(x<=350){
		sens = 1;
	}else if (x>=600){
		sens = -1;
	}
	x+= vitesse*sens;
}