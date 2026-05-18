// === ÉDITEUR DE NIVEAU ===
depth = -99999;

// Layout
le_panel_left_w  = 260;
le_panel_right_w = 280;
le_viewport_x    = le_panel_left_w;
le_viewport_w    = 1280 - le_panel_left_w - le_panel_right_w;
le_viewport_h    = 720;

// Load level from selector if provided
if (variable_global_exists("level_to_load") && global.level_to_load != "") {
    le_objects = level_loader(global.level_to_load);
    global.level_to_load = "";
}

// Surface 3D
le_surf = -1;

// Caméra orbitale
le_cam_angle  = 35.0;   // pitch (degrés depuis l'horizontal)
le_cam_yaw    = 45.0;   // rotation horizontale
le_cam_dist   = 800.0;
le_cam_cx     = 0.0;
le_cam_cy     = 0.0;
le_cam_cz     = 0.0;
le_cam_fov    = 45.0;

// Drag caméra (bouton droit)
le_drag_cam = false;
le_drag_mx  = 0; le_drag_my  = 0;
le_drag_yaw = 0; le_drag_ang = 0;
// Pan caméra (bouton milieu)
le_pan_cam  = false;
le_pan_mx   = 0; le_pan_my   = 0;
le_pan_cx   = 0; le_pan_cy   = 0;

// Éclairage — slider jour/nuit + orientation soleil
le_day_hour = 14.0;     // 0..24
le_day_dragging = false;
le_sun_azimuth = 0.0;   // offset azimut manuel en radians [-pi..pi]
le_sun_az_drag = false;

