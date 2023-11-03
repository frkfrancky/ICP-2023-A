draw_set_colour(c_white);
var tex = sprite_get_texture(s_terr0,0);
draw_primitive_begin_texture(pr_trianglestrip, tex);
draw_vertex_texture(x, y, 0, 0);
draw_vertex_texture(x+576, y, 1, 0);
draw_vertex_texture(x+576, y+317, 1, 1);
draw_vertex_texture(x,y+317, 0, 1);
draw_vertex_texture(x, y, 0, 0);
draw_primitive_end();
