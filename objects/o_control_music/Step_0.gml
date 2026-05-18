//audio_stop_all()
if(audio_is_playing(mosika)==false){
	var hasard = int64(random_range(0,get_count_music()));
	var mozika_rehetra = get_all_music();

	mosika_index = hasard;
	mosika = audio_play_sound(mozika_rehetra[2,mosika_index],1,false);  //fichier
	titre_mosika = mozika_rehetra[3,mosika_index]	//titre
	artiste_mosika = mozika_rehetra[4,mosika_index]	//artiste
}

if(is_display == true and compt_start == false){
	compt_start = true;
	alarm_set(0,300);
}

if(compt_start == true){
	if(tp<300){
		tp++;
	}
}

if(keyboard_check(ord("A"))){
	is_display = true;
	compt_start = false;
}
