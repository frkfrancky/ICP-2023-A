draw_self();

/*
gpu_set_blendmode_ext(bm_src_alpha, bm_zero);
draw_sprite_part_ext(s_background_menu1,1,x,y,sprite_width,sprite_height,x,y,1,1,-1,0.5);
gpu_set_blendmode(bm_normal);*/
if(room == r_menu3){
	draw_set_alpha(image_alpha);
	if(id==o_control_menu.mn[2]){
		draw_sprite_part_ext(afficher,0,0,0,128,128,x+sprite_width-132,y+4,0.9,0.9,-1,1);
		draw_set_halign(fa_right);
		draw_set_valign(fa_top);
		draw_text(x+sprite_width-150,y+28,text);
	
	}else if (id==o_control_menu.mn[3]){
		draw_sprite_part_ext(afficher,0,0,0,128,128,x+16,y+4,0.9,0.9,-1,1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text(x+150,y+28,text);
	}
}

if(room == r_menu4){
	draw_set_alpha(image_alpha);
	if(id==o_control_menu.mn[2]){
		draw_sprite_part_ext(afficher,0,0,0,128,128,x+sprite_width-132,y+4,0.9,0.9,-1,1);
		draw_set_halign(fa_right);
		draw_set_valign(fa_top);
		draw_text(x+sprite_width-150,y+28,text);
	
	}else if (id==o_control_menu.mn[3]){
		draw_sprite_part_ext(afficher,0,0,0,128,128,x+16,y+4,0.9,0.9,-1,1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text(x+150,y+28,text);
	}
	//CONTOUR////////////////////
	var i, steps, xx, yy, radius;
	steps=5;
	if(mini_id == 2){
		xx=x+96;
		yy=y+60;
		draw_text_transformed(xx+45,yy-60,"vit",0.5,0.5,0);
		draw_text_transformed(xx-53,yy-36,"pre",0.5,0.5,0);
		draw_text_transformed(xx-53,yy+20,"pui",0.5,0.5,0);
		draw_text_transformed(xx+48,yy+38,"def",0.5,0.5,0);
		draw_text_transformed(xx+80,yy-8,"tec",0.5,0.5,0);
	}else{
		xx=x+sprite_width-96;
		yy=y+60;
		draw_text_transformed(xx+28,yy-60,"vit",0.5,0.5,0);
		draw_text_transformed(xx-70,yy-36,"pre",0.5,0.5,0);
		draw_text_transformed(xx-70,yy+20,"pui",0.5,0.5,0);
		draw_text_transformed(xx+31,yy+38,"def",0.5,0.5,0);
		draw_text_transformed(xx+63,yy-8,"tec",0.5,0.5,0);
	}
	var alifa;
	alifa[0] = 0.5; alifa[1] = 1 ; alifa[2] = 0.5;
	radius=50;
	draw_set_color($FFFFFF);
	for (var j = 0; j < 3; ++j) {
		draw_set_alpha(alifa[j]);
		draw_primitive_begin(pr_linestrip);
		for(i = 0; i <= steps; i += 1)
		   {
			draw_vertex(xx + lengthdir_x(radius, 360 * i / steps), yy + lengthdir_y(radius, 360 * i / steps));
		   }
		draw_primitive_end();
		radius--;
	}
	draw_set_alpha(1);
	
	/////////////////////////////
	
	//REMPLISSAGE SELECTED//////////////////
	if(data2 != 0){
		steps=5;
		radius=30;
		draw_set_color($AA00FF);//5EDB67
		draw_set_alpha(0.5);
		draw_primitive_begin(pr_trianglelist);
		radius = calcul_stat(int64(data2[array_length_1d(data2)-4]));
		
		for(i = 0; i < steps; i += 1)
		   {	
				draw_vertex(xx + lengthdir_x(radius, 360 * i / steps), yy + lengthdir_y(radius, 360 * i / steps));
				draw_sprite(point,0,xx + lengthdir_x(radius, 360 * i / steps), yy + lengthdir_y(radius, 360 * i / steps));
				if(i >= 4){	radius = calcul_stat(int64(data2[1]));	}else{	radius = calcul_stat(int64(data2[i+1]));	}
				radius = calcul_stat(int64(data2[i+1]));
				draw_vertex(xx + lengthdir_x(radius, 360 * (i+1) / steps), yy + lengthdir_y(radius, 360 * (i+1) / steps));
				draw_vertex(xx,yy);
		   }
		draw_primitive_end();
		draw_set_alpha(1);
		draw_set_color($FFFFFF);
	}
	////////////////////////////////
	
	//REMPLISSAGE//////////////////
	if(data != 0){
		steps=5;
		radius=30;
		draw_set_color($DDE854);//5EDB67
		draw_set_alpha(0.5);
		draw_primitive_begin(pr_trianglelist);
		radius = calcul_stat(int64(data[array_length_1d(data)-4]));
		for(i = 0; i < steps; i += 1)
		   {	
				draw_vertex(xx + lengthdir_x(radius, 360 * i / steps), yy + lengthdir_y(radius, 360 * i / steps));
				draw_sprite(point,0,xx + lengthdir_x(radius, 360 * i / steps), yy + lengthdir_y(radius, 360 * i / steps));
				if(i >= 4){	radius = calcul_stat(int64(data[1]));	}else{	radius = calcul_stat(int64(data[i+1]));	}
				radius = calcul_stat(int64(data[i+1]));
				draw_vertex(xx + lengthdir_x(radius, 360 * (i+1) / steps), yy + lengthdir_y(radius, 360 * (i+1) / steps));
				draw_vertex(xx,yy);
		   }
		draw_primitive_end();
		draw_set_alpha(1);
		draw_set_color($FFFFFF);
		
		
		//draw_text_transformed(x,y,string(data[0]),0.5,0.5,0);
		

		
	}
	////////////////////////////////
	
	
}
