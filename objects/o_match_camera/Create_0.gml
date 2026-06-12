// === MATCH CAMERA GAME ===
depth = -99999;

// Layout - EXACT copy from o_level
le_panel_left_w  = 260;
le_panel_right_w = 280;
le_viewport_x    = le_panel_left_w;
le_viewport_w    = 1280 - le_panel_left_w - le_panel_right_w;
le_viewport_h    = 720;

// Shader uniforms - créer d'abord pour level_loader
if (!variable_global_exists("vFormat")) {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    vertex_format_add_color();
    global.vFormat = vertex_format_end();
}

// Charger le niveau avec level_loader
le_objects   = [];
if (variable_global_exists("level_to_load") && global.level_to_load != "") {
    le_objects = level_loader(global.level_to_load);
    global.level_to_load = "";
}

// Surface 3D
le_surf = -1;

// Caméra orbitale (même position que l'éditeur pour la cohérence)
le_cam_angle  = 35.0;
le_cam_yaw    = 45.0;
le_cam_dist   = 800.0;
le_cam_cx     = 0.0;
le_cam_cy     = 0.0;
le_cam_cz     = 0.0;
le_cam_fov    = 45.0;

// Éclairage — slider jour/nuit + orientation soleil
le_day_hour = 14.0;
le_sun_azimuth = 0.0;

le_update_lighting = function() {
    var _h = le_day_hour;
    if (_h >= 5.5 && _h <= 20.5) {
        var _t    = (_h - 5.5) / 15.0;
        var _warm = abs(_t - 0.5) * 2;
        var _elev_rad = _t * pi;
        var _elev = sin(_elev_rad);
        var _horiz = cos(_elev_rad);
        var _az = le_sun_azimuth;
        var _dx = cos(_az) * _horiz;
        var _dy = sin(_az) * _horiz;
        var _dz = max(_elev, 0.02);
        var _ln = sqrt(_dx*_dx + _dy*_dy + _dz*_dz);
        le_lit_dir   = [_dx/_ln, _dy/_ln, _dz/_ln];
        le_lit_color = [1.5, 1.5*(1.0-_warm*0.35), 1.5*(1.0-_warm*0.6)];
        le_lit_amb   = lerp(0.50, 0.18, _warm);
        le_lit_rim   = lerp(0.20, 0.65, _warm);
    } else {
        var _az = le_sun_azimuth;
        var _dx = cos(_az) * 0.12; var _dy = sin(_az) * 0.12; var _dz = 0.99;
        var _ln = sqrt(_dx*_dx+_dy*_dy+_dz*_dz);
        le_lit_dir   = [_dx/_ln, _dy/_ln, _dz/_ln];
        le_lit_color = [0.12, 0.15, 0.30];
        le_lit_amb   = 0.07;
        le_lit_rim   = 0.10;
    }
};
le_lit_dir   = [0,0,1];
le_lit_color = [1,1,1];
le_lit_amb   = 0.4;
le_lit_rim   = 0.3;
le_update_lighting();

le_sel_obj   = -1;
le_hover_obj = -1;
le_obj_scroll = 0;
le_obj_sx    = array_create(128, -1);
le_obj_sy    = array_create(128, -1);

// Boutons propriétés
le_hold_btn   = "";
le_hold_t     = 0;
le_hold_step  = 0;

// Modal
le_modal_open = false;
le_modal_cat  = 0;

// Shader uniforms - Shader1
le_u_ldir        = shader_get_uniform(Shader1, "u_lightDir");
le_u_lcol        = shader_get_uniform(Shader1, "u_lightColor");
le_u_lamb        = shader_get_uniform(Shader1, "u_ambient");
le_u_lrim        = shader_get_uniform(Shader1, "u_rimStrength");
le_u_pl0         = shader_get_uniform(Shader1, "u_pl0");
le_u_pl1         = shader_get_uniform(Shader1, "u_pl1");
le_u_pl0col      = shader_get_uniform(Shader1, "u_pl0col");
le_u_pl1col      = shader_get_uniform(Shader1, "u_pl1col");
le_u_pl2         = shader_get_uniform(Shader1, "u_pl2");
le_u_pl2col      = shader_get_uniform(Shader1, "u_pl2col");
le_u_pl2rad      = shader_get_uniform(Shader1, "u_pl2rad");
le_u_pl3         = shader_get_uniform(Shader1, "u_pl3");
le_u_pl3col      = shader_get_uniform(Shader1, "u_pl3col");
le_u_pl3rad      = shader_get_uniform(Shader1, "u_pl3rad");
le_u_pl0rad      = shader_get_uniform(Shader1, "u_pl0rad");
le_u_pl1rad      = shader_get_uniform(Shader1, "u_pl1rad");
le_u_sprpos      = shader_get_uniform(Shader1, "u_sprpos");
le_u_flat_normal = shader_get_uniform(Shader1, "u_flat_normal");
le_u_litPos      = shader_get_uniform(Shader1, "u_litPos");
le_u_litRight    = shader_get_uniform(Shader1, "u_litRight");
le_u_litUp       = shader_get_uniform(Shader1, "u_litUp");
le_u_litFwd      = shader_get_uniform(Shader1, "u_litFwd");
le_u_litHW       = shader_get_uniform(Shader1, "u_litHW");
le_u_litHH       = shader_get_uniform(Shader1, "u_litHH");
le_u_litFar      = shader_get_uniform(Shader1, "u_litFar");
le_u_shadow_samp = shader_get_sampler_index(Shader1, "u_shadowMap");
le_u_shadow_en   = shader_get_uniform(Shader1, "u_shadowEnable");
le_u_shadow_dark = shader_get_uniform(Shader1, "u_shadowDark");
le_u_shadow_bias = shader_get_uniform(Shader1, "u_shadowBias");
le_u_shadow_recv = shader_get_uniform(Shader1, "u_shadowRecv");

