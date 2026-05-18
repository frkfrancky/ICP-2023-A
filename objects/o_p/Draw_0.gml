// Ombre au sol directionnelle (ellipse offset selon direction lumière)
// Lumière vient de (0.55, -0.30) en XY → ombre va dans la direction opposée
var _shx = x - 12;   // offset shadow X (opposé lumière)
var _shy = y + 7;    // offset shadow Y
draw_set_color(c_black);
draw_set_alpha(0.22);
draw_ellipse(_shx-18, _shy-7, _shx+18, _shy+7, false);
draw_set_alpha(1);
draw_set_color(c_white);

draw_set_font(my_font);
if(ekipa == 1){
	draw_line_width(x,y,o_cc.tt1[point_tt].x,o_cc.tt1[point_tt].y,4);
}
if(akaiky == true){
	draw_circle_color(x,y,17,c_white,c_white,true);
}

//draw_self();

// === CORPS 3D ARTICULÉ (FK) ===
var _cam_dir = point_direction(x, y, o_cam.x, o_cam.y);
var _rel_ang = ((_cam_dir - dir) mod 360 + 360) mod 360;
var _frame   = (8 - (round(_rel_ang / 45) mod 8)) mod 8;

// Axe "droite" billboard : perpendiculaire à la direction joueur→caméra dans XY
// → chaque quad fait toujours face à la caméra (vrai billboard)
var _brx = lengthdir_x(1, _cam_dir - 90);
var _bry = lengthdir_y(1, _cam_dir - 90);

// Axe "droite" du joueur en espace monde
// → utilisé uniquement pour calculer la profondeur relative de chaque bone
var _prx = dsin(dir);
var _pry = dcos(dir);

// Vecteur joueur→caméra normalisé
var _cam_dist = max(point_distance(x, y, o_cam.x, o_cam.y), 1);
var _cdx = (o_cam.x - x) / _cam_dist;
var _cdy = (o_cam.y - y) / _cam_dist;
// Dot product axe droit joueur × direction caméra
// → +1 si axe droit joueur pointe vers caméra (caméra sur le côté D)
// → -1 si axe droit joueur pointe à l'opposé (caméra sur le côté G)
var _right_dot_cam = _prx*_cdx + _pry*_cdy;

// Vecteur avant du joueur (pour projeter piv_by/end_by = axe LAT)
var _fwd_x = dcos(dir);
var _fwd_y = -dsin(dir);

// Cinématique directe
var _fk    = global.char_fk(anim_current, anim_time);
var _order = global.char_layer_order[_frame];

var _body_vb = vertex_create_buffer();
vertex_begin(_body_vb, global.vFormat);

for (var _pi = 0; _pi < 10; _pi++) {
    var _pid  = _order[_pi];
    var _part = global.char_parts[_pid];
    var _bone = _fk[_pid];

    var _hw = _part.hw;

    // Position monde du PIVOT — latéral (bx) + profondeur avant/arrière (by = axe LAT)
    var _piv_by_v = variable_struct_exists(_bone,"piv_by") ? _bone.piv_by : 0;
    var _piv_bias = _bone.piv_bx * _right_dot_cam * 0.8;
    var _piv_wx = x + _bone.piv_bx * _prx + _piv_by_v * _fwd_x + _cdx * _piv_bias;
    var _piv_wy = y + _bone.piv_bx * _pry + _piv_by_v * _fwd_y + _cdy * _piv_bias;
    var _piv_wz = -(z + _bone.piv_bz);

    // Position monde du END
    var _end_by_v = variable_struct_exists(_bone,"end_by") ? _bone.end_by : 0;
    var _end_bias = _bone.end_bx * _right_dot_cam * 0.8;
    var _end_wx = x + _bone.end_bx * _prx + _end_by_v * _fwd_x + _cdx * _end_bias;
    var _end_wy = y + _bone.end_bx * _pry + _end_by_v * _fwd_y + _cdy * _end_bias;
    var _end_wz = -(z + _bone.end_bz);

    // Quad : pivot → end, ±hw perpendiculaire caméra
    // Les coins se raccordent exactement aux bones voisins
    var _Ax = _piv_wx + _brx*_hw; var _Ay = _piv_wy + _bry*_hw; var _Az = _piv_wz;
    var _Bx = _piv_wx - _brx*_hw; var _By = _piv_wy - _bry*_hw; var _Bz = _piv_wz;
    var _Cx = _end_wx - _brx*_hw; var _Cy = _end_wy - _bry*_hw; var _Cz = _end_wz;
    var _Dx = _end_wx + _brx*_hw; var _Dy = _end_wy + _bry*_hw; var _Dz = _end_wz;

    var _col = _part.col;
    vertex_position_3d(_body_vb, _Ax,_Ay,_Az); vertex_texcoord(_body_vb,0,0); vertex_color(_body_vb,_col,1);
    vertex_position_3d(_body_vb, _Bx,_By,_Bz); vertex_texcoord(_body_vb,1,0); vertex_color(_body_vb,_col,1);
    vertex_position_3d(_body_vb, _Cx,_Cy,_Cz); vertex_texcoord(_body_vb,1,1); vertex_color(_body_vb,_col,1);
    vertex_position_3d(_body_vb, _Ax,_Ay,_Az); vertex_texcoord(_body_vb,0,0); vertex_color(_body_vb,_col,1);
    vertex_position_3d(_body_vb, _Cx,_Cy,_Cz); vertex_texcoord(_body_vb,1,1); vertex_color(_body_vb,_col,1);
    vertex_position_3d(_body_vb, _Dx,_Dy,_Dz); vertex_texcoord(_body_vb,0,1); vertex_color(_body_vb,_col,1);
}

