var _mx    = device_mouse_x_to_gui(0);
var _my    = device_mouse_y_to_gui(0);
var _click = mouse_check_button_pressed(mb_left);
var _held  = mouse_check_button(mb_left);
le_anim_t = (le_anim_t + 1.0/120.0) mod 1.0; // cycle idle ~2s
// Toggle ombres (raccourci clavier)
if (keyboard_check_pressed(ord("O"))) le_shadow_enable = !le_shadow_enable;
// Sauvegarder état modal avant tout traitement (évite open+close dans la même frame)
var _modal_was_open = le_modal_open;

if (keyboard_check_pressed(vk_escape)) {
    if (le_modal_open) le_modal_open = false;
    else room_goto(r_outils);
    exit;
}

var _in_view = (_mx >= le_viewport_x && _mx < le_viewport_x+le_viewport_w && _my >= 0 && _my < le_viewport_h);

// ── Panneau parametres ombres (flottant sur la vue 3D) ──────────
// Coordonnees synchronisees avec Draw_0
var _spx  = le_viewport_x + 8; var _spy  = 8;
var _spw  = 250; var _sph  = 194;
var _slx0 = _spx + 8; var _slx1 = _spx + _spw - 8;
var _slw  = _slx1 - _slx0;
// Offsets Y des zones interactives (curseur _sy dans Draw_0) :
// titre 18 + sep 5 = 23 → _spy+29
// ON/OFF : _spy+29 .. _spy+47
// sep 5 → _spy+52, azimut label : _spy+57, slider : _spy+71 .. +10
// sep 5 → _spy+92, dark label : _spy+97, slider : _spy+111 .. +10
// sep 5 → _spy+132, bias label : _spy+137, slider : _spy+151 .. +10
var _p_onoff_y = _spy + 29;
var _p_az_y    = _spy + 71;
var _p_dark_y  = _spy + 111;
var _p_bias_y  = _spy + 151;

// Clic sur la barre ombres → toggle panneau
if (_click && _mx >= 8 && _mx <= le_panel_left_w-8 && _my >= 74 && _my < 88)
    le_shadow_panel = !le_shadow_panel;

// Fermer panneau si clic hors zone panneau
if (_click && le_shadow_panel && !le_modal_open) {
    var _in_panel = (_mx >= _spx && _mx <= _spx+_spw && _my >= _spy && _my <= _spy+_sph);
    var _on_bar   = (_mx >= 8 && _mx <= le_panel_left_w-8 && _my >= 74 && _my < 88);
    if (!_in_panel && !_on_bar) le_shadow_panel = false;
}

if (le_shadow_panel && !le_modal_open) {
    // Bouton ON/OFF
    if (_click && _mx >= _slx0 && _mx <= _slx1 && _my >= _p_onoff_y && _my < _p_onoff_y+18)
        le_shadow_enable = !le_shadow_enable;
    // Debut drag sliders
    if (_click && _mx >= _slx0 && _mx <= _slx1) {
        if (_my >= _p_az_y   && _my < _p_az_y+12)  le_shadow_sl_drag = "azimut";
        if (_my >= _p_dark_y && _my < _p_dark_y+12) le_shadow_sl_drag = "dark";
        if (_my >= _p_bias_y && _my < _p_bias_y+12) le_shadow_sl_drag = "bias";
    }
}
// Drag slider azimut
if (le_shadow_sl_drag == "azimut") {
    if (_held) {
        var _t0 = clamp((_mx - _slx0) / _slw, 0.0, 1.0);
        le_sun_azimuth = lerp(-pi, pi, _t0);
        le_update_lighting();
    } else le_shadow_sl_drag = "";
}
// Drag slider noirceur
if (le_shadow_sl_drag == "dark") {
    if (_held) {
        var _t = clamp((_mx - _slx0) / _slw, 0.0, 1.0);
        le_shadow_darkness = 1.0 - _t;
    } else le_shadow_sl_drag = "";
}
// Drag slider biais
if (le_shadow_sl_drag == "bias") {
    if (_held) {
        var _t2 = clamp((_mx - _slx0) / _slw, 0.0, 1.0);
        le_shadow_bias = lerp(0.001, 0.010, _t2);
    } else le_shadow_sl_drag = "";
}