// Occluders point lights
le_u_occ = array_create(8, -1);
le_u_occr = array_create(8, -1);
for (var _oi=0; _oi<8; _oi++) {
    le_u_occ[_oi]  = shader_get_uniform(Shader1, "u_occ"+string(_oi));
    le_u_occr[_oi] = shader_get_uniform(Shader1, "u_occr"+string(_oi));
}

// shd_floor pour terrain
le_u_fldir   = shader_get_uniform(shd_floor, "u_lightDir");
le_u_flcol   = shader_get_uniform(shd_floor, "u_lightColor");
le_u_flamb   = shader_get_uniform(shd_floor, "u_ambient");
le_u_fl_pl0    = shader_get_uniform(shd_floor, "u_pl0");
le_u_fl_pl1    = shader_get_uniform(shd_floor, "u_pl1");
le_u_fl_pl2    = shader_get_uniform(shd_floor, "u_pl2");
le_u_fl_pl3    = shader_get_uniform(shd_floor, "u_pl3");
le_u_fl_pl0col = shader_get_uniform(shd_floor, "u_pl0col");
le_u_fl_pl1col = shader_get_uniform(shd_floor, "u_pl1col");
le_u_fl_pl2col = shader_get_uniform(shd_floor, "u_pl2col");
le_u_fl_pl3col = shader_get_uniform(shd_floor, "u_pl3col");
le_u_fl_pl0rad = shader_get_uniform(shd_floor, "u_pl0rad");
le_u_fl_pl1rad = shader_get_uniform(shd_floor, "u_pl1rad");
le_u_fl_pl2rad = shader_get_uniform(shd_floor, "u_pl2rad");
le_u_fl_pl3rad = shader_get_uniform(shd_floor, "u_pl3rad");
le_u_fl_litPos      = shader_get_uniform(shd_floor, "u_litPos");
le_u_fl_litRight    = shader_get_uniform(shd_floor, "u_litRight");
le_u_fl_litUp       = shader_get_uniform(shd_floor, "u_litUp");
le_u_fl_litFwd      = shader_get_uniform(shd_floor, "u_litFwd");
le_u_fl_litHW       = shader_get_uniform(shd_floor, "u_litHW");
le_u_fl_litHH       = shader_get_uniform(shd_floor, "u_litHH");
le_u_fl_litFar      = shader_get_uniform(shd_floor, "u_litFar");
le_u_fl_shadow_samp = shader_get_sampler_index(shd_floor, "u_shadowMap");
le_u_fl_shadow_en   = shader_get_uniform(shd_floor, "u_shadowEnable");
le_u_fl_shadow_dark = shader_get_uniform(shd_floor, "u_shadowDark");
le_u_fl_shadow_bias = shader_get_uniform(shd_floor, "u_shadowBias");

// shd_shadow
le_u_sh_litPos   = shader_get_uniform(shd_shadow, "u_litPos");
le_u_sh_litRight = shader_get_uniform(shd_shadow, "u_litRight");
le_u_sh_litUp    = shader_get_uniform(shd_shadow, "u_litUp");
le_u_sh_litFwd   = shader_get_uniform(shd_shadow, "u_litFwd");
le_u_sh_litHW    = shader_get_uniform(shd_shadow, "u_litHW");
le_u_sh_litHH    = shader_get_uniform(shd_shadow, "u_litHH");
le_u_sh_litFar   = shader_get_uniform(shd_shadow, "u_litFar");