vertex_end(_body_vb);
vertex_freeze(_body_vb);

// Éclairage joueur via Shader1 (u_flat_normal=1 → normale fixe billboard)
shader_set(Shader1);
shader_set_uniform_f_array(o_cam.u_ldir,  o_cam.lit_dir);
shader_set_uniform_f(o_cam.u_lcol,  o_cam.lit_color[0], o_cam.lit_color[1], o_cam.lit_color[2]);
shader_set_uniform_f(o_cam.u_lamb,  o_cam.lit_amb);
shader_set_uniform_f(o_cam.u_lrim,  o_cam.lit_rim);
shader_set_uniform_f(o_cam.u_flat_normal, 1.0);
shader_set_uniform_f(o_cam.u_sprpos, x, y);
// Point lights salle (même config que la balle)
var _blx0 = lerp(o_cc.but1.x, o_cc.but2.x, 0.28);
var _bly0 = lerp(o_cc.but1.y, o_cc.but2.y, 0.28);
var _blx1 = lerp(o_cc.but1.x, o_cc.but2.x, 0.72);
var _bly1 = lerp(o_cc.but1.y, o_cc.but2.y, 0.72);
shader_set_uniform_f(o_cam.u_pl0,   _blx0, _bly0);
shader_set_uniform_f(o_cam.u_pl1,   _blx1, _bly1);
shader_set_uniform_f(o_cam.u_plcol, 0.38, 0.32, 0.22);
shader_set_uniform_f(o_cam.u_plrad, 420.0);
vertex_submit(_body_vb, pr_trianglelist, -1);
shader_reset();
vertex_delete_buffer(_body_vb);

// Position monde de l'ancre ballon (pour que o_b puisse suivre)
var _ball_slot = _fk[10];
if (!is_undefined(_ball_slot)) {
    anim_ball_wx = x + _ball_slot.bx * _prx + _ball_slot.by * _fwd_x;
    anim_ball_wy = y + _ball_slot.bx * _pry + _ball_slot.by * _fwd_y;
    anim_ball_wz = -(z + _ball_slot.bz);
}

// ===== INDICATEURS 3D : desactivation du z-test pour eviter le z-fighting =====
gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);

var _cx = x + 11;   // centre X du sprite
var _vy = y;
var _vb_used = false;
var _vb = vertex_create_buffer();
vertex_begin(_vb, global.vFormat);

