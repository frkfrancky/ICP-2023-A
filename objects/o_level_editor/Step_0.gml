var _mx    = device_mouse_x_to_gui(0);
var _my    = device_mouse_y_to_gui(0);
var _click = mouse_check_button_pressed(mb_left);

// ESC → retour au menu outils
if (keyboard_check_pressed(vk_escape)) { room_goto(r_outils); exit; }

var _in_view = (_mx >= le_viewport_x && _mx < le_viewport_x+le_viewport_w);

// ── Rotation caméra (drag bouton droit ou molette) ──────────────────
if (_in_view && mouse_check_button_pressed(mb_right)) {
    le_drag_cam = true;
    le_drag_mx  = _mx;
    le_drag_my  = _my;
    le_drag_yaw = le_cam_yaw;
    le_drag_ang = le_cam_angle;
}
if (le_drag_cam) {
    if (mouse_check_button(mb_right)) {
        le_cam_yaw   = le_drag_yaw + (_mx - le_drag_mx) * 0.5;
        le_cam_angle = clamp(le_drag_ang - (_my - le_drag_my) * 0.3, 5, 89);
    } else le_drag_cam = false;
}

// Molette : zoom
if (_in_view) {
    var _zs = mouse_wheel_up() - mouse_wheel_down();
    if (_zs != 0) le_cam_dist = clamp(le_cam_dist - _zs * 60, 100, 5000);
}

