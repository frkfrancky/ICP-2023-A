// === ÉDITEUR D'ANIMATIONS ===
depth = -99999;
ed_part_names = ["Torse","Tête","BrasD","AvantD","BrasG","AvantG","CuisseD","TibiaD","CuisseG","TibiaG"];

// Layout
ed_panel_left_w  = 280;
ed_panel_right_w = 300;
ed_timeline_h    = 110;
ed_preview_w     = 1280 - ed_panel_left_w - ed_panel_right_w;
ed_preview_h     = 720  - ed_timeline_h;
ed_timeline_y    = 720  - ed_timeline_h;
ed_lh = 24;

prev_cx    = ed_panel_left_w + ed_preview_w * 0.5;
prev_cy    = ed_timeline_y * 0.74;   // personnage plus bas
prev_dir   = 180;
prev_scale = 3.0;
prev_zoom_target = 3.0;             // pour zoom fluide

ed_sel_anim    = "";
ed_sel_kf      = 0;
ed_sel_part    = -1;
ed_hover_part  = -1;
ed_sel_axis    = 0;   // 0 = swing (ang), 1 = latéral (ang_lat)
tl_playing     = false;
tl_time        = 0.0;
tl_drag_kf     = -1;
ed_notif       = "";
ed_notif_time  = 0;
ed_anim_scroll = 0;

// ── Squelette ────────────────────────────────────────────────────
if (!variable_global_exists("char_root_bz")) global.char_root_bz = 50;

