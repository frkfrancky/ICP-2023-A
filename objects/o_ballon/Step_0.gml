vspeed += g;
	
if(place_meeting(x,y+vspeed,o_ombre_ballon)==true){
	if(abs(vspeed)<2){
		vspeed = 0;
	}else{
		vspeed = -(vspeed)/fric;
	}
}
if(place_meeting(x,y+1,o_ombre_ballon)==false && (o_ombre_ballon.y-y)<0){
	y = o_ombre_ballon.y-16;
}

image_angle += -hspeed/1.5;
