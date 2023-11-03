draw_self();

//3d set /////////////////////////////

vBuffTop = vertex_create_buffer();

vertex_begin(vBuffTop, global.vFormat);
var centre = 32;
vertex_create_face(vBuffTop,
	new Vec3 (x, y-centre, z +72),
	new Vec3 (x, y+64 - centre, z +72),
	new Vec3 (x, y+64 - centre,z),
	new Vec3 (x, y - centre, z),
	c_white, 1);

vertex_end(vBuffTop);
vertex_freeze(vBuffTop);
//3d end //////////////////////////////

textureTop = sprite_get_texture(tableau_3d, 0);

vertex_submit(vBuffTop, pr_trianglelist, textureTop);
vertex_delete_buffer(vBuffTop);
