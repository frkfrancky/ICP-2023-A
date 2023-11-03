draw_self();
draw_arrow(x,y,(x+hspeed*5),(y+vspeed*5),2);
//draw_sprite(s_perso_body,0,x,y);
draw_sprite_ext(s_perso_body,0,x,y,1,1-(depth/2000),1-(depth/2000),-1,255);
draw_text(x+30,y,string(mini_id));
draw_text(x+30,y+30,string(is_player));
if(is_player && o_camera.proche1 != -1){
	draw_line(x,y,o_camera.perso[o_camera.proche1].x,o_camera.perso[o_camera.proche1].y);
}

/*for (var i = 0; i < 5; ++i) {
    
}*/
