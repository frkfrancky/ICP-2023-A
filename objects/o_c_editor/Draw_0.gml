if (!variable_global_exists("anim_lib")) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

var _col_bg      = #0D0D18;
var _col_panel   = #161628;
var _col_panel2  = #1E1E38;
var _col_border  = #333366;
var _col_sel     = #4444BB;
var _col_hover   = #222244;
var _col_kf_col  = #FFDD44;
var _col_kf_sel  = #FF4444;
var _col_tl_head = #FF6600;
var _col_notif   = #44FF88;

draw_set_alpha(1);
draw_set_color(_col_bg);
draw_rectangle(0, 0, _gw, _gh, false);

// ═══ PANNEAU GAUCHE ══════════════════════════════════════════════
draw_set_color(_col_panel);
draw_rectangle(0, 0, ed_panel_left_w, ed_timeline_y, false);
draw_set_color(_col_border);
draw_rectangle(0, 0, ed_panel_left_w, ed_timeline_y, true);

draw_set_font(-1);
draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_top);
draw_text(ed_panel_left_w*0.5, 8, "ANIMATIONS");

var _anim_names = variable_struct_get_names(global.anim_lib);
var _na_count   = array_length(_anim_names);
var _row0_y     = 36;
for (var _i = 0; _i < _na_count; _i++) {
    var _ry = _row0_y + (_i - ed_anim_scroll) * ed_lh;
    if (_ry < 30 || _ry >= ed_timeline_y - 112) continue;
    var _is_sel = (_anim_names[_i] == ed_sel_anim);
    var _is_hov = (_mx < ed_panel_left_w && _my >= _ry && _my < _ry+ed_lh);
    draw_set_color(_is_sel ? _col_sel : (_is_hov ? _col_hover : _col_panel2));
    draw_rectangle(4, _ry, ed_panel_left_w-4, _ry+ed_lh-2, false);
    draw_set_color(c_white);
    draw_set_halign(fa_left); draw_set_valign(fa_middle);
    draw_text(12, _ry+ed_lh*0.5, _anim_names[_i]);
}

// Boutons + / - anim
var _btn_y = ed_timeline_y - 112;
draw_set_halign(fa_center); draw_set_valign(fa_middle);
draw_set_color(_col_panel2); draw_rectangle(4,   _btn_y, 136, _btn_y+28, false);
draw_set_color(_col_border);  draw_rectangle(4,   _btn_y, 136, _btn_y+28, true);
draw_set_color(c_white);      draw_text(70,        _btn_y+14, "+ Nouvelle");
draw_set_color(_col_panel2); draw_rectangle(140, _btn_y, 275, _btn_y+28, false);
draw_set_color(_col_border);  draw_rectangle(140, _btn_y, 275, _btn_y+28, true);
draw_set_color(c_white);      draw_text(207,      _btn_y+14, "- Supprimer");

