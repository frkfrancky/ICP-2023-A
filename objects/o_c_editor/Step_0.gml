if (!variable_global_exists("anim_lib")) exit;
if (ed_sel_anim == "" || !variable_struct_exists(global.anim_lib, ed_sel_anim)) {
    var _nn = variable_struct_get_names(global.anim_lib);
    if (array_length(_nn) > 0) ed_sel_anim = _nn[0]; else exit;
}

var _mx    = device_mouse_x_to_gui(0);
var _my    = device_mouse_y_to_gui(0);
var _click = mouse_check_button_pressed(mb_left);

// Rotation préview
if (keyboard_check(vk_left))  prev_dir = (prev_dir - 2 + 360) mod 360;
if (keyboard_check(vk_right)) prev_dir = (prev_dir + 2) mod 360;
if (keyboard_check_pressed(vk_escape)) { room_goto(r_menu1); exit; }

var _anim = global.anim_lib[$ ed_sel_anim];
var _kf   = _anim.kf;
var _nkf  = array_length(_kf);

// S'assurer que chaque KF a tous les champs nécessaires
for (var _ki = 0; _ki < _nkf; _ki++) {
    if (!variable_struct_exists(_kf[_ki], "angles_lat"))
        _kf[_ki].angles_lat = array_create(10, 0);
    if (!variable_struct_exists(_kf[_ki], "root_z"))
        _kf[_ki].root_z = 0;
    if (!variable_struct_exists(_kf[_ki], "ball"))
        _kf[_ki].ball = {bx:5, by:10, bz:30};
}

// Timeline : lecture
if (keyboard_check_pressed(ord(" "))) tl_playing = !tl_playing;
if (tl_playing) {
    tl_time = (tl_time + 1.0 / _anim.length) mod 1.0;
    var _best = 0;
    for (var _i = 0; _i < _nkf; _i++) { if (_kf[_i].t <= tl_time) _best = _i; }
    ed_sel_kf = _best;
}

// Timeline : drag tête
var _tl_x0 = ed_panel_left_w + 80;
var _tl_xw  = ed_preview_w - 90;
if (_my >= ed_timeline_y+18 && _my <= ed_timeline_y+56
 && _mx >= _tl_x0 && _mx <= _tl_x0+_tl_xw && mouse_check_button(mb_left)) {
    tl_playing = false;
    tl_time = clamp((_mx-_tl_x0)/_tl_xw, 0, 0.9999);
}

// Timeline : drag KF
if (tl_drag_kf >= 0) {
    if (mouse_check_button(mb_left)) {
        var _nt  = clamp((_mx-_tl_x0)/_tl_xw, 0, 0.9999);
        var _mn  = (tl_drag_kf > 0)      ? _kf[tl_drag_kf-1].t+0.01 : 0.001;
        var _mxv = (tl_drag_kf < _nkf-1) ? _kf[tl_drag_kf+1].t-0.01 : 0.9999;
        _kf[tl_drag_kf].t = clamp(_nt, _mn, _mxv);
        ed_sel_kf = tl_drag_kf;
    } else tl_drag_kf = -1;
}
if (_click && _my >= ed_timeline_y+18 && _my <= ed_timeline_y+60) {
    for (var _i = 0; _i < _nkf; _i++) {
        var _kx = _tl_x0 + _kf[_i].t * _tl_xw;
        if (abs(_mx-_kx) < 10) { tl_drag_kf = _i; ed_sel_kf = _i; break; }
    }
}

// Hover + sélection bone + ballon
ed_hover_part = -1;
if (variable_global_exists("char_fk") && _my < ed_timeline_y
 && _mx > ed_panel_left_w && _mx < ed_panel_left_w+ed_preview_w) {
    var _fk_data = global.char_fk(ed_sel_anim, tl_time);
    var _proj_s  = dsin(prev_dir);
    var _proj_c  = dcos(prev_dir);
    var _rel_ang2 = ((90-prev_dir) mod 360+360) mod 360;
    var _frame2   = (8-(round(_rel_ang2/45) mod 8)) mod 8;
    var _order2   = global.char_layer_order[_frame2];

    // Bones (priorité inverse : celui dessiné en dernier = au-dessus)
    for (var _oi = 9; _oi >= 0; _oi--) {
        var _i  = _order2[_oi];
        var _b  = _fk_data[_i];
        var _pby2 = variable_struct_exists(_b,"piv_by") ? _b.piv_by : 0;
        var _eby2 = variable_struct_exists(_b,"end_by")  ? _b.end_by  : 0;
        var _cx = prev_cx + ((_b.piv_bx+_b.end_bx)*0.5*_proj_s + (_pby2+_eby2)*0.5*_proj_c) * prev_scale;
        var _cy = prev_cy - (_b.piv_bz+_b.end_bz)*0.5 * prev_scale;
        if (point_distance(_mx, _my, _cx, _cy) < 22) { ed_hover_part = _i; break; }
    }
    // Ballon (slot 10)
    if (ed_show_ball && !is_undefined(_fk_data[10])) {
        var _bll = _fk_data[10];
        var _bsx = prev_cx + (_bll.bx * _proj_s + _bll.by * _proj_c) * prev_scale;
        var _bsy = prev_cy - _bll.bz * prev_scale;
        if (point_distance(_mx, _my, _bsx, _bsy) < 16) ed_hover_part = 10;
    }

    if (_click) {
        if (ed_hover_part >= 0) { ed_sel_part = ed_hover_part; tl_playing = false; }
        else if (_my < ed_timeline_y) { ed_sel_part = -1; } // déselect
    }
}

