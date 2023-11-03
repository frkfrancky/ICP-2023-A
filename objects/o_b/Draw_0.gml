/*
draw_self();

draw_set_color(c_black);
draw_set_alpha(0.2);
draw_circle(x,y,8,false);
draw_set_color(c_white);
draw_set_alpha(1);

draw_set_alpha(1);
//draw_text(x,y+32,string(point_distance(x,y,pocesseur.x,pocesseur.y)));
//draw_text(x,y+32,string(mpamono));
draw_set_color(c_fuchsia);
draw_line_width(x,y,o_cc.but2.x,o_cc.but2.y,8);

//draw_text(x,y+32, string(im_angle_3d));

draw_set_color(c_white);
*/

//shader_set(Shader1);

//draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 1.0);

draw_self();
var alp = 0.5 - (z/500);

draw_set_alpha(alp);
draw_circle_color(x,y,7,c_black,c_black,false);
draw_set_alpha(1);

vertex_submit(vBuffTop, pr_trianglelist, textureTop)
//vertex_submit(vBuffTop2, pr_trianglelist, -1)
vertex_delete_buffer(vBuffTop)
vertex_delete_buffer(vBuffTop2)
shader_reset();
