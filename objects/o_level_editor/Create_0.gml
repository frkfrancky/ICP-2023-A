// === ÉDITEUR DE NIVEAU ===
depth = -99999;

// Layout
le_panel_left_w  = 260;
le_panel_right_w = 280;
le_viewport_x    = le_panel_left_w;
le_viewport_w    = 1280 - le_panel_left_w - le_panel_right_w;
le_viewport_h    = 720;

// Surface 3D
le_surf      = -1;
le_cam_angle = 30.0;   // inclinaison caméra (degrés depuis horizontal)
le_cam_yaw   = 225.0;  // rotation horizontale de la caméra
le_cam_dist  = 800.0;  // distance au centre
le_cam_cx    = 0.0;    // centre cible x
le_cam_cy    = 0.0;    // centre cible y
le_cam_cz    = 0.0;    // centre cible z
le_cam_fov   = 45.0;

// Drag caméra
le_drag_cam  = false;
le_drag_mx   = 0;
le_drag_my   = 0;
le_drag_yaw  = 0;
le_drag_ang  = 0;

// Éclairage
le_day_presets = [
    { name:"Matin",   hour: 7.0, dir:[0.82,0.55,0.15], col:[1.0,0.85,0.60], amb:0.30, rim:0.40 },
    { name:"Midi",    hour:12.0, dir:[0.10,0.99,0.10], col:[1.0,1.00,0.95], amb:0.50, rim:0.25 },
    { name:"Soir",    hour:17.0, dir:[0.85,0.48,0.22], col:[1.0,0.70,0.40], amb:0.28, rim:0.55 },
    { name:"Nuit",    hour:22.0, dir:[0.10,0.30,0.95], col:[0.2,0.25,0.40], amb:0.12, rim:0.20 },
    { name:"Nuageux", hour:12.0, dir:[0.20,0.90,0.38], col:[0.7,0.75,0.80], amb:0.55, rim:0.10 },
    { name:"Pluie",   hour:12.0, dir:[0.05,0.80,0.60], col:[0.5,0.55,0.65], amb:0.60, rim:0.05 },
];
le_preset_sel = 1; // Midi par défaut

var _p = le_day_presets[le_preset_sel];
le_lit_dir   = _p.dir;
le_lit_color = _p.col;
le_lit_amb   = _p.amb;
le_lit_rim   = _p.rim;

// Objets de la scène
le_objects   = [];   // tableau de structs {vb, x, y, z, rx, ry, rz, sx, sy, sz, name, col}
le_sel_obj   = -1;   // index sélectionné
le_hover_obj = -1;

// Shader uniforms
if (variable_global_exists("vFormat")) {
    le_u_ldir        = shader_get_uniform(Shader1, "u_lightDir");
    le_u_lcol        = shader_get_uniform(Shader1, "u_lightColor");
    le_u_lamb        = shader_get_uniform(Shader1, "u_ambient");
    le_u_lrim        = shader_get_uniform(Shader1, "u_rimStrength");
    le_u_pl0         = shader_get_uniform(Shader1, "u_pl0");
    le_u_pl1         = shader_get_uniform(Shader1, "u_pl1");
    le_u_plcol       = shader_get_uniform(Shader1, "u_plcol");
    le_u_plrad       = shader_get_uniform(Shader1, "u_plrad");
    le_u_sprpos      = shader_get_uniform(Shader1, "u_sprpos");
    le_u_flat_normal = shader_get_uniform(Shader1, "u_flat_normal");
} else {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    vertex_format_add_color();
    global.vFormat = vertex_format_end();
    le_u_ldir        = shader_get_uniform(Shader1, "u_lightDir");
    le_u_lcol        = shader_get_uniform(Shader1, "u_lightColor");
    le_u_lamb        = shader_get_uniform(Shader1, "u_ambient");
    le_u_lrim        = shader_get_uniform(Shader1, "u_rimStrength");
    le_u_pl0         = shader_get_uniform(Shader1, "u_pl0");
    le_u_pl1         = shader_get_uniform(Shader1, "u_pl1");
    le_u_plcol       = shader_get_uniform(Shader1, "u_plcol");
    le_u_plrad       = shader_get_uniform(Shader1, "u_plrad");
    le_u_sprpos      = shader_get_uniform(Shader1, "u_sprpos");
    le_u_flat_normal = shader_get_uniform(Shader1, "u_flat_normal");
}

