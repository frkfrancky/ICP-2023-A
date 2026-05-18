/// @description Nom du joueur au-dessus de la tête (Draw GUI)
var _gsw = display_get_gui_width();
var _gsh = display_get_gui_height();
var _vm  = o_cam.cam_view_mat;
var _pm  = o_cam.cam_proj_mat;

// Point monde : légèrement en dessous du haut des jauges (z+190)
var _wx = x;
var _wy = y;
var _wz = -(z + 190);

var _v  = matrix_transform_vertex(_vm, _wx, _wy, _wz);
var _vz = _v[2];
if(_vz > 0){
	var _c    = matrix_transform_vertex(_pm, _v[0], _v[1], _vz);
	var _ndcx =  _c[0] / _vz;
	var _ndcy = -_c[1] / _vz;
	var _sx   = (_ndcx * 0.5 + 0.5) * _gsw;
	var _sy   = (_ndcy * 0.5 + 0.5) * _gsh;
	if(_sx >= 0 && _sx <= _gsw && _sy >= -30 && _sy <= _gsh){
		var _tcol = (ekipa == 1) ? #88bbff : #ff8888;
		var _lbl  = (ekipa == 1 ? "P" : "E") + string(index + 1);
		draw_set_font(my_font);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_color(is_me ? c_yellow : _tcol);
		draw_text(_sx, _sy, _lbl);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
	}
}