le_update_lighting = function() {
    var _h = le_day_hour;
    if (_h >= 5.5 && _h <= 20.5) {
        var _t    = (_h - 5.5) / 15.0;          // 0=aube, 0.5=midi, 1=coucher
        var _warm = abs(_t - 0.5) * 2;           // 0=zenith, 1=horizon
        // Coordonnées sphériques propres :
        // elevation angle : 0° à l'horizon, 90° à midi
        var _elev_rad = _t * pi;                  // 0..pi
        var _elev = sin(_elev_rad);               // 0 aube → 1 midi → 0 coucher
        var _horiz = cos(_elev_rad);              // 1 aube → 0 midi → -1 coucher (signe pour E→O)
        // Direction lumière : azimut contrôle uniquement le cap horizontal
        // A midi : _horiz = 0 → direction purement verticale → ombre sous l'objet
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
        // Nuit : direction fixe, azimut s'applique aussi
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


// Objets de la scène  {type, vb, x,y,z, rx,ry,rz, sx,sy,sz, name, col, intensity (lumières)}
le_objects   = [];
le_sel_obj   = -1;
le_hover_obj = -1;
le_obj_scroll = 0;          // scroll liste objets panneau gauche
le_obj_sx    = array_create(128, -1); // positions écran projetées (hover)
le_obj_sy    = array_create(128, -1);

// Boutons propriétés : hold pour accélérer
le_hold_btn   = "";   // "px+","px-","py+","py-","pz+","pz-","s+","s-","rz+","rz-"
le_hold_t     = 0;
le_hold_step  = 0;

// Modal ajout d'objet
le_modal_open = false;
le_modal_cat  = 0;    // catégorie hover dans modal

// Shader uniforms
if (!variable_global_exists("vFormat")) {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    vertex_format_add_color();
    global.vFormat = vertex_format_end();
}
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
// Shadow map — Shader1 (uniforms geometriques lumiere)
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
// Occluders lumières ponctuelles
le_u_occ = array_create(8, -1);
le_u_occr = array_create(8, -1);
for (var _oi=0; _oi<8; _oi++) {
    le_u_occ[_oi]  = shader_get_uniform(Shader1, "u_occ"+string(_oi));
    le_u_occr[_oi] = shader_get_uniform(Shader1, "u_occr"+string(_oi));
}

// shd_floor pour le terrain de match (su_ter1)
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
// Shadow map — shd_floor (memes uniforms geometriques)
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

// shd_shadow uniforms geometriques
le_u_sh_litPos   = shader_get_uniform(shd_shadow, "u_litPos");
le_u_sh_litRight = shader_get_uniform(shd_shadow, "u_litRight");
le_u_sh_litUp    = shader_get_uniform(shd_shadow, "u_litUp");
le_u_sh_litFwd   = shader_get_uniform(shd_shadow, "u_litFwd");
le_u_sh_litHW    = shader_get_uniform(shd_shadow, "u_litHW");
le_u_sh_litHH    = shader_get_uniform(shd_shadow, "u_litHH");
le_u_sh_litFar   = shader_get_uniform(shd_shadow, "u_litFar");

// Shadow map surface + parametres
le_shadow_enable   = false;
le_shadow_surf     = -1;
le_shadow_sz       = 2048;
le_shadow_darkness = 0.30; // noirceur ombre [0=noir total .. 1=invisible]
le_shadow_bias     = 0.004; // biais precision [0.001..0.010]
le_shadow_panel    = false; // panneau parametres ouvert
le_shadow_sl_drag  = "";    // slider en cours de drag ("dark","bias","")

// Vecteurs base lumiere (calcules dans Draw_0 a chaque frame)
le_lit_pos   = [0, 0, 3500];
le_lit_right = [1, 0, 0];
le_lit_up    = [0, 0, 1];
le_lit_fwd   = [0, 0, -1];
le_lit_hw    = 1100;
le_lit_hh    = 750;
le_lit_far   = 8000;

// ── Grille sol ────────────────────────────────────────────────────
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

// ── Fonctions utilitaires ─────────────────────────────────────────
le_make_cube_vb = function(_hw) {
    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);
    var _cv=[[-_hw,-_hw,0],[_hw,-_hw,0],[_hw,_hw,0],[-_hw,_hw,0],
             [-_hw,-_hw,_hw*2],[_hw,-_hw,_hw*2],[_hw,_hw,_hw*2],[-_hw,_hw,_hw*2]];
    var _cf=[[0,2,1,0,3,2],[4,5,6,4,6,7],[0,1,5,0,5,4],[2,3,7,2,7,6],[0,4,7,0,7,3],[1,2,6,1,6,5]];
    var _cn=[[0,0,-1],[0,0,1],[0,-1,0],[0,1,0],[-1,0,0],[1,0,0]];
    for(var _fi=0;_fi<6;_fi++){
        var _nx=_cn[_fi][0];var _ny=_cn[_fi][1];var _nz=_cn[_fi][2];
        var _col2=make_color_rgb(round((_nz*0.5+0.5)*255),128,128);
        for(var _vi=0;_vi<6;_vi++){
            var _idx=_cf[_fi][_vi];
            vertex_position_3d(_vb,_cv[_idx][0],_cv[_idx][1],_cv[_idx][2]);
            vertex_texcoord(_vb,_nx*0.5+0.5,_ny*0.5+0.5); vertex_color(_vb,_col2,1.0);
        }
    }
    vertex_end(_vb); vertex_freeze(_vb);
    return _vb;
};

// Helper : split un token "v/vt/vn" ou "v/vt" ou "v//vn" ou "v"
// Retourne [vi-1, ti-1] (indices 0-based, -1 si absent)
le_parse_tok = function(_tok) {
    var _s1 = string_pos("/", _tok);
    if (_s1 == 0) return [real(_tok)-1, -1];
    var _vi = real(string_copy(_tok, 1, _s1-1)) - 1;
    var _rest = string_copy(_tok, _s1+1, string_length(_tok)-_s1);
    var _s2 = string_pos("/", _rest);
    var _ti = -1;
    if (_s2 == 0) { // v/vt
        if (string_length(_rest) > 0) _ti = real(_rest) - 1;
    } else { // v/vt/vn ou v//vn
        var _ts = string_copy(_rest, 1, _s2-1);
        if (string_length(_ts) > 0) _ti = real(_ts) - 1;
    }
    return [_vi, _ti];
};

// Parse un .obj avec UV et MTL automatique
// Retourne struct { vb, tex_spr } ou undefined
le_parse_obj = function(_path) {
    if (!file_exists(_path)) return undefined;
    var _dir = filename_dir(_path) + "\\";

    // ── Passe 1 : lire géométrie + UV + référence MTL ───────────
    var _vx=[]; var _vy=[]; var _vz=[];
    var _tu=[]; var _tv=[];           // UV coords bruts du fichier
    var _faces=[];                    // chaque face = [[vi,ti],[vi,ti],[vi,ti]]
    var _mtl_file = "";              // nom du fichier .mtl
    var _f = file_text_open_read(_path);
    while (!file_text_eof(_f)) {
        var _line = file_text_readln(_f);
        // Supprimer \r éventuel (Windows)
        if (string_byte_at(_line, string_length(_line)) == 13)
            _line = string_copy(_line, 1, string_length(_line)-1);
        var _len = string_length(_line);
        if (_len == 0) continue;
        var _pfx2 = string_copy(_line, 1, 2);
        var _pfx3 = string_copy(_line, 1, 3);
        var _pfx7 = string_copy(_line, 1, 7);

        if (_pfx7 == "mtllib ") {
            _mtl_file = string_copy(_line, 8, _len-7);

        } else if (_pfx3 == "vt ") {
            // UV coord
            var _r = string_copy(_line, 4, _len-3);
            var _sp = string_pos(" ", _r);
            if (_sp > 0) {
                array_push(_tu, real(string_copy(_r, 1, _sp-1)));
                // V inversé : OBJ V=0 = bas, GMS V=0 = haut
                array_push(_tv, 1.0 - real(string_copy(_r, _sp+1, string_length(_r)-_sp)));
            }

        } else if (_pfx2 == "v ") {
            var _r = string_copy(_line, 3, _len-2);
            var _s1=string_pos(" ",_r);
            var _a=real(string_copy(_r,1,_s1-1)); _r=string_copy(_r,_s1+1,string_length(_r)-_s1);
            var _s2=string_pos(" ",_r);
            var _b=real(string_copy(_r,1,_s2-1)); var _c=real(string_copy(_r,_s2+1,string_length(_r)));
            array_push(_vx,_a); array_push(_vy,_b); array_push(_vz,_c);

        } else if (_pfx2 == "f ") {
            var _r = string_copy(_line, 3, _len-2);
            var _corners = [];
            while (string_length(_r) > 0) {
                var _sp = string_pos(" ", _r);
                var _tok = (_sp>0) ? string_copy(_r,1,_sp-1) : _r;
                _r = (_sp>0) ? string_copy(_r,_sp+1,string_length(_r)-_sp) : "";
                if (string_length(_tok) > 0)
                    array_push(_corners, le_parse_tok(_tok));
            }
            // Fan triangulation
            for (var _fi=1; _fi<array_length(_corners)-1; _fi++)
                array_push(_faces, [_corners[0], _corners[_fi], _corners[_fi+1]]);
        }
    }
    file_text_close(_f);
    if (array_length(_vx)==0 || array_length(_faces)==0) return undefined;

    // ── Passe 2 : lire le MTL → charger texture AVANT le VB ────
    var _tex_spr = -1;
    // atlas UV remapping : u_atlas = au + u_obj*(bu-au), v_atlas = av + v_obj*(bv-av)
    var _atl_u0=0.0; var _atl_v0=0.0; var _atl_u1=1.0; var _atl_v1=1.0;
    if (_mtl_file != "") {
        var _mtl_path = _dir + _mtl_file;
        if (!file_exists(_mtl_path)) _mtl_path = _mtl_file; // chemin absolu
        if (file_exists(_mtl_path)) {
            var _fm = file_text_open_read(_mtl_path);
            while (!file_text_eof(_fm)) {
                var _ml = file_text_readln(_fm);
                if (string_byte_at(_ml, string_length(_ml)) == 13)
                    _ml = string_copy(_ml, 1, string_length(_ml)-1);
                var _mlen = string_length(_ml);
                if (_mlen < 8) continue;
                // map_Kd = texture diffuse
                if (string_copy(_ml,1,7) == "map_Kd ") {
                    var _tex_name = string_copy(_ml, 8, _mlen-7);
                    // Nettoyer les espaces/tabulations en début
                    while (string_length(_tex_name)>0 &&
                           (string_byte_at(_tex_name,1)==32 || string_byte_at(_tex_name,1)==9))
                        _tex_name = string_copy(_tex_name, 2, string_length(_tex_name)-1);
                    var _tex_path = _dir + _tex_name;
                    if (!file_exists(_tex_path)) _tex_path = _tex_name;
                    if (file_exists(_tex_path)) {
                        _tex_spr = sprite_add(_tex_path, 1, false, false, 0, 0);
                        // Récupérer les UV atlas IMMÉDIATEMENT après le chargement
                        var _uvs = sprite_get_uvs(_tex_spr, 0);
                        _atl_u0 = _uvs[0]; _atl_v0 = _uvs[1];
                        _atl_u1 = _uvs[2]; _atl_v1 = _uvs[3];
                    }
                    break;
                }
            }
            file_text_close(_fm);
        }
    }

    // ── Passe 3 : construire le vertex buffer ────────────────────
    var _has_uv = (array_length(_tu) > 0 && _tex_spr >= 0);
    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);
    for (var _fi=0; _fi<array_length(_faces); _fi++) {
        var _face = _faces[_fi];
        var _c0=_face[0]; var _c1=_face[1]; var _c2=_face[2];
        var _i0=_c0[0]; var _i1=_c1[0]; var _i2=_c2[0];
        var _t0=_c0[1]; var _t1=_c1[1]; var _t2=_c2[1];

        // Normale de face (pour eclairage flat + UV encode si pas de texture)
        var _ax=_vx[_i1]-_vx[_i0]; var _ay=_vy[_i1]-_vy[_i0]; var _az=_vz[_i1]-_vz[_i0];
        var _bx=_vx[_i2]-_vx[_i0]; var _by=_vy[_i2]-_vy[_i0]; var _bz=_vz[_i2]-_vz[_i0];
        var _nx=_ay*_bz-_az*_by; var _ny=_az*_bx-_ax*_bz; var _nz=_ax*_by-_ay*_bx;
        var _nl=max(sqrt(_nx*_nx+_ny*_ny+_nz*_nz),0.0001);
        _nx/=_nl; _ny/=_nl; _nz/=_nl;
        var _enc_u = _nx*0.5+0.5; var _enc_v = _ny*0.5+0.5;
        var _col = (_tex_spr >= 0) ? c_white : make_color_rgb(round((_nz*0.5+0.5)*255),128,128);

        var _verts = [_i0,_i1,_i2];
        var _terts = [_t0,_t1,_t2];
        for (var _vi=0; _vi<3; _vi++) {
            var _idx = _verts[_vi]; var _tidx = _terts[_vi];
            var _uu, _vv;
            if (_has_uv && _tidx >= 0) {
                // Remapper UV OBJ (0..1) vers UV atlas GMS2
                _uu = _atl_u0 + _tu[_tidx] * (_atl_u1 - _atl_u0);
                _vv = _atl_v0 + _tv[_tidx] * (_atl_v1 - _atl_v0);
            } else {
                _uu = _enc_u; _vv = _enc_v;
            }
            vertex_position_3d(_vb, _vx[_idx], _vy[_idx], _vz[_idx]);
            vertex_texcoord(_vb, _uu, _vv);
            vertex_color(_vb, _col, 1.0);
        }
    }
    vertex_end(_vb); vertex_freeze(_vb);
    return { vb:_vb, tex_spr:_tex_spr };
};