// Zoom preview (Ctrl + molette, ou boutons +/-)
var _in_preview = (_mx > ed_panel_left_w && _mx < ed_panel_left_w+ed_preview_w);
if (_in_preview && keyboard_check(vk_control)) {
    var _zscroll = mouse_wheel_up() - mouse_wheel_down();
    if (_zscroll != 0) {
        prev_zoom_target = clamp(prev_zoom_target + _zscroll * 0.3, 0.5, 10.0);
    }
}
prev_scale = lerp(prev_scale, prev_zoom_target, 0.2);

// Molette : édition angle bone / ballon / root_z
if (ed_sel_kf >= 0 && ed_sel_kf < _nkf && _in_preview && !keyboard_check(vk_control)) {
    var _scroll = mouse_wheel_up() - mouse_wheel_down();
    if (_scroll != 0) {
        var _step = keyboard_check(vk_shift) ? 5 : 1;
        if (ed_sel_part >= 0 && ed_sel_part <= 9) {
            // Bone : swing ou lat
            if (ed_sel_axis == 0)
                _kf[ed_sel_kf].angles[ed_sel_part]     = (_kf[ed_sel_kf].angles[ed_sel_part]     + _scroll*_step + 360) mod 360;
            else
                _kf[ed_sel_kf].angles_lat[ed_sel_part] = (_kf[ed_sel_kf].angles_lat[ed_sel_part] + _scroll*_step + 360) mod 360;
        } else if (ed_sel_part == 10) {
            // Ballon : axe0=hauteur  axe1=latéral  ctrl=profondeur
            var _b = _kf[ed_sel_kf].ball;
            if (keyboard_check(vk_control))
                _b.by += _scroll * _step;
            else if (ed_sel_axis == 1)
                _b.bx += _scroll * _step;
            else
                _b.bz += _scroll * _step;
        } else {
            // Rien sélectionné → root_z (saut/bond du squelette entier)
            _kf[ed_sel_kf].root_z += _scroll * _step;
        }
        tl_time = _kf[ed_sel_kf].t;
    }
}

// Panneau droit
var _rx0 = ed_panel_left_w + ed_preview_w;
var _hw2 = (ed_panel_right_w - 26) / 2;
if (_click && _mx >= _rx0) {
    // + KF / Coller (y=60-88)
    if (_my >= 60 && _my < 88) {
        var _t0 = _kf[ed_sel_kf].t;
        var _t1 = (ed_sel_kf+1 < _nkf) ? _kf[ed_sel_kf+1].t : 1.0;
        // Si un KF est copié, coller ses valeurs, sinon dupliquer le KF courant
        var _src = (ed_copy_kf >= 0 && ed_copy_kf < _nkf) ? _kf[ed_copy_kf] : _kf[ed_sel_kf];
        var _na  = array_create(10,0); array_copy(_na,  0, _src.angles,     0, 10);
        var _nal = array_create(10,0); array_copy(_nal, 0, _src.angles_lat, 0, 10);
        var _nrz = _src.root_z;
        var _nb  = {bx:_src.ball.bx, by:_src.ball.by, bz:_src.ball.bz};
        array_insert(_kf, ed_sel_kf+1, {t:(_t0+_t1)*0.5, angles:_na, angles_lat:_nal, root_z:_nrz, ball:_nb});
        ed_sel_kf++; _nkf++;
        ed_notif = (ed_copy_kf >= 0) ? "KF collé" : "KF ajouté"; ed_notif_time = 60;
    }
    // - KF (y=92-120)
    if (_my >= 92 && _my < 120 && _nkf > 2) {
        array_delete(_kf, ed_sel_kf, 1); _nkf--;
        ed_sel_kf = clamp(ed_sel_kf, 0, _nkf-1);
        ed_notif = "KF supprimé"; ed_notif_time = 60;
    }
    // Longueur (y=124-152)
    if (_my >= 124 && _my < 152)
        _anim.length = max(10, _anim.length + (_mx > _rx0+78 ? 2 : -2));
    // Copier KF courant (y=156-180)
    if (_my >= 156 && _my < 180) {
        ed_copy_kf = ed_sel_kf;
        ed_notif = "KF[" + string(ed_sel_kf) + "] copié"; ed_notif_time = 90;
    }
    // Boutons SWING/LAT (y=218-246)
    if (_my >= 218 && _my < 246) {
        if (_mx < _rx0+8+_hw2) ed_sel_axis = 0;
        else                    ed_sel_axis = 1;
    }
    // Toggle ballon (y=250-274)
    if (_my >= 250 && _my < 274 && _mx < _rx0+ed_panel_right_w-8)
        ed_show_ball = !ed_show_ball;
}