// ── Caméra : orbite bouton droit ────────────────────────────────
// Drag start
if (_in_view && mouse_check_button_pressed(mb_right)) {
    le_drag_cam = true;
    le_drag_mx  = _mx; le_drag_my = _my;
    le_drag_yaw = le_cam_yaw; le_drag_ang = le_cam_angle;
}
if (le_drag_cam) {
    if (mouse_check_button(mb_right)) {
        // Surface double-flip → les deux axes doivent être inversés
        le_cam_yaw   = le_drag_yaw   - (_mx - le_drag_mx) * 0.4;
        le_cam_angle = clamp(le_drag_ang + (_my - le_drag_my) * 0.3, 3, 88);
    } else le_drag_cam = false;
}

// Pan : bouton milieu
if (_in_view && mouse_check_button_pressed(mb_middle)) {
    le_pan_cam = true;
    le_pan_mx  = _mx; le_pan_my = _my;
    le_pan_cx  = le_cam_cx; le_pan_cy = le_cam_cy;
}
if (le_pan_cam) {
    if (mouse_check_button(mb_middle)) {
        var _yaw_r   = degtorad(le_cam_yaw);
        var _pan_spd = le_cam_dist * 0.0015;
        var _dmx = _mx - le_pan_mx;
        var _dmy = _my - le_pan_my;
        // Camera right=(-sin,cos), backward=(cos,sin); les deux axes inversés (double-flip)
        le_cam_cx = le_pan_cx + sin(_yaw_r)*_dmx*_pan_spd - cos(_yaw_r)*_dmy*_pan_spd;
        le_cam_cy = le_pan_cy - cos(_yaw_r)*_dmx*_pan_spd - sin(_yaw_r)*_dmy*_pan_spd;
    } else le_pan_cam = false;
}

// Zoom molette
if (_in_view && !le_drag_cam) {
    var _zs = mouse_wheel_up() - mouse_wheel_down();
    if (_zs != 0) le_cam_dist = clamp(le_cam_dist - _zs * le_cam_dist * 0.1, 50, 8000);
}

// ── Slider jour/nuit ────────────────────────────────────────────
// Zone slider : panneau gauche, y=56..72
var _sl_x0 = 8; var _sl_x1 = le_panel_left_w - 8;
var _sl_y0 = 58; var _sl_y1 = 70;
if (mouse_check_button_pressed(mb_left) && _mx >= _sl_x0 && _mx <= _sl_x1 && _my >= _sl_y0 && _my <= _sl_y1)
    le_day_dragging = true;
if (!mouse_check_button(mb_left)) le_day_dragging = false;
if (le_day_dragging) {
    le_day_hour = clamp((_mx - _sl_x0) / (_sl_x1 - _sl_x0) * 24.0, 0, 24);
    le_update_lighting();
}

// ── Hover boutons panneau gauche (plus jamais decales, panneau ombre est sur la vue) ──
var _le_btn_top  = 90;
var _le_list_top = _le_btn_top + 64;
le_hover_btn_add = (_mx >= 8 && _mx < le_panel_left_w-8 && _my >= _le_btn_top    && _my < _le_btn_top+26);
le_hover_btn_del = (_mx >= 8 && _mx < le_panel_left_w-8 && _my >= _le_btn_top+32 && _my < _le_btn_top+58);

// ── Hover objets 3D (positions projetées remplies dans Draw_0) ──
// La surface est dessinée avec draw_surface_ext(surf, vp_x+vp_w, vp_h, -1, -1, ...)
// Donc pixel surface (sx,sy) → écran (vp_x+vp_w - sx, vp_h - sy)
// Inverse : souris écran (mx,my) → coords surface (vp_x+vp_w - mx, vp_h - my)
le_hover_obj = -1;
if (_in_view && !le_drag_cam) {
    var _best_d = 48;
    for (var _i = array_length(le_objects)-1; _i >= 0; _i--) {
        var _sx = le_obj_sx[_i]; var _sy = le_obj_sy[_i];
        if (_sx < 0) continue;
        if (point_distance(_mx, _my, _sx, _sy) < _best_d) {
            _best_d = point_distance(_mx, _my, _sx, _sy);
            le_hover_obj = _i;
        }
    }
    if (_click && le_hover_obj >= 0) le_sel_obj = le_hover_obj;
}

// ── Hold buttons propriétés ─────────────────────────────────────
var _rx0 = le_viewport_x + le_viewport_w;
var _in_right = (_mx >= _rx0 && !le_modal_open);
if (!_held) { le_hold_btn = ""; le_hold_t = 0; le_hold_step = 0; }