// Shadow map
le_shadow_enable   = true;
le_shadow_surf     = -1;
le_shadow_sz       = 2048;
le_shadow_darkness = 0.30;
le_shadow_bias     = 0.004;
le_shadow_panel    = false;
le_shadow_sl_drag  = "";

// Lumiere base
le_lit_pos   = [0, 0, 3500];
le_lit_right = [1, 0, 0];
le_lit_up    = [0, 0, 1];
le_lit_fwd   = [0, 0, -1];
le_lit_hw    = 1100;
le_lit_hh    = 750;
le_lit_far   = 8000;

// Grille sol
le_grid_vb = vertex_create_buffer();
vertex_begin(le_grid_vb, global.vFormat);
var _gs = 100; var _gc = 12;
for (var _gi = -_gc; _gi <= _gc; _gi++) {
    var _cx = (_gi == 0) ? #4488FF : #2A3A4A;
    var _cy = (_gi == 0) ? #FF5544 : #2A3A4A;
    vertex_position_3d(le_grid_vb, _gi*_gs,-_gc*_gs,0); vertex_texcoord(le_grid_vb,0,0); vertex_color(le_grid_vb,_cx,0.7);
    vertex_position_3d(le_grid_vb, _gi*_gs, _gc*_gs,0); vertex_texcoord(le_grid_vb,0,0); vertex_color(le_grid_vb,_cx,0.7);
    vertex_position_3d(le_grid_vb,-_gc*_gs, _gi*_gs,0); vertex_texcoord(le_grid_vb,0,0); vertex_color(le_grid_vb,_cy,0.7);
    vertex_position_3d(le_grid_vb, _gc*_gs, _gi*_gs,0); vertex_texcoord(le_grid_vb,0,0); vertex_color(le_grid_vb,_cy,0.7);
}
vertex_end(le_grid_vb);
vertex_freeze(le_grid_vb);

// Animations personnages
le_anim_t = 0.0;

// FK character system
if (!variable_global_exists("char_parts")) {
    global.char_root_bz = 50;
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
    var _F_front = [8,9,6,7, 0, 4,5,2,3, 1];
    var _F_back  = [1, 2,3,4,5, 0, 6,7,8,9];
    var _D_front = [4,5,8,9, 0, 1, 2,3,6,7];
    var _G_front = [2,3,6,7, 0, 1, 4,5,8,9];
    global.char_layer_order = [_F_front,_D_front,_D_front,_D_front,_F_back,_G_front,_G_front,_G_front];
    global.anim_lib = {};
    global.anim_lib[$ "idle"] = {
        loop:true, length:120,
        kf:[
            { t:0.00, angles:[ 0,  0,155,165,205,195,180,180,180,180], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:0 },
            { t:0.50, angles:[ 2,  2,153,163,207,197,182,182,182,182], angles_lat:[0,0,0,0,0,0,0,0,0,0], root_z:0 },
        ]
    };
    global.char_fk = function(anim_name, t) {
        var _parts  = global.char_parts;
        var _n      = array_length(_parts);
        var _result = array_create(_n, undefined);
        var _angles     = array_create(_n, 0);
        var _angles_lat = array_create(_n, 0);
        var _root_z = 0;
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
                var _da  = ((_k1.angles[_i]-_k0.angles[_i]+540) mod 360)-180;
                var _dal = ((_lat1[_i]-_lat0[_i]+540) mod 360)-180;
                _angles[_i]     = _k0.angles[_i] + _da  * _f;
                _angles_lat[_i] = _lat0[_i]       + _dal * _f;
            }
            _root_z = lerp(
                variable_struct_exists(_k0,"root_z") ? _k0.root_z : 0,
                variable_struct_exists(_k1,"root_z") ? _k1.root_z : 0, _f);
        } else {
            for (var _i = 0; _i < _n; _i++) {
                _angles[_i]     = _parts[_i].ang;
                _angles_lat[_i] = variable_struct_exists(_parts[_i],"ang_lat") ? _parts[_i].ang_lat : 0;
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
            };
        }
        return _result;
    };
}

// Assets 3D du projet
le_asset_list = [];
var _known_models = [
    { name:"olonako",       path:"D:\\Proj_GMK\\inter-classe2.yyp\\3dassets\\olonako\\olonako.obj" },
    { name:"zweite blend",  path:"D:\\Proj_GMK\\inter-classe2.yyp\\3dassets\\zweite blend\\zweite blend.obj" },
];
for (var _ki = 0; _ki < array_length(_known_models); _ki++) {
    var _km = _known_models[_ki];
    if (file_exists(_km.path))
        array_push(le_asset_list, { name:_km.name, path:_km.path });
}

le_hover_btn_add = false;
le_hover_btn_del = false;

// Notification
le_notif = "";
le_notif_time = 0;