// Panneau gauche
if (_click && _mx < ed_panel_left_w) {
    var _anim_names = variable_struct_get_names(global.anim_lib);
    var _row0_y2 = 36;
    for (var _i = 0; _i < array_length(_anim_names); _i++) {
        var _ry = _row0_y2 + (_i-ed_anim_scroll)*ed_lh;
        if (_my >= _ry && _my < _ry+ed_lh && _ry > 30 && _ry < ed_timeline_y-112) {
            ed_sel_anim = _anim_names[_i];
            ed_sel_kf = 0; ed_sel_part = -1; tl_time = 0; tl_playing = false;
        }
    }
    var _btn_y = ed_timeline_y - 112;
    // + anim
    if (_my >= _btn_y && _my < _btn_y+28 && _mx < 136) {
        var _nn2 = "anim_" + string(array_length(variable_struct_get_names(global.anim_lib)));
        // Posture de repos (idle) par défaut
        var _def_ang  = [ 0,  0, 155, 165, 205, 195, 180, 180, 180, 180];
        var _def_lat  = [0,0,0,0,0,0,0,0,0,0];
        global.anim_lib[$ _nn2] = {loop:true, length:60,
            kf:[{t:0.00, angles:array_create(10,0), angles_lat:_def_lat, root_z:0, ball:{bx:5,by:10,bz:30}},
                {t:0.50, angles:array_create(10,0), angles_lat:_def_lat, root_z:0, ball:{bx:5,by:10,bz:30}}]};
        array_copy(_nn2 == _nn2 ? global.anim_lib[$ _nn2].kf[0].angles : [], 0, _def_ang, 0, 10);
        var _def_ang2 = [ 0,  0, 155, 165, 205, 195, 180, 180, 180, 180];
        array_copy(global.anim_lib[$ _nn2].kf[1].angles, 0, _def_ang2, 0, 10);
        ed_sel_anim = _nn2; ed_sel_kf = 0; tl_time = 0;
        ed_notif = "Créé: "+_nn2; ed_notif_time = 90;
    }
    // - anim
    if (_my >= _btn_y && _my < _btn_y+28 && _mx >= 140 && _mx < 275) {
        var _names2 = variable_struct_get_names(global.anim_lib);
        if (array_length(_names2) > 1) {
            variable_struct_remove(global.anim_lib, ed_sel_anim);
            ed_sel_anim = variable_struct_get_names(global.anim_lib)[0];
            ed_notif = "Anim supprimée"; ed_notif_time = 90;
        }
    }
    // Export
    var _exp_y = _btn_y + 34;
    if (_my >= _exp_y && _my < _exp_y+28 && _mx < 136) {
        var _path_exp = get_save_filename("JSON|*.json", "char_animations");
        if (_path_exp != "") {
            var _f = file_text_open_write(_path_exp);
            file_text_write_string(_f, json_stringify(global.anim_lib));
            file_text_close(_f);
            ed_notif = "Exporté !"; ed_notif_time = 120;
        }
    }
    // Import
    if (_my >= _exp_y && _my < _exp_y+28 && _mx >= 140 && _mx < 275) {
        var _path_imp = get_open_filename("JSON|*.json", "char_animations");
        if (_path_imp != "" && file_exists(_path_imp)) {
            var _f2 = file_text_open_read(_path_imp);
            var _s2 = "";
            while (!file_text_eof(_f2)) _s2 += file_text_readln(_f2);
            file_text_close(_f2);
            var _d2 = json_parse(_s2);
            var _nms = variable_struct_get_names(_d2);
            for (var _ii = 0; _ii < array_length(_nms); _ii++)
                global.anim_lib[$ _nms[_ii]] = _d2[$ _nms[_ii]];
            var _all = variable_struct_get_names(global.anim_lib);
            if (array_length(_all) > 0) ed_sel_anim = _all[0];
            ed_notif = "Importé !"; ed_notif_time = 120;
        }
    }
}

if (_mx < ed_panel_left_w) ed_anim_scroll = max(0, ed_anim_scroll - mouse_wheel_up() + mouse_wheel_down());

if (keyboard_check(vk_control) && keyboard_check_pressed(ord("S"))) {
    global.anim_save();
    ed_notif = "Sauvegardé !"; ed_notif_time = 120;
}

if (ed_notif_time > 0) ed_notif_time--;
else ed_notif = "";
