
draw_set_alpha(opacity);
draw_set_color(c_white);
var results = video_draw()

if (results[0] == 0) {
	//draw_surface(results[1], 0, 0);
	draw_surface_stretched(results[1],0,0,room_width,room_height)
}
	
if(fin == true){
	if(opacity > 0){
		opacity -= 0.01;
		video_set_volume(opacity);
	}else{
		video_set_volume(1);
		video_close();
		room = titre;
	}
}
	
	
	
draw_text(32, 550, "Video position: " + string(floor(video_get_position() / 1000)) + "/" + string(floor(video_get_duration() / 1000)));



if(floor(video_get_position()/ 1000) == floor(video_get_duration() / 1000)){
			video_close();
			room = titre;
}


