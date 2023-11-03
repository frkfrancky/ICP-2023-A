if(camera_libre == false){
	camera_libre = true;
	time_dep = global.time;
	global.time = 0;
}else{
	camera_libre = false;
	global.time = time_dep;
}
