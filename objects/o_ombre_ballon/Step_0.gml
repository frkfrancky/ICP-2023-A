//friction
if(hspeed>0){
	hspeed -= fric;
}else if (hspeed<0){
	hspeed += fric;
}

//ballon
ballon.x = x;
depth = 192-y;
ballon.depth = depth-1;
ballon.image_xscale = 1-(depth/2000);
ballon.image_yscale = ballon.image_xscale;

if(place_meeting(x+hspeed,y,o_block)){
	hspeed = -(hspeed/2);
	ballon.hspeed = hspeed;
}

//possesseur
