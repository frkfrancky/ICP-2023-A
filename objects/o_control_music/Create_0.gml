 //AUDIO TEST
randomize();
var hasard = int64(random_range(0,get_count_music()));
var mozika_rehetra = get_all_music();

mosika_index = hasard;
mosika = audio_play_sound(mozika_rehetra[2,mosika_index],1,false);  //fichier
titre_mosika = mozika_rehetra[3,mosika_index]	//titre
artiste_mosika = mozika_rehetra[4,mosika_index]	//artiste

audio_sound_set_track_position(mosika, "20");

plus = 8;	//padding, margin

xx1 = room_width - 300 + plus;
yy1 = 2*plus;
xx2 = room_width - 2*plus;
yy2 = 100 + plus;


is_display = true;
compt_start = true;

tp = 0;
alarm_set(0,300);