if (_in_right && le_sel_obj >= 0 && le_sel_obj < array_length(le_objects)) {
    var _o = le_objects[le_sel_obj];
    // Détecter zone bouton pressée
    if (_click) {
        // Detection : minus = _mx in [_rx0+90.._rx0+112], plus = _mx in [_rx0+168.._rx0+190]
        // Rows (cy = haut de rangee, hauteur 20px) : px=64, py=88, pz=112, s=152, rz=192, ry=216, rx=240
        if      (_my>=64  && _my<84  && _mx>=_rx0+90 && _mx<_rx0+112)  le_hold_btn="px-";
        else if (_my>=64  && _my<84  && _mx>=_rx0+168) le_hold_btn="px+";
        else if (_my>=88  && _my<108 && _mx>=_rx0+90 && _mx<_rx0+112)  le_hold_btn="py-";
        else if (_my>=88  && _my<108 && _mx>=_rx0+168) le_hold_btn="py+";
        else if (_my>=112 && _my<132 && _mx>=_rx0+90 && _mx<_rx0+112)  le_hold_btn="pz-";
        else if (_my>=112 && _my<132 && _mx>=_rx0+168) le_hold_btn="pz+";
        else if (_my>=152 && _my<172 && _mx>=_rx0+90 && _mx<_rx0+112)  le_hold_btn="s-";
        else if (_my>=152 && _my<172 && _mx>=_rx0+168) le_hold_btn="s+";
        else if (_my>=192 && _my<212 && _mx>=_rx0+90 && _mx<_rx0+112)  le_hold_btn="rz-";
        else if (_my>=192 && _my<212 && _mx>=_rx0+168) le_hold_btn="rz+";
        else if (_my>=216 && _my<236 && _mx>=_rx0+90 && _mx<_rx0+112)  le_hold_btn="ry-";
        else if (_my>=216 && _my<236 && _mx>=_rx0+168) le_hold_btn="ry+";
        else if (_my>=240 && _my<260 && _mx>=_rx0+90 && _mx<_rx0+112)  le_hold_btn="rx-";
        else if (_my>=240 && _my<260 && _mx>=_rx0+168) le_hold_btn="rx+";
        // Boutons lumiere : Intensite cy=302, Portee cy=326
        else if (_my>=302 && _my<322 && _mx>=_rx0+90 && _mx<_rx0+112 && _o.type=="light") le_hold_btn="li-";
        else if (_my>=302 && _my<322 && _mx>=_rx0+168 && _o.type=="light")                  le_hold_btn="li+";
        else if (_my>=326 && _my<346 && _mx>=_rx0+90 && _mx<_rx0+112 && _o.type=="light") le_hold_btn="lr-";
        else if (_my>=326 && _my<346 && _mx>=_rx0+168 && _o.type=="light")                  le_hold_btn="lr+";
        // Couleur lumiere : swatch y=366..386 → saisie R/G/B
        else if (_my>=366 && _my<386 && _mx>=_rx0+10 && _mx<=_rx0+230 && _o.type=="light") {
            var _cr = get_integer("Rouge (0-255):", color_get_red(_o.col));
            var _cg = get_integer("Vert  (0-255):", color_get_green(_o.col));
            var _cb = get_integer("Bleu  (0-255):", color_get_blue(_o.col));
            _o.col = make_color_rgb(clamp(_cr,0,255), clamp(_cg,0,255), clamp(_cb,0,255));
        }
    }
    // Appliquer hold
    if (le_hold_btn != "" && _held) {
        le_hold_t++;
        var _spd = (le_hold_t > 60) ? 5 : ((le_hold_t > 20) ? 2 : 1);
        if (_click || le_hold_t > 20) {
            // step tous les N frames selon vitesse
            var _do = _click || (le_hold_t mod max(1, 8 - floor(le_hold_t/20)) == 0);
            if (_do) {
                var _pos_step = keyboard_check(vk_shift) ? 50 : 10;
                var _rot_step = keyboard_check(vk_shift) ? 45 : 5;
                var _scl_step = keyboard_check(vk_shift) ? 0.5 : 0.1;
                switch (le_hold_btn) {
                    case "px-": _o.x -= _pos_step; break; case "px+": _o.x += _pos_step; break;
                    case "py-": _o.y -= _pos_step; break; case "py+": _o.y += _pos_step; break;
                    case "pz-": _o.z -= _pos_step; break; case "pz+": _o.z += _pos_step; break;
                    case "s-":  _o.sx = max(0.05, _o.sx-_scl_step); _o.sy=_o.sx; _o.sz=_o.sx; break;
                    case "s+":  _o.sx += _scl_step; _o.sy=_o.sx; _o.sz=_o.sx; break;
                    case "rz-": _o.rz = (_o.rz - _rot_step + 360) mod 360; break;
                    case "rz+": _o.rz = (_o.rz + _rot_step) mod 360; break;
                    case "ry-": _o.ry = (_o.ry - _rot_step + 360) mod 360; break;
                    case "ry+": _o.ry = (_o.ry + _rot_step) mod 360; break;
                    case "rx-": _o.rx = (_o.rx - _rot_step + 360) mod 360; break;
                    case "rx+": _o.rx = (_o.rx + _rot_step) mod 360; break;
                    case "li-":
                        if (!variable_struct_exists(_o,"intensity")) _o.intensity=1.0;
                        _o.intensity = max(0, _o.intensity - _scl_step*0.5); break;
                    case "li+":
                        if (!variable_struct_exists(_o,"intensity")) _o.intensity=1.0;
                        _o.intensity = min(8, _o.intensity + _scl_step*0.5); break;
                    case "lr-":
                        if (!variable_struct_exists(_o,"range")) _o.range=500;
                        _o.range = max(50, _o.range - _pos_step*5); break;
                    case "lr+":
                        if (!variable_struct_exists(_o,"range")) _o.range=500;
                        _o.range = min(8000, _o.range + _pos_step*5); break;
                }
            }
        }
    }

}

