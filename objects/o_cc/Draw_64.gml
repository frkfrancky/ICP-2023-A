/*draw_text(20,20,string((global.is_me1.direction - point_direction(eq1[key].x,eq1[key].y,global.is_me1.x,global.is_me1.y))));
draw_text(100,20,string(abs(angle_difference(global.is_me1.direction,point_direction(global.is_me1.x,global.is_me1.y,ak1.x,ak1.y)))));
*/

//affiche la vitesse du temps
draw_text_transformed(room_width - 100, 30,"time: "+string(global.time),0.7,0.7,0);
draw_text_transformed(room_width - 158, 70,"nb_player: "+string(global.playerNumber),0.7,0.7,0);

//affiche le score:
draw_set_halign(fa_middle);
draw_set_valign(fa_center);
draw_text_transformed(room_width/2, 30,"equipe bleu: "+string(global.but_eq1),0.7,0.7,0);
draw_text_transformed(room_width/2, 60,"equipe rouge: "+string(global.but_eq2),0.7,0.7,0);
