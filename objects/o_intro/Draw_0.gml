

if(manomboka == true){
	draw_set_color(c_white);
	draw_set_alpha(opacity);
	draw_rectangle(0,0,room_width,room_height,false);

	if(sens == 1){
		if(opacity < 1){
			opacity += 0.01;
		}
	}else{
		if(opacity > 0){
			opacity -= 0.01;
		}
	}

	if(pause1 == false && misy_alarm == false && sens == 1 && opacity >= 1){
		alarm_set(0,temp1);
		misy_alarm = true;
	}

	if(pause1 == false && misy_alarm == false && sens == -1 && opacity <= 0){
		if((index_sary+1) < array_length(sary)){
			index_sary += 1;
			sens = 1;
		}else{
			room_goto(video);
		}
	}
	draw_sprite_ext(sary[index_sary],0,room_width/2,(room_height/2)-25,0.5,0.5,0,-1,opacity);
}