// --- Triangle indicateur joueur contrôlé (▽) — billboard face caméra ---
if(is_me){
	var _tc = (ekipa == 1) ? #2277ff : #ff3333;
	// Direction perpendiculaire à la caméra dans le plan XY (comme la balle)
	var _cam_ang = point_direction(o_cam.x, o_cam.y, x, y);
	var _hw = 9;
	var _tlx1 = x + lengthdir_x(_hw, _cam_ang + 90);
	var _tly1 = y + lengthdir_y(_hw, _cam_ang + 90);
	var _tlx2 = x + lengthdir_x(_hw, _cam_ang - 90);
	var _tly2 = y + lengthdir_y(_hw, _cam_ang - 90);
	// ▽ : pointe en bas, base en haut
	vertex_position_3d(_vb, x,     y,     -(z+201)); vertex_texcoord(_vb, 0.5,1.0); vertex_color(_vb, _tc, 0.92);
	vertex_position_3d(_vb, _tlx1, _tly1, -(z+217)); vertex_texcoord(_vb, 0.0,0.0); vertex_color(_vb, _tc, 0.92);
	vertex_position_3d(_vb, _tlx2, _tly2, -(z+217)); vertex_texcoord(_vb, 1.0,0.0); vertex_color(_vb, _tc, 0.92);
	_vb_used = true;
}

// === helper : dessine un quad dans _vb (plan XZ, Y unique par couche) ===
// ax,bx = X gauche/droite   za,zb = game_z bas/haut   yy = Y (décalé par couche)
// col, alp = couleur/alpha

// --- Jauge TIR : zones colorées (visible quand charge tir) ---
if(mbol && is_charging_tir){ _vb_used = true;
	var _j  = jauge_tir;
	var _gw = 46;
	var _gx1 = _cx - 23;
	// Y vers caméra (+) pour passer devant les sprites
	var _y0 = _vy+2.0; var _y1 = _vy+2.1; var _y2 = _vy+2.2; var _y3 = _vy+2.3;

	// Fond gris
	var _ax=_gx1-1; var _bx=_gx1+_gw+1;
	vertex_position_3d(_vb,_ax,_y0,-(z+219)); vertex_texcoord(_vb,0,0); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_bx,_y0,-(z+219)); vertex_texcoord(_vb,1,0); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_bx,_y0,-(z+229)); vertex_texcoord(_vb,1,1); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_ax,_y0,-(z+219)); vertex_texcoord(_vb,0,0); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_bx,_y0,-(z+229)); vertex_texcoord(_vb,1,1); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_ax,_y0,-(z+229)); vertex_texcoord(_vb,0,1); vertex_color(_vb,#444444,0.85);
	// Zone blanche 0-40%
	var _z1x=_gx1; var _z2x=_gx1+_gw*0.40;
	vertex_position_3d(_vb,_z1x,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+221)); vertex_texcoord(_vb,1,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z1x,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z1x,_y1,-(z+227)); vertex_texcoord(_vb,0,1); vertex_color(_vb,c_silver,1);
	// Zone jaune 40-90%
	_z1x=_gx1+_gw*0.40; _z2x=_gx1+_gw*0.90;
	vertex_position_3d(_vb,_z1x,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_yellow,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+221)); vertex_texcoord(_vb,1,0); vertex_color(_vb,c_yellow,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_yellow,1);
	vertex_position_3d(_vb,_z1x,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_yellow,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_yellow,1);
	vertex_position_3d(_vb,_z1x,_y1,-(z+227)); vertex_texcoord(_vb,0,1); vertex_color(_vb,c_yellow,1);
	// Zone blanche 90-100%
	_z1x=_gx1+_gw*0.90; _z2x=_gx1+_gw;
	vertex_position_3d(_vb,_z1x,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+221)); vertex_texcoord(_vb,1,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z1x,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z2x,_y1,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_z1x,_y1,-(z+227)); vertex_texcoord(_vb,0,1); vertex_color(_vb,c_silver,1);
	// Zone verte précision
	var _gc=0.65; var _ghw=0.25*(precision/100);
	_z1x=_gx1+_gw*(_gc-_ghw); _z2x=_gx1+_gw*(_gc+_ghw);
	vertex_position_3d(_vb,_z1x,_y2,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_lime,0.9);
	vertex_position_3d(_vb,_z2x,_y2,-(z+221)); vertex_texcoord(_vb,1,0); vertex_color(_vb,c_lime,0.9);
	vertex_position_3d(_vb,_z2x,_y2,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_lime,0.9);
	vertex_position_3d(_vb,_z1x,_y2,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_lime,0.9);
	vertex_position_3d(_vb,_z2x,_y2,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_lime,0.9);
	vertex_position_3d(_vb,_z1x,_y2,-(z+227)); vertex_texcoord(_vb,0,1); vertex_color(_vb,c_lime,0.9);
	// Curseur rouge
	var _cxp=_gx1+_gw*(_j/100);
	vertex_position_3d(_vb,_cxp-1.5,_y3,-(z+218)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_red,1);
	vertex_position_3d(_vb,_cxp+1.5,_y3,-(z+218)); vertex_texcoord(_vb,1,0); vertex_color(_vb,c_red,1);
	vertex_position_3d(_vb,_cxp+1.5,_y3,-(z+230)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_red,1);
	vertex_position_3d(_vb,_cxp-1.5,_y3,-(z+218)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_red,1);
	vertex_position_3d(_vb,_cxp+1.5,_y3,-(z+230)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_red,1);
	vertex_position_3d(_vb,_cxp-1.5,_y3,-(z+230)); vertex_texcoord(_vb,0,1); vertex_color(_vb,c_red,1);
}

