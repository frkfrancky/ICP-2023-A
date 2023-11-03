
function vertex_create_face (_vBuff, _p1, _p2, _p3, _p4, _color, _alpha){
	//static _texSize = 32;
	//var _texW = _width;
	//var _texH = _height;

	//The first triangle
	vertex_position_3d(_vBuff, _p1.x, _p1.y, -_p1.z);
	vertex_color(_vBuff, _color, _alpha);
	vertex_texcoord(_vBuff, 0, 0);

	vertex_position_3d(_vBuff, _p2.x, _p2.y, -_p2.z);
	vertex_texcoord(_vBuff, 1, 0);//_texW
	vertex_color(_vBuff, _color, _alpha);

	vertex_position_3d(_vBuff, _p3.x, _p3.y, -_p3.z);
	vertex_texcoord(_vBuff, 1, 1);//_texW_texH
	vertex_color(_vBuff, _color, _alpha);

	//The second triangle. The winding order has been maintained so drawing is consistent if culling is enabled.
	vertex_position_3d(_vBuff, _p1.x, _p1.y, -_p1.z);
	vertex_texcoord(_vBuff, 0, 0);
	vertex_color(_vBuff, _color, _alpha);

	vertex_position_3d(_vBuff, _p3.x, _p3.y, -_p3.z);
	vertex_texcoord(_vBuff, 1, 1);//_texW_texH
	vertex_color(_vBuff, _color, _alpha);

	vertex_position_3d(_vBuff, _p4.x, _p4.y, -_p4.z);
	vertex_texcoord(_vBuff, 0, 1);
	vertex_color(_vBuff, _color, _alpha);
}