// Grille sol (vertex buffer statique)
le_grid_vb = -1;
le_grid_vb = vertex_create_buffer();
vertex_begin(le_grid_vb, global.vFormat);
var _gs = 100; var _gc = 10;
for (var _gi = -_gc; _gi <= _gc; _gi++) {
    // lignes X
    vertex_position_3d(le_grid_vb, _gi*_gs, -_gc*_gs, 0);
    vertex_texcoord(le_grid_vb, 0, 0);
    vertex_color(le_grid_vb, (_gi==0) ? #4488FF : #334455, 0.5);
    vertex_position_3d(le_grid_vb, _gi*_gs,  _gc*_gs, 0);
    vertex_texcoord(le_grid_vb, 0, 0);
    vertex_color(le_grid_vb, (_gi==0) ? #4488FF : #334455, 0.5);
    // lignes Y
    vertex_position_3d(le_grid_vb, -_gc*_gs, _gi*_gs, 0);
    vertex_texcoord(le_grid_vb, 0, 0);
    vertex_color(le_grid_vb, (_gi==0) ? #FF4444 : #334455, 0.5);
    vertex_position_3d(le_grid_vb,  _gc*_gs, _gi*_gs, 0);
    vertex_texcoord(le_grid_vb, 0, 0);
    vertex_color(le_grid_vb, (_gi==0) ? #FF4444 : #334455, 0.5);
}
vertex_end(le_grid_vb);
vertex_freeze(le_grid_vb);

// Notif
le_notif      = "";
le_notif_time = 0;

// OBJ parser (fonction locale)
le_parse_obj = function(_path) {
    if (!file_exists(_path)) return undefined;
    var _f  = file_text_open_read(_path);
    var _vx = []; var _vy = []; var _vz = [];
    var _faces = [];
    while (!file_text_eof(_f)) {
        var _line = file_text_readln(_f);
        // trim
        while (string_length(_line) > 0 && string_byte_at(_line,1) == 32) _line = string_copy(_line,2,string_length(_line)-1);
        if (string_copy(_line,1,2) == "v ") {
            // vertex position
            var _rest = string_copy(_line,3,string_length(_line)-2);
            var _sp1 = string_pos(" ",_rest); var _a = real(string_copy(_rest,1,_sp1-1)); _rest = string_copy(_rest,_sp1+1,string_length(_rest)-_sp1);
            var _sp2 = string_pos(" ",_rest); var _b = real(string_copy(_rest,1,_sp2-1)); var _c = real(string_copy(_rest,_sp2+1,string_length(_rest)-_sp2));
            array_push(_vx,_a); array_push(_vy,_b); array_push(_vz,_c);
        } else if (string_copy(_line,1,2) == "f ") {
            // face (simplifié : prend seulement l'indice vertex, ignore UV et normales)
            var _rest = string_copy(_line,3,string_length(_line)-2);
            var _idx = [];
            while (string_length(_rest) > 0) {
                var _sp = string_pos(" ",_rest);
                var _tok = (_sp > 0) ? string_copy(_rest,1,_sp-1) : _rest;
                _rest = (_sp > 0) ? string_copy(_rest,_sp+1,string_length(_rest)-_sp) : "";
                // token peut être "1", "1/2", "1/2/3", "1//3"
                var _slpos = string_pos("/",_tok); var _vi = (_slpos>0) ? real(string_copy(_tok,1,_slpos-1)) : real(_tok);
                if (_vi > 0) array_push(_idx, _vi-1); // OBJ 1-based → 0-based
            }
            // fan triangulation
            for (var _fi = 1; _fi < array_length(_idx)-1; _fi++)
                array_push(_faces, [_idx[0], _idx[_fi], _idx[_fi+1]]);
        }
    }
    file_text_close(_f);
    if (array_length(_vx) == 0 || array_length(_faces) == 0) return undefined;

    // Construire vertex buffer
    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);
    for (var _fi = 0; _fi < array_length(_faces); _fi++) {
        var _f3 = _faces[_fi];
        var _i0=_f3[0]; var _i1=_f3[1]; var _i2=_f3[2];
        // Normale face
        var _ax=_vx[_i1]-_vx[_i0]; var _ay=_vy[_i1]-_vy[_i0]; var _az=_vz[_i1]-_vz[_i0];
        var _bx=_vx[_i2]-_vx[_i0]; var _by=_vy[_i2]-_vy[_i0]; var _bz=_vz[_i2]-_vz[_i0];
        var _nx=_ay*_bz-_az*_by; var _ny=_az*_bx-_ax*_bz; var _nz=_ax*_by-_ay*_bx;
        var _nl=max(sqrt(_nx*_nx+_ny*_ny+_nz*_nz),0.0001); _nx/=_nl; _ny/=_nl; _nz/=_nl;
        // On encode la normale dans UV (u=nx*0.5+0.5, v=ny*0.5+0.5) et z dans color alpha
        var _nu = _nx*0.5+0.5; var _nv = _ny*0.5+0.5;
        var _col = make_color_rgb(round((_nz*0.5+0.5)*255), 128, 128);
        vertex_position_3d(_vb, _vx[_i0],_vy[_i0],_vz[_i0]); vertex_texcoord(_vb,_nu,_nv); vertex_color(_vb,_col,1.0);
        vertex_position_3d(_vb, _vx[_i1],_vy[_i1],_vz[_i1]); vertex_texcoord(_vb,_nu,_nv); vertex_color(_vb,_col,1.0);
        vertex_position_3d(_vb, _vx[_i2],_vy[_i2],_vz[_i2]); vertex_texcoord(_vb,_nu,_nv); vertex_color(_vb,_col,1.0);
    }
    vertex_end(_vb);
    vertex_freeze(_vb);
    return _vb;
};

// Ajouter une boîte de test comme objet par défaut
var _box_vb = vertex_create_buffer();
vertex_begin(_box_vb, global.vFormat);
// 6 faces d'un cube 100×100×100
var _cv = [[-50,-50,0],[50,-50,0],[50,50,0],[-50,50,0],[-50,-50,100],[50,-50,100],[50,50,100],[-50,50,100]];
var _cf = [[0,1,2,0,2,3],[4,6,5,4,7,6],[0,4,5,0,5,1],[2,6,7,2,7,3],[0,3,7,0,7,4],[1,5,6,1,6,2]];
var _cn = [[0,0,-1],[0,0,1],[0,-1,0],[0,1,0],[-1,0,0],[1,0,0]];
for (var _fi=0;_fi<6;_fi++){
    var _nx=_cn[_fi][0]; var _ny=_cn[_fi][1]; var _nz=_cn[_fi][2];
    var _nu=_nx*0.5+0.5; var _nv=_ny*0.5+0.5;
    var _col2=make_color_rgb(round((_nz*0.5+0.5)*255),128,128);
    for (var _vi=0;_vi<6;_vi++){
        var _idx2=_cf[_fi][_vi];
        vertex_position_3d(_box_vb,_cv[_idx2][0],_cv[_idx2][1],_cv[_idx2][2]);
        vertex_texcoord(_box_vb,_nu,_nv); vertex_color(_box_vb,_col2,1.0);
    }
}
vertex_end(_box_vb);
vertex_freeze(_box_vb);
array_push(le_objects, {vb:_box_vb, x:0,y:0,z:0, rx:0,ry:0,rz:0, sx:1,sy:1,sz:1, name:"Cube", col:#AABB88});
