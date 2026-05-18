if (!variable_global_exists("char_parts")) exit;

// Caméra fictive : fixe, légèrement au sud du personnage
var _cam_x = x;
var _cam_y = y + 500;

var _cam_dir = point_direction(x, y, _cam_x, _cam_y);
var _rel_ang = ((_cam_dir - dir) mod 360 + 360) mod 360;
var _frame   = (8 - (round(_rel_ang / 45) mod 8)) mod 8;

var _brx = lengthdir_x(1, _cam_dir - 90);
var _bry = lengthdir_y(1, _cam_dir - 90);
var _prx = dsin(dir);
var _pry = dcos(dir);

var _cam_dist = max(point_distance(x, y, _cam_x, _cam_y), 1);
var _cdx = (_cam_x - x) / _cam_dist;
var _cdy = (_cam_y - y) / _cam_dist;
var _right_dot_cam = _prx*_cdx + _pry*_cdy;

var _fk    = global.char_fk(anim_current, anim_time);
var _order = global.char_layer_order[_frame];

// Dessin des bones avec GPU orthographique (Draw event = 2D par défaut en room sans caméra 3D)
// On convertit les coordonnées bones en screen 2D directement
var _scale = 2.5;  // zoom préview

for (var _pi = 0; _pi < 10; _pi++) {
    var _pid  = _order[_pi];
    var _part = global.char_parts[_pid];
    var _bone = _fk[_pid];
    var _hw   = _part.hw;

    var _piv_bias = _bone.piv_bx * _right_dot_cam * 0.8;
    var _end_bias = _bone.end_bx * _right_dot_cam * 0.8;

    // Pivot et end en espace 2D préview (bx=horizontal, bz=vertical inversé)
    var _piv_sx = x + (_bone.piv_bx + _piv_bias) * _scale;
    var _piv_sy = y - _bone.piv_bz * _scale;
    var _end_sx = x + (_bone.end_bx + _end_bias) * _scale;
    var _end_sy = y - _bone.end_bz * _scale;

    // Vecteur perpendiculaire au bone en écran
    var _bdir = point_direction(_piv_sx, _piv_sy, _end_sx, _end_sy);
    var _phx  = lengthdir_x(_hw * _scale, _bdir + 90);
    var _phy  = lengthdir_y(_hw * _scale, _bdir + 90);

    // Quad 2D
    var _Ax = _piv_sx + _phx; var _Ay = _piv_sy + _phy;
    var _Bx = _piv_sx - _phx; var _By = _piv_sy - _phy;
    var _Cx = _end_sx - _phx; var _Cy = _end_sy - _phy;
    var _Dx = _end_sx + _phx; var _Dy = _end_sy + _phy;

    draw_set_color(_part.col);
    draw_set_alpha(0.92);
    draw_triangle(_Ax,_Ay, _Bx,_By, _Cx,_Cy, false);
    draw_triangle(_Ax,_Ay, _Cx,_Cy, _Dx,_Dy, false);
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_line(_Ax,_Ay, _Bx,_By);
    draw_line(_Bx,_By, _Cx,_Cy);
    draw_line(_Cx,_Cy, _Dx,_Dy);
    draw_line(_Dx,_Dy, _Ax,_Ay);
    draw_set_alpha(1);
}

// Label direction
draw_set_color(c_white);
draw_set_font(-1);
draw_set_halign(fa_center);
draw_text(x, y - 200, "← → : tourner    dir=" + string(round(dir)) + "°   frame=" + string(_frame));
draw_set_halign(fa_left);