// ── Panneau gauche : presets lumière ────────────────────────────────
if (_click && _mx < le_panel_left_w) {
    var _np = array_length(le_day_presets);
    for (var _i = 0; _i < _np; _i++) {
        var _py = 100 + _i * 44;
        if (_my >= _py && _my < _py+36) {
            le_preset_sel = _i;
            var _p = le_day_presets[_i];
            le_lit_dir   = _p.dir;
            le_lit_color = _p.col;
            le_lit_amb   = _p.amb;
            le_lit_rim   = _p.rim;
        }
    }
    // Import OBJ
    if (_my >= 440 && _my < 476) {
        var _path = get_open_filename("OBJ Files|*.obj", "Importer un objet 3D");
        if (_path != "" && file_exists(_path)) {
            var _vb2 = le_parse_obj(_path);
            if (!is_undefined(_vb2)) {
                var _fname = filename_name(_path);
                array_push(le_objects, {vb:_vb2, x:0,y:0,z:0, rx:0,ry:0,rz:0, sx:1,sy:1,sz:1, name:_fname, col:#88AABB});
                le_sel_obj = array_length(le_objects)-1;
                le_notif = "Importé: "+_fname; le_notif_time = 120;
            } else {
                le_notif = "Erreur lecture OBJ"; le_notif_time = 90;
            }
        }
    }
    // Ajouter cube
    if (_my >= 484 && _my < 520) {
        var _box_vb2 = vertex_create_buffer();
        vertex_begin(_box_vb2, global.vFormat);
        var _cv2=[[-50,-50,0],[50,-50,0],[50,50,0],[-50,50,0],[-50,-50,100],[50,-50,100],[50,50,100],[-50,50,100]];
        var _cf2=[[0,1,2,0,2,3],[4,6,5,4,7,6],[0,4,5,0,5,1],[2,6,7,2,7,3],[0,3,7,0,7,4],[1,5,6,1,6,2]];
        var _cn2=[[0,0,-1],[0,0,1],[0,-1,0],[0,1,0],[-1,0,0],[1,0,0]];
        for(var _fi2=0;_fi2<6;_fi2++){var _nx2=_cn2[_fi2][0];var _ny2=_cn2[_fi2][1];var _nz2=_cn2[_fi2][2];var _nu2=_nx2*0.5+0.5;var _nv2=_ny2*0.5+0.5;var _col3=make_color_rgb(round((_nz2*0.5+0.5)*255),128,128);for(var _vi2=0;_vi2<6;_vi2++){var _idx3=_cf2[_fi2][_vi2];vertex_position_3d(_box_vb2,_cv2[_idx3][0],_cv2[_idx3][1],_cv2[_idx3][2]);vertex_texcoord(_box_vb2,_nu2,_nv2);vertex_color(_box_vb2,_col3,1.0);}}
        vertex_end(_box_vb2); vertex_freeze(_box_vb2);
        array_push(le_objects, {vb:_box_vb2,x:irandom_range(-200,200),y:irandom_range(-200,200),z:0,rx:0,ry:0,rz:0,sx:1,sy:1,sz:1,name:"Cube",col:#AABB88});
        le_sel_obj = array_length(le_objects)-1;
    }
    // Supprimer objet sélectionné
    if (_my >= 524 && _my < 560 && le_sel_obj >= 0 && le_sel_obj < array_length(le_objects)) {
        vertex_delete_buffer(le_objects[le_sel_obj].vb);
        array_delete(le_objects, le_sel_obj, 1);
        le_sel_obj = clamp(le_sel_obj-1, -1, array_length(le_objects)-1);
    }
    // Sélection objet dans la liste du panneau gauche (y=580+)
    var _nob = array_length(le_objects);
    for (var _i = 0; _i < _nob; _i++) {
        var _oy = 590 + _i*26;
        if (_my >= _oy && _my < _oy+24) le_sel_obj = _i;
    }
}

// ── Panneau droit : édition propriétés de l'objet sélectionné ───────
if (_click && _mx >= le_viewport_x+le_viewport_w && le_sel_obj >= 0 && le_sel_obj < array_length(le_objects)) {
    var _rx0 = le_viewport_x+le_viewport_w;
    var _o   = le_objects[le_sel_obj];
    // Flèches X/Y/Z position (+/- par clic)
    if (_my >= 80  && _my < 100)  _o.x += (_mx < _rx0+140) ? -10 : 10;
    if (_my >= 106 && _my < 126)  _o.y += (_mx < _rx0+140) ? -10 : 10;
    if (_my >= 132 && _my < 152)  _o.z += (_mx < _rx0+140) ? -10 : 10;
    // Scale
    if (_my >= 180 && _my < 200) { _o.sx = max(0.1, _o.sx + ((_mx < _rx0+140) ? -0.1 : 0.1)); _o.sy=_o.sx; _o.sz=_o.sx; }
    // Rotation Z
    if (_my >= 220 && _my < 240)  _o.rz += (_mx < _rx0+140) ? -15 : 15;
}

// Molette sur panneau droit : position Z fine
if (_mx >= le_viewport_x+le_viewport_w && le_sel_obj >= 0 && le_sel_obj < array_length(le_objects)) {
    var _ws = mouse_wheel_up() - mouse_wheel_down();
    if (_ws != 0) le_objects[le_sel_obj].z += _ws * 10;
}

// Sauvegarde JSON (Ctrl+S)
if (keyboard_check(vk_control) && keyboard_check_pressed(ord("S"))) {
    var _sdata = {};
    for (var _i = 0; _i < array_length(le_objects); _i++) {
        var _oo = le_objects[_i];
        _sdata[$ "obj_"+string(_i)] = {name:_oo.name,x:_oo.x,y:_oo.y,z:_oo.z,rx:_oo.rx,ry:_oo.ry,rz:_oo.rz,sx:_oo.sx,sy:_oo.sy,sz:_oo.sz,col:_oo.col};
    }
    var _sp = get_save_filename("JSON|*.json","niveau");
    if (_sp != "") {
        var _sf = file_text_open_write(_sp);
        file_text_write_string(_sf, json_stringify(_sdata));
        file_text_close(_sf);
        le_notif = "Sauvegardé !"; le_notif_time = 120;
    }
}

if (le_notif_time > 0) le_notif_time--;
else le_notif = "";
