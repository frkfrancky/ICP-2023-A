//draw_self();
draw_set_color(c_black);
draw_set_alpha(0.2);
draw_circle(x,y,16,false);
draw_set_color(c_white);
draw_set_alpha(1);

draw_text(x+32,y,string(pt3s));


//////alana refaveo////////////////////////////////////////////////////
//draw_text(x+32,y+32,string(miandry_passe));
if(ekipa == 1){
	draw_line_width(x,y,o_cc.tt1[point_tt].x,o_cc.tt1[point_tt].y,4);
}
if(akaiky == true){
	draw_circle_color(x,y,17,c_white,c_white,true);
}
////////////////////////////////////////////////////////////////////////
//draw_self();



//3d draw ///////////
//3d set /////////////////////////////
vBuffTop = vertex_create_buffer();

vertex_begin(vBuffTop, global.vFormat);
var centre = 9;

/*
var a = 1;var b = 0;
var c = 0;var d = 1;*/

vertex_create_face(vBuffTop,
	new Vec3 (x-centre, y, z +130),
	new Vec3 (x-centre+40, y, z +130),
	new Vec3 (x-centre+40, y,z),
	new Vec3 (x-centre, y, z),
	c_white, 1);

vertex_end(vBuffTop);
vertex_freeze(vBuffTop);
//3d end //////////////////////////////

if(ekipa == 1){
	textureTop = sprite_get_texture(olona_3d, 0);

}else{
	textureTop = sprite_get_texture(olona_3d, 1);
}
vertex_submit(vBuffTop, pr_trianglelist, textureTop);
vertex_delete_buffer(vBuffTop);


//TEST SMF ENGINE //////////////