// ── Terrain de match (UV via sprite_get_uvs pour su_ter1) ────────
le_make_terrain_vb = function() {
    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);
    var _hw = 700; var _hd = 400;
    // sprite_get_uvs retourne les coords réelles dans la texture atlas
    var _uvs = sprite_get_uvs(su_ter1, 0);
    var _u0 = _uvs[0]; var _v0 = _uvs[1];
    var _u1 = _uvs[2]; var _v1 = _uvs[3];
    vertex_position_3d(_vb,-_hw,-_hd,0); vertex_texcoord(_vb,_u0,_v0); vertex_color(_vb,c_white,1.0);
    vertex_position_3d(_vb, _hw,-_hd,0); vertex_texcoord(_vb,_u1,_v0); vertex_color(_vb,c_white,1.0);
    vertex_position_3d(_vb, _hw, _hd,0); vertex_texcoord(_vb,_u1,_v1); vertex_color(_vb,c_white,1.0);
    vertex_position_3d(_vb,-_hw,-_hd,0); vertex_texcoord(_vb,_u0,_v0); vertex_color(_vb,c_white,1.0);
    vertex_position_3d(_vb, _hw, _hd,0); vertex_texcoord(_vb,_u1,_v1); vertex_color(_vb,c_white,1.0);
    vertex_position_3d(_vb,-_hw, _hd,0); vertex_texcoord(_vb,_u0,_v1); vertex_color(_vb,c_white,1.0);
    vertex_end(_vb); vertex_freeze(_vb);
    return _vb;
};

