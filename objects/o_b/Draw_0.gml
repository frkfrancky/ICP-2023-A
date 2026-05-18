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
// Ombre au sol directionnelle (s'étire selon hauteur de la balle)
var _bh  = max(z - 8, 0);          // hauteur au-dessus du sol
var _alp = max(0.05, 0.35 - _bh/600);
var _sr  = 5 + _bh * 0.08;        // rayon grandit avec la hauteur
var _osx = x - 10 - _bh * 0.04;   // offset X (direction opposée lumière)
var _osy = y + 5  + _bh * 0.02;
draw_set_alpha(_alp);
draw_ellipse(_osx-_sr*1.5, _osy-_sr*0.6, _osx+_sr*1.5, _osy+_sr*0.6, false);
draw_set_alpha(1);

// Sprite balle avec shader lumière — spots fixes de salle
shader_set(Shader1);
shader_set_uniform_f_array(o_cam.u_ldir, o_cam.lit_dir);
shader_set_uniform_f(o_cam.u_lcol, o_cam.lit_color[0], o_cam.lit_color[1], o_cam.lit_color[2]);
shader_set_uniform_f(o_cam.u_lamb, o_cam.lit_amb);
shader_set_uniform_f(o_cam.u_lrim, o_cam.lit_rim + 0.2);
var _blx0 = lerp(o_cc.but1.x, o_cc.but2.x, 0.28);
var _bly0 = lerp(o_cc.but1.y, o_cc.but2.y, 0.28);
var _blx1 = lerp(o_cc.but1.x, o_cc.but2.x, 0.72);
var _bly1 = lerp(o_cc.but1.y, o_cc.but2.y, 0.72);
shader_set_uniform_f(o_cam.u_pl0, _blx0, _bly0);
shader_set_uniform_f(o_cam.u_pl1, _blx1, _bly1);
shader_set_uniform_f(o_cam.u_plcol, 0.42, 0.38, 0.30);
shader_set_uniform_f(o_cam.u_plrad, 420.0);
shader_set_uniform_f(o_cam.u_sprpos, x, y);
shader_set_uniform_f(o_cam.u_flat_normal, 0.0); // sphere normal pour la balle
vertex_submit(vBuffTop, pr_trianglelist, textureTop);
shader_reset();
vertex_delete_buffer(vBuffTop);
vertex_delete_buffer(vBuffTop2);