// ── Panneau gauche ──────────────────────────────────────────────
if (_click && _mx < le_panel_left_w && !le_modal_open) {
    // Bouton "+ Ajouter"
    if (_my >= _le_btn_top && _my < _le_btn_top+26) le_modal_open = true;
    // Supprimer
    if (_my >= _le_btn_top+32 && _my < _le_btn_top+58 && le_sel_obj >= 0 && le_sel_obj < array_length(le_objects)) {
        var _oo = le_objects[le_sel_obj];
        if ((_oo.type == "mesh" || _oo.type == "terrain") && _oo.vb >= 0) vertex_delete_buffer(_oo.vb);
        array_delete(le_objects, le_sel_obj, 1);
        le_sel_obj = clamp(le_sel_obj-1, -1, array_length(le_objects)-1);
    }
    // Liste objets
    var _nob = array_length(le_objects);
    for (var _i = 0; _i < _nob; _i++) {
        var _oy = _le_list_top + 8 + (_i - le_obj_scroll) * 28;
        if (_oy < _le_list_top || _oy > le_viewport_h - 8) continue;
        if (_my >= _oy && _my < _oy+26) le_sel_obj = _i;
    }
}
// Scroll liste objets
if (_mx < le_panel_left_w) {
    var _ws2 = mouse_wheel_up() - mouse_wheel_down();
    if (_ws2 != 0) le_obj_scroll = max(0, le_obj_scroll - _ws2);
}

