

draw_set_alpha(0.5);
draw_rectangle_color(x-32,y-48,x+250,y+16,c_black,c_black,c_black,c_black,false);

draw_set_alpha(hita);
draw_set_color(c_white);
draw_set_font(my_font_big);
draw_text(x,y,soratra);

if(farany != hita){
	farany = hita;
	alarm_set(0,50);
}
