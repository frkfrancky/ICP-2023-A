//ANALOGUE TACTILE (start)////////////////////////////////
draw_set_alpha(0.5);
draw_set_color(c_white);
draw_circle(x_analogue,y_analogue,r_analogue,false);


draw_set_color(c_red);
draw_circle(x_analogue_r,y_analogue_r,r_analogue/2,false);

draw_set_color(c_white);
draw_circle(x_analogue_b,y_analogue_b,96,true);
draw_set_alpha(1);
draw_text(100, 50, string(button_analogue));

//(end)//////////////////////////////////////////////////

//BOUTON ACTION (start)////////////////////////////////
draw_set_alpha(0.5);
draw_set_color(c_white);
draw_circle(x_action1,y_action1,r_actions,false);
draw_text(120, 50, string(button_action1));

draw_set_alpha(0.5);
draw_set_color(c_white);
draw_circle(x_action2,y_action2,r_actions,false);
draw_text(140, 50, string(button_action2));
//(end)//////////////////////////////////////////////////
