draw_set_alpha(0.5);
draw_circle_color(x,y,8,c_red,loko,false);
draw_circle_color(x,y,rayon,c_red,loko,true);
draw_set_alpha(1);
draw_set_color(c_maroon);
draw_text_transformed(x,y+16,string(index),0.7,0.7,0);
draw_set_color(c_white);