// Export / Import
var _exp_y = _btn_y + 34;
draw_set_color(_col_panel2); draw_rectangle(4,   _exp_y, 136, _exp_y+28, false);
draw_set_color(_col_border);  draw_rectangle(4,   _exp_y, 136, _exp_y+28, true);
draw_set_color(#44DDAA);      draw_text(70,        _exp_y+14, "↑ Exporter");
draw_set_color(_col_panel2); draw_rectangle(140, _exp_y, 275, _exp_y+28, false);
draw_set_color(_col_border);  draw_rectangle(140, _exp_y, 275, _exp_y+28, true);
draw_set_color(#AADDFF);      draw_text(207,      _exp_y+14, "↓ Importer");

draw_set_color(#444466); draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_text(4, _exp_y+34, "Auto: .../" + string_copy(working_directory, max(1,string_length(working_directory)-30), 30));

// ═══ PANNEAU DROIT ═══════════════════════════════════════════════
var _rx0 = ed_panel_left_w + ed_preview_w;
draw_set_color(_col_panel);
draw_rectangle(_rx0, 0, _gw, ed_timeline_y, false);
draw_set_color(_col_border);
draw_rectangle(_rx0, 0, _gw, ed_timeline_y, true);

draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_top);
draw_text(_rx0+ed_panel_right_w*0.5, 8, "KEYFRAMES");

if (ed_sel_anim != "" && variable_struct_exists(global.anim_lib, ed_sel_anim)) {
    var _anim  = global.anim_lib[$ ed_sel_anim];
    var _kf    = _anim.kf;
    var _nkf   = array_length(_kf);

    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_text(_rx0+8, 28, "Anim : " + ed_sel_anim);
    draw_text(_rx0+8, 44, "Durée : " + string(_anim.length) + " steps");

    // ── Boutons KF (y 60-178) ────────────────────────────────────────
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    // + KF / Coller  (y=60-88)
    draw_set_color(ed_copy_kf >= 0 ? _col_sel : _col_panel2);
    draw_rectangle(_rx0+8,  60, _rx0+148, 88, false);
    draw_set_color(_col_border); draw_rectangle(_rx0+8, 60, _rx0+148, 88, true);
    draw_set_color(ed_copy_kf >= 0 ? #44FFAA : c_white);
    draw_text(_rx0+78, 74, ed_copy_kf >= 0 ? "↓ Coller KF" : "+ KF après");
    // - KF  (y=92-120)
    draw_set_color(_col_panel2); draw_rectangle(_rx0+8,  92, _rx0+148, 120, false);
    draw_set_color(_col_border);  draw_rectangle(_rx0+8,  92, _rx0+148, 120, true);
    draw_set_color(c_white);      draw_text(_rx0+78, 106, "- KF  (" + string(_nkf) + ")");
    // < durée >  (y=124-152)
    draw_set_color(_col_panel2); draw_rectangle(_rx0+8, 124, _rx0+148, 152, false);
    draw_set_color(_col_border);  draw_rectangle(_rx0+8, 124, _rx0+148, 152, true);
    draw_set_color(c_white);      draw_text(_rx0+78, 138, "< " + string(_anim.length) + " steps >");
    // Copier KF  (y=156-180)
    draw_set_color(ed_copy_kf == ed_sel_kf ? _col_sel : _col_panel2);
    draw_rectangle(_rx0+8, 156, _rx0+148, 180, false);
    draw_set_color(_col_border); draw_rectangle(_rx0+8, 156, _rx0+148, 180, true);
    draw_set_color(ed_copy_kf >= 0 ? _col_kf_col : #AAAAAA);
    draw_text(_rx0+78, 168, ed_copy_kf >= 0 ? "✓ Copié [" + string(ed_copy_kf) + "]" : "Copier KF");

    // ── Zoom (y=184-196) ─────────────────────────────────────────────
    draw_set_color(_col_border); draw_line(_rx0, 184, _gw, 184);
    draw_set_color(#666688); draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_text(_rx0+8, 187, "Zoom ×" + string(round(prev_scale*10)*0.1) + "  [Ctrl+molette]");

    // ── Axe molette (y=200-280) ──────────────────────────────────────
    draw_set_color(_col_border); draw_line(_rx0, 200, _gw, 200);
    draw_set_color(#AAAACC); draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_text(_rx0+8, 204, ed_sel_part == 10 ? "Ballon — axe molette :" : "Axe molette (os) :");

    var _hw2 = (ed_panel_right_w - 26) / 2;
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    if (ed_sel_part == 10) {
        draw_set_color(ed_sel_axis == 0 ? _col_sel : _col_panel2);
        draw_rectangle(_rx0+8,        218, _rx0+8+_hw2,    246, false);
        draw_set_color(ed_sel_axis == 0 ? c_white : _col_border);
        draw_rectangle(_rx0+8,        218, _rx0+8+_hw2,    246, true);
        draw_set_color(ed_sel_axis == 0 ? #FFCC00 : #888866);
        draw_text(_rx0+8+_hw2*0.5,   232, "HAUTEUR Z");
        draw_set_color(ed_sel_axis == 1 ? _col_sel : _col_panel2);
        draw_rectangle(_rx0+12+_hw2,  218, _rx0+12+_hw2*2, 246, false);
        draw_set_color(ed_sel_axis == 1 ? c_white : _col_border);
        draw_rectangle(_rx0+12+_hw2,  218, _rx0+12+_hw2*2, 246, true);
        draw_set_color(ed_sel_axis == 1 ? #FFCC00 : #888866);
        draw_text(_rx0+12+_hw2*1.5,  232, "LAT BX");
    } else {
        draw_set_color(ed_sel_axis == 0 ? _col_sel : _col_panel2);
        draw_rectangle(_rx0+8,        218, _rx0+8+_hw2,    246, false);
        draw_set_color(ed_sel_axis == 0 ? c_white : _col_border);
        draw_rectangle(_rx0+8,        218, _rx0+8+_hw2,    246, true);
        draw_set_color(ed_sel_axis == 0 ? c_white : #888888);
        draw_text(_rx0+8+_hw2*0.5,   232, "SWING ↕");
        draw_set_color(ed_sel_axis == 1 ? _col_sel : _col_panel2);
        draw_rectangle(_rx0+12+_hw2,  218, _rx0+12+_hw2*2, 246, false);
        draw_set_color(ed_sel_axis == 1 ? c_white : _col_border);
        draw_rectangle(_rx0+12+_hw2,  218, _rx0+12+_hw2*2, 246, true);
        draw_set_color(ed_sel_axis == 1 ? c_white : #888888);
        draw_text(_rx0+12+_hw2*1.5,  232, "LAT ↔");
    }
    // Toggle ballon (y=250-274)
    draw_set_color(ed_show_ball ? #FF8800 : _col_panel2);
    draw_rectangle(_rx0+8, 250, _rx0+ed_panel_right_w-8, 274, false);
    draw_set_color(_col_border); draw_rectangle(_rx0+8, 250, _rx0+ed_panel_right_w-8, 274, true);
    draw_set_color(ed_show_ball ? c_white : #888888);
    draw_text(_rx0+ed_panel_right_w*0.5, 262, ed_show_ball ? "● Ballon ON" : "○ Ballon OFF");

    // ── Infos sélection (y=278+) ─────────────────────────────────────
    draw_set_color(_col_border); draw_line(_rx0, 278, _gw, 278);
    draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top);
    if (ed_sel_kf >= 0 && ed_sel_kf < _nkf) {
        var _cur_kf = _kf[ed_sel_kf];
        var _rz_val = variable_struct_exists(_cur_kf,"root_z") ? _cur_kf.root_z : 0;
        if (ed_sel_part == 10) {
            draw_text(_rx0+8, 282, "BALLON  KF[" + string(ed_sel_kf) + "] :");
            var _bv = variable_struct_exists(_cur_kf,"ball") ? _cur_kf.ball : {bx:5,by:10,bz:30};
            draw_set_color(ed_sel_axis == 0 ? _col_kf_sel : #FF8800);
            draw_text(_rx0+8, 300, "BZ hauteur : " + string(round(_bv.bz)));
            draw_set_color(ed_sel_axis == 1 ? _col_kf_sel : #FF8800);
            draw_text(_rx0+8, 318, "BX latéral : " + string(round(_bv.bx)));
            draw_set_color(#AA6600);
            draw_text(_rx0+8, 336, "BY profond : " + string(round(_bv.by)) + "  [Ctrl]");
            draw_set_color(#555577);
            draw_text(_rx0+8, 354, "Maj=±5   sinon ±1");
            draw_set_color(#AAAACC);
            draw_text(_rx0+8, 372, "Root Z : " + string(round(_rz_val)));
        } else if (ed_sel_part >= 0) {
            draw_text(_rx0+8, 282, ed_part_names[ed_sel_part] + "  KF[" + string(ed_sel_kf) + "] :");
            var _has_lat = variable_struct_exists(_cur_kf,"angles_lat");
            draw_set_color(ed_sel_axis == 0 ? _col_kf_sel : #888888);
            draw_text(_rx0+8, 300, "Swing : " + string(_cur_kf.angles[ed_sel_part]) + "°");
            draw_set_color(ed_sel_axis == 1 ? _col_kf_sel : #888888);
            draw_text(_rx0+8, 318, "Lat   : " + string(_has_lat ? _cur_kf.angles_lat[ed_sel_part] : 0) + "°");
            draw_set_color(#555577);
            draw_text(_rx0+8, 336, "Molette=±1°   Maj=±5°");
            draw_set_color(#AAAACC);
            draw_text(_rx0+8, 354, "Root Z : " + string(round(_rz_val)));
        } else {
            draw_set_color(#AAFFAA);
            draw_text(_rx0+8, 282, "Root Z  KF[" + string(ed_sel_kf) + "] :");
            draw_set_color(_col_kf_sel);
            draw_text(_rx0+8, 300, "Z = " + string(round(_rz_val)) + " px");
            draw_set_color(#555577);
            draw_text(_rx0+8, 318, "Molette = monte/descend");
            draw_set_color(#888888);
            draw_text(_rx0+8, 338, "(cliquer un os ou ballon)");
        }

        // ── Liste angles (y=378+) ──────────────────────────────────────
        draw_set_color(_col_border); draw_line(_rx0, 378, _gw, 378);
        draw_set_color(c_white); draw_set_halign(fa_left);
        draw_text(_rx0+8, 382, "KF[" + string(ed_sel_kf) + "]  swing / lat :");
        var _has_lat2 = variable_struct_exists(_cur_kf,"angles_lat");
        for (var _i = 0; _i < 10; _i++) {
            var _ty = 400 + _i*20;
            if (_ty > _gh-8) break;
            draw_set_color((_i == ed_sel_part) ? _col_kf_sel : #AAAAAA);
            var _s2 = _cur_kf.angles[_i];
            var _l2 = _has_lat2 ? _cur_kf.angles_lat[_i] : 0;
            draw_text(_rx0+8, _ty, ed_part_names[_i] + ": " + string(_s2) + "° / " + string(_l2) + "°");
        }
    }
}

// ═══ ZONE PRÉVIEW 3D (rendu identique au match) ══════════════════
var _pv_x0 = ed_panel_left_w;
var _pv_x1 = _pv_x0 + ed_preview_w;
var _sw = ed_preview_w;
var _sh = ed_timeline_y;

// ── Surface 3D ──────────────────────────────────────────────────
if (!surface_exists(ed_3d_surf) || surface_get_width(ed_3d_surf) != _sw || surface_get_height(ed_3d_surf) != _sh) {
    if (surface_exists(ed_3d_surf)) surface_free(ed_3d_surf);
    ed_3d_surf = surface_create(_sw, _sh);
}

// Sauvegarde matrices 2D courantes
var _mat_v_save = matrix_get(matrix_view);
var _mat_p_save = matrix_get(matrix_projection);

surface_set_target(ed_3d_surf);
draw_clear(#090915);

// Grille de fond
draw_set_color(#14142A);
for (var _gx = 0; _gx < _sw; _gx += 40) draw_line(_gx, 0, _gx, _sh);
for (var _gy = 0; _gy < _sh; _gy += 40) draw_line(0, _gy, _sw, _gy);
// Ligne sol
draw_set_color(#303060);
draw_line(20, _sh * 0.74, _sw-20, _sh * 0.74);

// ── Caméra 3D perspective (identique au match, fov=35) ─────────
var _ed_cam  = camera_create();
var _cam_dist = ed_cam_dist_base / prev_scale;
// Caméra au sud (Y positif), personnage à l'origine, hauteur calée sur centre
var _look_z   = -(global.char_root_bz * 0.5);  // -25 ≈ milieu du torse
camera_set_view_mat(_ed_cam, matrix_build_lookat(
    0, _cam_dist, _look_z,   // pos caméra
    0, 0,         _look_z,   // cible
    0, 0,         1));        // up = Z
var _asp_3d = _sw / _sh;
camera_set_proj_mat(_ed_cam, matrix_build_projection_perspective_fov(35, _asp_3d, 1, 5000));
camera_apply(_ed_cam);
camera_destroy(_ed_cam);

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

// ── Rendu squelette exactement comme o_p/Draw_0 ─────────────────
if (variable_global_exists("char_fk") && ed_sel_anim != ""
 && variable_struct_exists(global.anim_lib, ed_sel_anim)) {
    var _fk = global.char_fk(ed_sel_anim, tl_time);
    if (!is_undefined(_fk)) {
        var _dir       = prev_dir;
        var _prx       = dsin(_dir);  // axe droit du perso
        var _pry       = dcos(_dir);
        var _fwd_x     = dcos(_dir);  // axe avant du perso
        var _fwd_y     = -dsin(_dir);
        // Caméra au sud (0, +dist) → vecteur perso→caméra = (0,1)
        var _cdx       = 0;  var _cdy = 1;
        var _right_dot = _prx*_cdx + _pry*_cdy;
        // Billboard : perpendiculaire caméra-sud = axe X (1,0)
        var _brx       = 1;  var _bry = 0;
        var _rel_ang   = ((90 - _dir) mod 360 + 360) mod 360;
        var _frame     = (8 - (round(_rel_ang/45) mod 8)) mod 8;
        var _order     = global.char_layer_order[_frame];

        var _vb = vertex_create_buffer();
        vertex_begin(_vb, global.vFormat);

        for (var _pi = 0; _pi < 10; _pi++) {
            var _pid  = _order[_pi];
            var _part = global.char_parts[_pid];
            var _bone = _fk[_pid];
            var _hw   = _part.hw;

            var _piv_by = variable_struct_exists(_bone,"piv_by") ? _bone.piv_by : 0;
            var _pb     = _bone.piv_bx * _right_dot * 0.8;
            var _piv_wx = _bone.piv_bx * _prx + _piv_by * _fwd_x + _cdx * _pb;
            var _piv_wy = _bone.piv_bx * _pry + _piv_by * _fwd_y + _cdy * _pb;
            var _piv_wz = -_bone.piv_bz;

            var _end_by = variable_struct_exists(_bone,"end_by") ? _bone.end_by : 0;
            var _eb     = _bone.end_bx * _right_dot * 0.8;
            var _end_wx = _bone.end_bx * _prx + _end_by * _fwd_x + _cdx * _eb;
            var _end_wy = _bone.end_bx * _pry + _end_by * _fwd_y + _cdy * _eb;
            var _end_wz = -_bone.end_bz;

            var _Ax=_piv_wx+_brx*_hw; var _Ay=_piv_wy+_bry*_hw; var _Az=_piv_wz;
            var _Bx=_piv_wx-_brx*_hw; var _By=_piv_wy-_bry*_hw; var _Bz=_piv_wz;
            var _Cx=_end_wx-_brx*_hw; var _Cy=_end_wy-_bry*_hw; var _Cz=_end_wz;
            var _Dx=_end_wx+_brx*_hw; var _Dy=_end_wy+_bry*_hw; var _Dz=_end_wz;

            var _col = _part.col;
            if (_pid == ed_sel_part)      _col = merge_color(_col, c_white,  0.5);
            else if (_pid == ed_hover_part) _col = merge_color(_col, c_yellow, 0.3);

            vertex_position_3d(_vb,_Ax,_Ay,_Az); vertex_texcoord(_vb,0,0); vertex_color(_vb,_col,1);
            vertex_position_3d(_vb,_Bx,_By,_Bz); vertex_texcoord(_vb,1,0); vertex_color(_vb,_col,1);
            vertex_position_3d(_vb,_Cx,_Cy,_Cz); vertex_texcoord(_vb,1,1); vertex_color(_vb,_col,1);
            vertex_position_3d(_vb,_Ax,_Ay,_Az); vertex_texcoord(_vb,0,0); vertex_color(_vb,_col,1);
            vertex_position_3d(_vb,_Cx,_Cy,_Cz); vertex_texcoord(_vb,1,1); vertex_color(_vb,_col,1);
            vertex_position_3d(_vb,_Dx,_Dy,_Dz); vertex_texcoord(_vb,0,1); vertex_color(_vb,_col,1);
        }
        vertex_end(_vb);
        vertex_freeze(_vb);

        shader_set(Shader1);
        shader_set_uniform_f_array(ed_u_ldir,  ed_lit_dir);
        shader_set_uniform_f(ed_u_lcol,  ed_lit_color[0], ed_lit_color[1], ed_lit_color[2]);
        shader_set_uniform_f(ed_u_lamb,  ed_lit_amb);
        shader_set_uniform_f(ed_u_lrim,  ed_lit_rim);
        shader_set_uniform_f(ed_u_flat_normal, 1.0);
        shader_set_uniform_f(ed_u_sprpos, 0, 0);
        shader_set_uniform_f(ed_u_pl0,   0, 0);
        shader_set_uniform_f(ed_u_pl1,   0, 0);
        shader_set_uniform_f(ed_u_plcol, 0, 0, 0);
        shader_set_uniform_f(ed_u_plrad, 1);
        vertex_submit(_vb, pr_trianglelist, -1);
        shader_reset();
        vertex_delete_buffer(_vb);

        // ── Ballon ──────────────────────────────────────────────
        if (ed_show_ball && !is_undefined(_fk[10])) {
            var _bll  = _fk[10];
            var _bpb  = _bll.bx * _right_dot * 0.8;
            var _bwx  = _bll.bx * _prx + _bll.by * _fwd_x + _cdx * _bpb;
            var _bwy  = _bll.bx * _pry + _bll.by * _fwd_y + _cdy * _bpb;
            var _bwz  = -_bll.bz;
            var _brad = ed_ball_rad;  // rayon en unités monde
            // Quad billboard circulaire (4 sommets)
            var _bvb = vertex_create_buffer();
            vertex_begin(_bvb, global.vFormat);
            var _bsel = (ed_sel_part == 10); var _bhov = (ed_hover_part == 10);
            var _bcol = _bsel ? #FFCC00 : (_bhov ? c_yellow : #FF8800);
            vertex_position_3d(_bvb,_bwx+_brx*_brad, _bwy+_bry*_brad, _bwz+_brad); vertex_texcoord(_bvb,0,0); vertex_color(_bvb,_bcol,1);
            vertex_position_3d(_bvb,_bwx-_brx*_brad, _bwy-_bry*_brad, _bwz+_brad); vertex_texcoord(_bvb,1,0); vertex_color(_bvb,_bcol,1);
            vertex_position_3d(_bvb,_bwx-_brx*_brad, _bwy-_bry*_brad, _bwz-_brad); vertex_texcoord(_bvb,1,1); vertex_color(_bvb,_bcol,1);
            vertex_position_3d(_bvb,_bwx+_brx*_brad, _bwy+_bry*_brad, _bwz+_brad); vertex_texcoord(_bvb,0,0); vertex_color(_bvb,_bcol,1);
            vertex_position_3d(_bvb,_bwx-_brx*_brad, _bwy-_bry*_brad, _bwz-_brad); vertex_texcoord(_bvb,1,1); vertex_color(_bvb,_bcol,1);
            vertex_position_3d(_bvb,_bwx+_brx*_brad, _bwy+_bry*_brad, _bwz-_brad); vertex_texcoord(_bvb,0,1); vertex_color(_bvb,_bcol,1);
            vertex_end(_bvb); vertex_freeze(_bvb);
            vertex_submit(_bvb, pr_trianglelist, -1);
            vertex_delete_buffer(_bvb);
        }

        // ── Sauvegarder positions projetées pour hover (2D approx.) ─
        // On projette manuellement les centres en coordonnées surface
        // pour que Step_0 puisse détecter les clics correctement
        var _tan_half = tan(degtorad(35 * 0.5));
        for (var _ci = 0; _ci < 10; _ci++) {
            var _b    = _fk[_ci];
            var _pby2 = variable_struct_exists(_b,"piv_by") ? _b.piv_by : 0;
            var _eby2 = variable_struct_exists(_b,"end_by")  ? _b.end_by  : 0;
            var _cx3  = (_b.piv_bx + _b.end_bx) * 0.5 * _prx
                      + (_pby2 + _eby2) * 0.5 * _fwd_x;
            var _cy3  = (_b.piv_bx + _b.end_bx) * 0.5 * _pry
                      + (_pby2 + _eby2) * 0.5 * _fwd_y;
            var _cz3  = -(_b.piv_bz + _b.end_bz) * 0.5;
            var _dist3= max(_cam_dist - _cy3, 1);
            var _px   = _cx3 / (_dist3 * _tan_half * _asp_3d) * (_sw * 0.5) + _sw * 0.5;
            var _py   = -(_cz3 - _look_z) / (_dist3 * _tan_half) * (_sh * 0.5) + _sh * 0.5;
            ed_bone_sx[_ci] = _pv_x0 + _px;
            ed_bone_sy[_ci] = _py;
        }
        // Ballon slot 10
        if (!is_undefined(_fk[10])) {
            var _bll2 = _fk[10];
            var _bpb2 = _bll2.bx * _right_dot * 0.8;
            var _bwx2 = _bll2.bx * _prx + _bll2.by * _fwd_x + _cdx * _bpb2;
            var _bwy2 = _bll2.bx * _pry + _bll2.by * _fwd_y + _cdy * _bpb2;
            var _bwz2 = -_bll2.bz;
            var _d2   = max(_cam_dist - _bwy2, 1);
            ed_bone_sx[10] = _pv_x0 + _bwx2 / (_d2*_tan_half*_asp_3d)*(_sw*0.5) + _sw*0.5;
            ed_bone_sy[10] = -(_bwz2 - _look_z) / (_d2*_tan_half)*(_sh*0.5) + _sh*0.5;
        }
    }
}

gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);
surface_reset_target();

// Restaurer matrices 2D
matrix_set(matrix_view, _mat_v_save);
matrix_set(matrix_projection, _mat_p_save);

// ── Afficher la surface dans la zone preview ──────────────────────
draw_surface(ed_3d_surf, _pv_x0, 0);

// Étiquette
draw_set_color(#444466);
draw_set_halign(fa_center); draw_set_valign(fa_top);
draw_text(prev_cx, 6, "◄ ►  Tourner   dir=" + string(round(prev_dir)) + "°  [Ctrl+molette=zoom ×" + string(round(prev_scale*10)*0.1) + "]");

// Surlignage 2D (sélection / hover — overlay par-dessus la surface)
if (ed_sel_part >= 0 && ed_sel_part <= 10) {
    var _ssx = ed_bone_sx[ed_sel_part];
    var _ssy = ed_bone_sy[ed_sel_part];
    draw_set_color(c_red); draw_set_alpha(0.6);
    draw_circle(_ssx, _ssy, 8, true);
    draw_set_alpha(1);
}
if (ed_hover_part >= 0 && ed_hover_part != ed_sel_part) {
    draw_set_color(c_yellow); draw_set_alpha(0.5);
    draw_circle(ed_bone_sx[ed_hover_part], ed_bone_sy[ed_hover_part], 6, true);
    draw_set_alpha(1);
}
// Label bone sélectionné
if (ed_sel_part >= 0 && ed_sel_part <= 9) {
    draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_bottom);
    draw_text(ed_bone_sx[ed_sel_part], ed_bone_sy[ed_sel_part]-10, ed_part_names[ed_sel_part]);
} else if (ed_sel_part == 10) {
    draw_set_color(#FFCC00); draw_set_halign(fa_center); draw_set_valign(fa_bottom);
    draw_text(ed_bone_sx[10], ed_bone_sy[10]-10, "BALLE");
}

draw_set_alpha(1);

// ═══ TIMELINE ════════════════════════════════════════════════════
draw_set_color(#0A0A16);
draw_rectangle(0, ed_timeline_y, _gw, _gh, false);
draw_set_color(_col_border);
draw_line(0, ed_timeline_y, _gw, ed_timeline_y);
var _tl_x0 = ed_panel_left_w + 80;
var _tl_xw  = ed_preview_w - 90;
var _tl_y   = ed_timeline_y + 8;
draw_set_color(#1A1A30);
draw_rectangle(_tl_x0, _tl_y+20, _tl_x0+_tl_xw, _tl_y+50, false);
draw_set_color(tl_playing ? #AA2222 : #228844);
draw_rectangle(ed_panel_left_w+8, _tl_y+18, ed_panel_left_w+74, _tl_y+52, false);
draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_middle);
draw_text(ed_panel_left_w+41, _tl_y+35, tl_playing ? "STOP" : "PLAY");

if (ed_sel_anim != "" && variable_struct_exists(global.anim_lib, ed_sel_anim)) {
    var _anim3 = global.anim_lib[$ ed_sel_anim];
    var _kf3 = _anim3.kf; var _nkf3 = array_length(_kf3);
    for (var _i = 0; _i < _nkf3; _i++) {
        var _kx = _tl_x0 + _kf3[_i].t * _tl_xw;
        draw_set_color((_i == ed_sel_kf) ? _col_kf_sel : _col_kf_col);
        draw_rectangle(_kx-5, _tl_y+18, _kx+5, _tl_y+52, false);
        draw_set_color(#000000); draw_rectangle(_kx-5, _tl_y+18, _kx+5, _tl_y+52, true);
        draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_top);
        draw_text(_kx, _tl_y+54, string(_i));
    }
    var _head_x = _tl_x0 + tl_time * _tl_xw;
    draw_set_color(_col_tl_head);
    draw_line(_head_x, _tl_y+14, _head_x, _tl_y+56);
    draw_triangle(_head_x-6, _tl_y+12, _head_x+6, _tl_y+12, _head_x, _tl_y+22, false);
}

draw_set_color(#666688); draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_text(_tl_x0, _tl_y+68, "Espace=Play/Stop   Molette=Angle   Ctrl+S=Sauver   Échap=Menu");

if (ed_notif_time > 0) {
    draw_set_color(_col_notif); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_alpha(min(1.0, ed_notif_time/30.0));
    draw_text(_gw*0.5, ed_timeline_y-18, ed_notif);
    draw_set_alpha(1.0);
}
draw_set_font(-1); draw_set_color(c_white); draw_set_alpha(1);
draw_set_halign(fa_left); draw_set_valign(fa_top);