// ── Plan terrain ──────────────────────────────────────────────────
le_make_plane_vb = function(_hw, _seg, _col) {
    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);
    var _step = _hw*2 / _seg;
    for (var _j = 0; _j < _seg; _j++) {
        for (var _i = 0; _i < _seg; _i++) {
            var _x0 = -_hw + _i*_step;  var _x1 = _x0+_step;
            var _y0 = -_hw + _j*_step;  var _y1 = _y0+_step;
            // upward normal → UV (0.5,0.5)
            vertex_position_3d(_vb,_x0,_y0,0); vertex_texcoord(_vb,0.5,0.5); vertex_color(_vb,_col,1.0);
            vertex_position_3d(_vb,_x1,_y0,0); vertex_texcoord(_vb,0.5,0.5); vertex_color(_vb,_col,1.0);
            vertex_position_3d(_vb,_x1,_y1,0); vertex_texcoord(_vb,0.5,0.5); vertex_color(_vb,_col,1.0);
            vertex_position_3d(_vb,_x0,_y0,0); vertex_texcoord(_vb,0.5,0.5); vertex_color(_vb,_col,1.0);
            vertex_position_3d(_vb,_x1,_y1,0); vertex_texcoord(_vb,0.5,0.5); vertex_color(_vb,_col,1.0);
            vertex_position_3d(_vb,_x0,_y1,0); vertex_texcoord(_vb,0.5,0.5); vertex_color(_vb,_col,1.0);
        }
    }
    vertex_end(_vb); vertex_freeze(_vb);
    return _vb;
};