// --- Jauge PASSE : barre simple blanche ---
if(mbol && is_charging_passe){ _vb_used = true;
	var _jp = jauge_passe;
	var _gw = 46; var _gx1 = _cx-23;
	var _y0 = _vy+2.0; var _y1 = _vy+2.1; var _y3 = _vy+2.2;
	// Fond gris
	vertex_position_3d(_vb,_gx1-1,    _y0,-(z+219)); vertex_texcoord(_vb,0,0); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_gx1+_gw+1,_y0,-(z+219)); vertex_texcoord(_vb,1,0); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_gx1+_gw+1,_y0,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_gx1-1,    _y0,-(z+219)); vertex_texcoord(_vb,0,0); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_gx1+_gw+1,_y0,-(z+227)); vertex_texcoord(_vb,1,1); vertex_color(_vb,#444444,0.85);
	vertex_position_3d(_vb,_gx1-1,    _y0,-(z+227)); vertex_texcoord(_vb,0,1); vertex_color(_vb,#444444,0.85);
	// Barre blanche
	var _fx = _gx1 + _gw*(_jp/100);
	vertex_position_3d(_vb,_gx1,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_white,1);
	vertex_position_3d(_vb,_fx, _y1,-(z+221)); vertex_texcoord(_vb,1,0); vertex_color(_vb,c_white,1);
	vertex_position_3d(_vb,_fx, _y1,-(z+225)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_white,1);
	vertex_position_3d(_vb,_gx1,_y1,-(z+221)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_white,1);
	vertex_position_3d(_vb,_fx, _y1,-(z+225)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_white,1);
	vertex_position_3d(_vb,_gx1,_y1,-(z+225)); vertex_texcoord(_vb,0,1); vertex_color(_vb,c_white,1);
	// Curseur gris
	var _cxp = _gx1+_gw*(_jp/100);
	vertex_position_3d(_vb,_cxp-1.5,_y3,-(z+218)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_cxp+1.5,_y3,-(z+218)); vertex_texcoord(_vb,1,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_cxp+1.5,_y3,-(z+228)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_cxp-1.5,_y3,-(z+218)); vertex_texcoord(_vb,0,0); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_cxp+1.5,_y3,-(z+228)); vertex_texcoord(_vb,1,1); vertex_color(_vb,c_silver,1);
	vertex_position_3d(_vb,_cxp-1.5,_y3,-(z+228)); vertex_texcoord(_vb,0,1); vertex_color(_vb,c_silver,1);
}