if (!variable_global_exists("char_parts")) {
    global.char_parts = [
        { parent:-1, pdx:  0, pdy:0, pdz:  0, ang:  0, ang_lat:0, len:40, hw:10, col:#4466BB },
        { parent: 0, pdx:  0, pdy:0, pdz:  3, ang:  0, ang_lat:0, len:18, hw: 9, col:#F5C88A },
        { parent: 0, pdx: 10, pdy:0, pdz: -2, ang:155, ang_lat:0, len:22, hw: 4, col:#CC3322 },
        { parent: 2, pdx:  0, pdy:0, pdz:  0, ang:165, ang_lat:0, len:20, hw: 3, col:#EE6644 },
        { parent: 0, pdx:-10, pdy:0, pdz: -2, ang:205, ang_lat:0, len:22, hw: 4, col:#226633 },
        { parent: 4, pdx:  0, pdy:0, pdz:  0, ang:195, ang_lat:0, len:20, hw: 3, col:#44AA66 },
        { parent: 0, pdx:  5, pdy:0, pdz:-40, ang:180, ang_lat:0, len:26, hw: 6, col:#774411 },
        { parent: 6, pdx:  0, pdy:0, pdz:  0, ang:180, ang_lat:0, len:24, hw: 5, col:#BB8855 },
        { parent: 0, pdx: -5, pdy:0, pdz:-40, ang:180, ang_lat:0, len:26, hw: 6, col:#114466 },
        { parent: 8, pdx:  0, pdy:0, pdz:  0, ang:180, ang_lat:0, len:24, hw: 5, col:#5599BB },
    ];
}

// Toujours réinitialiser pour avoir les bons ordres front/dos
{
    // face : tête au premier plan (devant bras)
    var _F_front = [8,9,6,7, 0, 4,5,2,3, 1];
    // dos  : tête derrière tout (on voit la nuque)
    var _F_back  = [1, 2,3,4,5, 0, 6,7,8,9];
    // côté D : tête devant corps, derrière les bras D
    var _D_front = [4,5,8,9, 0, 1, 2,3,6,7];
    // côté G : tête devant corps, derrière les bras G
    var _G_front = [2,3,6,7, 0, 1, 4,5,8,9];
    // frame : 0=face  1,2,3=côtéD  4=dos  5,6,7=côtéG
    global.char_layer_order = [_F_front,_D_front,_D_front,_D_front,_F_back,_G_front,_G_front,_G_front];
}

// ── Bibliothèque d'animations ─────────────────────────────────────
if (!variable_global_exists("anim_lib")) {
    global.anim_lib = {};
    global.anim_lib[$ "idle"] = {
        loop:true, length:120,
        kf:[
            { t:0.00, angles:[ 0,  0, 155, 165, 205, 195, 180, 180, 180, 180], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:0, ball:{bx:5,by:10,bz:30} },
            { t:0.50, angles:[ 2,  2, 153, 163, 207, 197, 182, 182, 182, 182], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:0, ball:{bx:5,by:10,bz:29} },
        ]
    };
    global.anim_lib[$ "run"] = {
        loop:true, length:36,
        kf:[
            { t:0.00, angles:[ 5,  3, 175, 178, 188, 183, 150, 163, 210, 196], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:2, ball:{bx:5,by:10,bz: 5} },
            { t:0.25, angles:[ 2,  1, 155, 165, 205, 195, 180, 180, 180, 180], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:5, ball:{bx:5,by:10,bz:28} },
            { t:0.50, angles:[ 5,  3, 188, 183, 175, 178, 210, 196, 150, 163], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:2, ball:{bx:5,by:10,bz: 5} },
            { t:0.75, angles:[ 2,  1, 155, 165, 205, 195, 180, 180, 180, 180], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:5, ball:{bx:5,by:10,bz:28} },
        ]
    };
}

// ── Fonctions globales FK ────────────────────────────────────────
// Toujours réinitialiser pour avoir la version 3D complète + root_z + ball
if (true) {
    global.char_fk = function(anim_name, t) {
        var _parts  = global.char_parts;
        var _n      = array_length(_parts);
        var _result = array_create(_n + 1, undefined); // slot 10 = ballon
        var _angles     = array_create(_n, 0);
        var _angles_lat = array_create(_n, 0);
        var _root_z  = 0;
        var _ball_bx = 5; var _ball_by = 10; var _ball_bz = 30;
        t = ((t mod 1.0) + 1.0) mod 1.0;

        if (variable_struct_exists(global.anim_lib, anim_name)) {
            var _anim = global.anim_lib[$ anim_name];
            var _kf   = _anim.kf;
            var _nkf  = array_length(_kf);
            var _i0   = 0;
            for (var _i = 0; _i < _nkf; _i++) { if (_kf[_i].t <= t) _i0 = _i; }
            var _i1 = (_i0+1) mod _nkf;
            var _k0 = _kf[_i0]; var _k1 = _kf[_i1];
            var _t0 = _k0.t; var _t1 = (_i1==0) ? 1.0 : _k1.t;
            var _f  = (_t1-_t0>0.0001) ? clamp((t-_t0)/(_t1-_t0),0,1) : 0;
            var _lat0 = variable_struct_exists(_k0,"angles_lat") ? _k0.angles_lat : array_create(_n,0);
            var _lat1 = variable_struct_exists(_k1,"angles_lat") ? _k1.angles_lat : array_create(_n,0);
            for (var _i = 0; _i < _n; _i++) {
                // Chemin le plus court (évite rotation 360° pour 352→-12)
                var _da  = ((_k1.angles[_i]  - _k0.angles[_i]  + 540) mod 360) - 180;
                var _dal = ((_lat1[_i]        - _lat0[_i]        + 540) mod 360) - 180;
                _angles[_i]     = _k0.angles[_i]  + _da  * _f;
                _angles_lat[_i] = _lat0[_i]        + _dal * _f;
            }
            // root_z : décalage vertical global du squelette (saut anim, bond de course)
            _root_z = lerp(
                variable_struct_exists(_k0,"root_z") ? _k0.root_z : 0,
                variable_struct_exists(_k1,"root_z") ? _k1.root_z : 0, _f);
            // ball : ancre ballon relative au perso (bz = hauteur depuis sol)
            var _b0 = variable_struct_exists(_k0,"ball") ? _k0.ball : {bx:5,by:10,bz:30};
            var _b1 = variable_struct_exists(_k1,"ball") ? _k1.ball : {bx:5,by:10,bz:30};
            _ball_bx = lerp(_b0.bx, _b1.bx, _f);
            _ball_by = lerp(_b0.by, _b1.by, _f);
            _ball_bz = lerp(_b0.bz, _b1.bz, _f);
        } else {
            for (var _i = 0; _i < _n; _i++) {
                _angles[_i]     = _parts[_i].ang;
                _angles_lat[_i] = variable_struct_exists(_parts[_i], "ang_lat") ? _parts[_i].ang_lat : 0;
            }
        }

        for (var _i = 0; _i < _n; _i++) {
            var _p = _parts[_i];
            var _piv_bx = 0; var _piv_by = 0; var _piv_bz = 0;
            if (_p.parent == -1) {
                _piv_bz = global.char_root_bz + _root_z;
            } else {
                var _par = _result[_p.parent];
                _piv_bx = _par.end_bx + _p.pdx;
                _piv_by = (variable_struct_exists(_par,"end_by") ? _par.end_by : 0)
                        + (variable_struct_exists(_p,  "pdy")    ? _p.pdy      : 0);
                _piv_bz = _par.end_bz + _p.pdz;
            }
            var _ar  = degtorad(_angles[_i]);
            var _arl = degtorad(_angles_lat[_i]);
            var _cl  = cos(_arl);
            _result[_i] = {
                piv_bx : _piv_bx, piv_by : _piv_by, piv_bz : _piv_bz,
                end_bx : _piv_bx + _p.len * sin(_ar) * _cl,
                end_by : _piv_by + _p.len * sin(_arl),
                end_bz : _piv_bz + _p.len * cos(_ar) * _cl,
                angle : _angles[_i], angle_lat : _angles_lat[_i]
            };
        }
        // Slot 10 : ancre du ballon (bz inclut root_z pour suivre le bond)
        _result[10] = { bx : _ball_bx, by : _ball_by, bz : _ball_bz + _root_z };
        return _result;
    };
}

if (!variable_global_exists("anim_save")) {
    global.anim_save = function() {
        var _f = file_text_open_write(working_directory+"char_animations.json");
        file_text_write_string(_f, json_stringify(global.anim_lib));
        file_text_close(_f);
    };
    global.anim_load = function() {
        var _path = working_directory+"char_animations.json";
        if (!file_exists(_path)) return;
        var _f = file_text_open_read(_path);
        var _s = "";
        while (!file_text_eof(_f)) _s += file_text_readln(_f);
        file_text_close(_f);
        var _d = json_parse(_s);
        var _names = variable_struct_get_names(_d);
        for (var _i = 0; _i < array_length(_names); _i++)
            global.anim_lib[$ _names[_i]] = _d[$ _names[_i]];
    };
    global.anim_load();
}

ed_show_ball  = true;
ed_copy_kf    = -1;
ed_ball_rad   = 12.0;

// Surface 3D pour le rendu identique au match
ed_3d_surf    = -1;
ed_cam_dist_base = 1200.0;  // distance caméra à scale=3.0

// Vertex format (au cas où o_cam absent de ce room)
if (!variable_global_exists("vFormat")) {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    vertex_format_add_color();
    global.vFormat = vertex_format_end();
}

// Shader uniforms — récupérés localement (pas besoin de o_cam)
ed_u_ldir        = shader_get_uniform(Shader1, "u_lightDir");
ed_u_lcol        = shader_get_uniform(Shader1, "u_lightColor");
ed_u_lamb        = shader_get_uniform(Shader1, "u_ambient");
ed_u_lrim        = shader_get_uniform(Shader1, "u_rimStrength");
ed_u_pl0         = shader_get_uniform(Shader1, "u_pl0");
ed_u_pl1         = shader_get_uniform(Shader1, "u_pl1");
ed_u_plcol       = shader_get_uniform(Shader1, "u_plcol");
ed_u_plrad       = shader_get_uniform(Shader1, "u_plrad");
ed_u_sprpos      = shader_get_uniform(Shader1, "u_sprpos");
ed_u_flat_normal = shader_get_uniform(Shader1, "u_flat_normal");

// Éclairage éditeur (par défaut après-midi)
ed_lit_dir   = [0.38, 0.72, 0.58];
ed_lit_color = [0.90, 0.82, 0.72];
ed_lit_amb   = 0.38;
ed_lit_rim   = 0.50;

// Positions projetées des bones pour hover (mises à jour chaque frame par Draw_0)
ed_bone_sx  = array_create(11, 0);
ed_bone_sy  = array_create(11, 0);

// Sélectionner la première anim disponible
var _init_names = variable_struct_get_names(global.anim_lib);
if (array_length(_init_names) > 0) ed_sel_anim = _init_names[0];