// ── Capsule personnage (cylindre + tête) ──────────────────────────
le_make_capsule_vb = function() {
    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);
    // Ajoute un box dans le vb
    var _add_box = function(_vb2, _ox, _oy, _oz, _hw2, _hd, _hh, _col2) {
        var _cv = [
            [_ox-_hw2,_oy-_hd,_oz],[_ox+_hw2,_oy-_hd,_oz],[_ox+_hw2,_oy+_hd,_oz],[_ox-_hw2,_oy+_hd,_oz],
            [_ox-_hw2,_oy-_hd,_oz+_hh],[_ox+_hw2,_oy-_hd,_oz+_hh],[_ox+_hw2,_oy+_hd,_oz+_hh],[_ox-_hw2,_oy+_hd,_oz+_hh]
        ];
        var _cf = [[0,2,1,0,3,2],[4,5,6,4,6,7],[0,1,5,0,5,4],[2,3,7,2,7,6],[0,4,7,0,7,3],[1,2,6,1,6,5]];
        var _cn = [[0,0,-1],[0,0,1],[0,-1,0],[0,1,0],[-1,0,0],[1,0,0]];
        for (var _fi=0;_fi<6;_fi++){
            var _nx2=_cn[_fi][0]; var _ny2=_cn[_fi][1];
            for (var _vi=0;_vi<6;_vi++){
                var _idx=_cf[_fi][_vi];
                vertex_position_3d(_vb2,_cv[_idx][0],_cv[_idx][1],_cv[_idx][2]);
                vertex_texcoord(_vb2,_nx2*0.5+0.5,_ny2*0.5+0.5); vertex_color(_vb2,_col2,1.0);
            }
        }
    };
    var _col_body = make_color_rgb(100,140,210);
    var _col_head = make_color_rgb(220,180,140);
    _add_box(_vb, 0,0,0,   20,15,100, _col_body); // corps
    _add_box(_vb, 0,0,100, 14,14,30,  _col_head); // tête
    _add_box(_vb,-30,0,30, 8,8,60,   _col_body); // bras gauche
    _add_box(_vb, 30,0,30, 8,8,60,   _col_body); // bras droit
    vertex_end(_vb); vertex_freeze(_vb);
    return _vb;
};

// Terrain de match par défaut (su_ter1 texture, shd_floor)
array_push(le_objects, {type:"terrain", vb:le_make_terrain_vb(),
    x:0,y:0,z:0, rx:0,ry:0,rz:0, sx:1,sy:1,sz:1, name:"Terrain match", col:c_white});

// Timer animation personnages
le_anim_t = 0.0;

// ── Système FK personnage (même guard que o_p) ────────────────────
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

// Modeles 3D du projet — file_find_first est sandboxe sur Windows GMS2,
// on utilise file_exists avec les chemins absolus directement.
// Pour ajouter un nouveau modele : ajouter une ligne { name, path } dans le tableau.
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
// Hover boutons (mis a jour dans Step_0)
le_hover_btn_add = false;
le_hover_btn_del = false;

// Notif
le_notif = (array_length(le_asset_list) > 0)
    ? "Assets: " + string(array_length(le_asset_list)) + " modeles OK"
    : "Assets introuvables (verifier les chemins)";
le_notif_time = 180;