// --- Indicateur pre-move ---
if(!mbol && pm_action != -1 && o_cc.bb.e_pocesseur == ekipa){ _vb_used = true;
	var _pcol = (pm_action == 1) ? c_red : c_aqua;
	var _gw2 = 38;
	var _pcx = _cx;
	var _pcy  = _vy + 2.0;
	var _pcy2 = _vy + 2.1;
	var _gx1b = _pcx - 19;
	var _pz = z;
	// Fond sombre
	vertex_position_3d(_vb,_gx1b,      _pcy,-(_pz+200)); vertex_texcoord(_vb,0,0); vertex_color(_vb,#333333,0.8);
	vertex_position_3d(_vb,_gx1b+_gw2, _pcy,-(_pz+200)); vertex_texcoord(_vb,1,0); vertex_color(_vb,#333333,0.8);
	vertex_position_3d(_vb,_gx1b+_gw2, _pcy,-(_pz+206)); vertex_texcoord(_vb,1,1); vertex_color(_vb,#333333,0.8);
	vertex_position_3d(_vb,_gx1b,      _pcy,-(_pz+200)); vertex_texcoord(_vb,0,0); vertex_color(_vb,#333333,0.8);
	vertex_position_3d(_vb,_gx1b+_gw2, _pcy,-(_pz+206)); vertex_texcoord(_vb,1,1); vertex_color(_vb,#333333,0.8);
	vertex_position_3d(_vb,_gx1b,      _pcy,-(_pz+206)); vertex_texcoord(_vb,0,1); vertex_color(_vb,#333333,0.8);
	// Barre colorée
	var _fxr = _gx1b + _gw2*(pm_jauge/100);
	vertex_position_3d(_vb,_gx1b,_pcy2,-(_pz+201)); vertex_texcoord(_vb,0,0); vertex_color(_vb,_pcol,1);
	vertex_position_3d(_vb,_fxr, _pcy2,-(_pz+201)); vertex_texcoord(_vb,1,0); vertex_color(_vb,_pcol,1);
	vertex_position_3d(_vb,_fxr, _pcy2,-(_pz+205)); vertex_texcoord(_vb,1,1); vertex_color(_vb,_pcol,1);
	vertex_position_3d(_vb,_gx1b,_pcy2,-(_pz+201)); vertex_texcoord(_vb,0,0); vertex_color(_vb,_pcol,1);
	vertex_position_3d(_vb,_fxr, _pcy2,-(_pz+205)); vertex_texcoord(_vb,1,1); vertex_color(_vb,_pcol,1);
	vertex_position_3d(_vb,_gx1b,_pcy2,-(_pz+205)); vertex_texcoord(_vb,0,1); vertex_color(_vb,_pcol,1);
}

vertex_end(_vb);
if(_vb_used){
	vertex_freeze(_vb);
	vertex_submit(_vb, pr_trianglelist, -1);
}
vertex_delete_buffer(_vb);

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

// --- Trajectoire pre-move : ruban 3D moi→panier si tir programmé et mon équipe a le ballon ---
if(!mbol && pm_action == 1 && o_cc.bb.e_pocesseur == ekipa){
	var _bx = (ekipa==1) ? o_cc.but2.x : o_cc.but1.x;
	var _by = (ekipa==1) ? o_cc.but2.y : o_cc.but1.y;
	var _dist = max(point_distance(x, y, _bx, _by), 1);
	var _dx2 = (_bx - x) / _dist;
	var _dy2 = (_by - y) / _dist;
	var _pw = 2;
	var _lcol = (ekipa==1) ? #2277ff : #ff3333;
	var _lz  = z + 2;

	var _p1x = x - _dy2*_pw;  var _p1y = y + _dx2*_pw;
	var _p2x = x + _dy2*_pw;  var _p2y = y - _dx2*_pw;
	var _p3x = _bx + _dy2*_pw;  var _p3y = _by  - _dx2*_pw;
	var _p4x = _bx - _dy2*_pw;  var _p4y = _by  + _dx2*_pw;

	var _vbl = vertex_create_buffer();
	vertex_begin(_vbl, global.vFormat);
	vertex_position_3d(_vbl,_p1x,_p1y,-_lz); vertex_texcoord(_vbl,0,0); vertex_color(_vbl,_lcol,0.45);
	vertex_position_3d(_vbl,_p2x,_p2y,-_lz); vertex_texcoord(_vbl,1,0); vertex_color(_vbl,_lcol,0.45);
	vertex_position_3d(_vbl,_p3x,_p3y,-_lz); vertex_texcoord(_vbl,1,1); vertex_color(_vbl,_lcol,0.45);
	vertex_position_3d(_vbl,_p1x,_p1y,-_lz); vertex_texcoord(_vbl,0,0); vertex_color(_vbl,_lcol,0.45);
	vertex_position_3d(_vbl,_p3x,_p3y,-_lz); vertex_texcoord(_vbl,1,1); vertex_color(_vbl,_lcol,0.45);
	vertex_position_3d(_vbl,_p4x,_p4y,-_lz); vertex_texcoord(_vbl,0,1); vertex_color(_vbl,_lcol,0.45);
	vertex_end(_vbl);
	vertex_freeze(_vbl);
	vertex_submit(_vbl, pr_trianglelist, -1);
	vertex_delete_buffer(_vbl);
}