// Modal ajout d'objet
if (_modal_was_open && _click) {
    // Reproduire exactement la meme geometrie que Draw_0
    var _nc_fixed = 5; // 0-4 categories fixes
    var _na = array_length(le_asset_list);
    var _nc = _nc_fixed + _na;
    var _row_h = 46;
    var _mod_w = 320;
    var _mod_h = 48 + _nc*_row_h + 24;
    var _sh2 = display_get_gui_height();
    var _mod_x = le_viewport_x + (le_viewport_w - _mod_w) * 0.5;
    var _mod_y = max(10, (_sh2 - _mod_h)*0.5);
    for (var _i = 0; _i < _nc; _i++) {
        var _by = _mod_y + 44 + _i*_row_h;
        if (_mx >= _mod_x+16 && _mx <= _mod_x+_mod_w-16 && _my >= _by && _my < _by+_row_h-2) {
            le_modal_open = false;
            if (_i == 0) { // Cube
                var _col_cube = make_color_rgb(170,187,136);
                array_push(le_objects, {type:"mesh", vb:le_make_cube_vb(50),
                    x:irandom_range(-200,200),y:irandom_range(-200,200),z:0,
                    rx:0,ry:0,rz:0, sx:1,sy:1,sz:1, name:"Cube", col:_col_cube});
                le_sel_obj = array_length(le_objects)-1;
            } else if (_i == 1) { // Lumiere
                var _col_light = make_color_rgb(255,221,136);
                array_push(le_objects, {type:"light", vb:-1,
                    x:0,y:0,z:200, rx:0,ry:0,rz:0, sx:1,sy:1,sz:1,
                    name:"Lumiere", col:_col_light, intensity:1.5, range:500});
                le_sel_obj = array_length(le_objects)-1;
            } else if (_i == 2) { // Personnage
                var _col_char = make_color_rgb(100,140,210);
                array_push(le_objects, {type:"char", vb:-1,
                    x:irandom_range(-200,200),y:irandom_range(-200,200),z:0,
                    rx:0,ry:0,rz:0, sx:1,sy:1,sz:1, name:"Personnage", col:_col_char});
                le_sel_obj = array_length(le_objects)-1;
            } else if (_i == 3) { // Terrain
                array_push(le_objects, {type:"terrain", vb:le_make_terrain_vb(),
                    x:0,y:0,z:0, rx:0,ry:0,rz:0, sx:1,sy:1,sz:1, name:"Terrain match", col:c_white});
                le_sel_obj = array_length(le_objects)-1;
            } else if (_i == 4) { // Import OBJ manuel
                var _path = get_open_filename("OBJ Files|*.obj", "Importer OBJ");
                if (_path != "" && file_exists(_path)) {
                    var _res = le_parse_obj(_path);
                    if (!is_undefined(_res)) {
                        var _notif_msg = (_res.tex_spr >= 0) ? "Importe avec texture !" : "Importe (sans texture)";
                        array_push(le_objects, {type:"mesh", vb:_res.vb, tex_spr:_res.tex_spr,
                            x:0,y:0,z:0, rx:0,ry:0,rz:0, sx:1,sy:1,sz:1,
                            name:filename_name(_path), col:make_color_rgb(200,200,200)});
                        le_sel_obj = array_length(le_objects)-1;
                        le_notif = _notif_msg; le_notif_time = 140;
                    } else { le_notif = "Erreur OBJ"; le_notif_time = 90; }
                }
            } else if (_i >= 5 && _i < 5+_na) { // Asset 3D du projet
                var _asset = le_asset_list[_i-5];
                var _res = le_parse_obj(_asset.path);
                if (!is_undefined(_res)) {
                    var _notif_msg = (_res.tex_spr >= 0) ? _asset.name+" : texture OK !" : _asset.name+" : pas de texture";
                    array_push(le_objects, {type:"mesh", vb:_res.vb, tex_spr:_res.tex_spr,
                        x:0,y:0,z:0, rx:0,ry:0,rz:0, sx:1,sy:1,sz:1,
                        name:_asset.name, col:make_color_rgb(200,200,200)});
                    le_sel_obj = array_length(le_objects)-1;
                    le_notif = _notif_msg; le_notif_time = 140;
                } else { le_notif = "Erreur: "+_asset.name; le_notif_time = 90; }
            }
        }
    }
    // Fermer si clic hors modal
    if (_mx < _mod_x || _mx > _mod_x+_mod_w || _my < _mod_y || _my > _mod_y+_mod_h)
        le_modal_open = false;
}

// ── Ctrl+S sauvegarde ───────────────────────────────────────────
if (keyboard_check(vk_control) && keyboard_check_pressed(ord("S"))) {
    var _sdata = {};
    for (var _i = 0; _i < array_length(le_objects); _i++) {
        var _oo = le_objects[_i];
        var _obj_data = {type:_oo.type,name:_oo.name,
            x:_oo.x,y:_oo.y,z:_oo.z,rx:_oo.rx,ry:_oo.ry,rz:_oo.rz,
            sx:_oo.sx,sy:_oo.sy,sz:_oo.sz,col:_oo.col};
        // Ajouter propriétés optionnelles pour les lumières
        if (_oo.type == "light") {
            if (variable_struct_exists(_oo,"intensity")) _obj_data.intensity = _oo.intensity;
            if (variable_struct_exists(_oo,"range")) _obj_data.range = _oo.range;
        }
        // Ajouter propriétés optionnelles pour les meshes
        if (_oo.type == "mesh") {
            if (variable_struct_exists(_oo,"tex_spr")) _obj_data.tex_spr = _oo.tex_spr;
        }
        _sdata[$ "obj_"+string(_i)] = _obj_data;
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
