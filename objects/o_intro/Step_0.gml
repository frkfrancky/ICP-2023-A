if(gamepad_button_check(global.gp1,gp_start) == true){
	if(video_get_status() == video_status_playing){
		video_close();
		fin = true;
	}
}
