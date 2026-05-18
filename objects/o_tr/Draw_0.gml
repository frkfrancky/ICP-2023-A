// Sol avec éclairage directionnel
shader_set(shd_floor);
shader_set_uniform_f_array(o_cam.u_fldir, o_cam.lit_dir);
shader_set_uniform_f(o_cam.u_flcol, o_cam.lit_color[0], o_cam.lit_color[1], o_cam.lit_color[2]);
shader_set_uniform_f(o_cam.u_flamb, 0.78);  // sol bien éclairé (ambiant élevé)
draw_self();
shader_reset();


//affichage zone 3 points/////////////////////
depth--;
draw_set_color(c_fuchsia);
draw_set_alpha(0.2);

draw_circle(x3pts_1,y3pts,r3pts,false);
draw_circle(x3pts_2,y3pts,r3pts,false);
depth++;
//////////////////////////////////////////////

draw_set_alpha(1)
