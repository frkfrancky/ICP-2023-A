// === ÉDITEUR D'ANIMATIONS STANDALONE ===
show_editor = true;
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
prev_cy    = ed_timeline_y * 0.65;
prev_dir   = 180;
prev_scale = 3.0;

ed_sel_anim   = "idle";
ed_sel_kf     = 0;
ed_sel_part   = -1;
ed_hover_part = -1;

tl_playing = false;
tl_time    = 0.0;
tl_drag_kf = -1;

ed_notif      = "";
ed_notif_time = 0;
ed_anim_scroll = 0;

// ── Init globals squelette directement (sans o_p) ───────────────
if (!variable_global_exists("char_parts")) {

    global.char_root_bz = 50;

    global.char_parts = [
        { parent:-1, pdx:  0, pdz:  0, ang:  0, len:40, hw:10, col:#4466BB },
        { parent: 0, pdx:  0, pdz:  3, ang:  0, len:18, hw: 9, col:#F5C88A },
        { parent: 0, pdx: 10, pdz: -2, ang:155, len:22, hw: 4, col:#CC3322 },
        { parent: 2, pdx:  0, pdz:  0, ang:165, len:20, hw: 3, col:#EE6644 },
        { parent: 0, pdx:-10, pdz: -2, ang:205, len:22, hw: 4, col:#226633 },
        { parent: 4, pdx:  0, pdz:  0, ang:195, len:20, hw: 3, col:#44AA66 },
        { parent: 0, pdx:  5, pdz:-40, ang:180, len:26, hw: 6, col:#774411 },
        { parent: 6, pdx:  0, pdz:  0, ang:180, len:24, hw: 5, col:#BB8855 },
        { parent: 0, pdx: -5, pdz:-40, ang:180, len:26, hw: 6, col:#114466 },
        { parent: 8, pdx:  0, pdz:  0, ang:180, len:24, hw: 5, col:#5599BB },
    ];

    var _Df = [8,9,4,5, 0, 6,7,2,3, 1];
    var _Gf = [6,7,2,3, 0, 8,9,4,5, 1];
    global.char_layer_order = [ _Df,_Df,_Df,_Gf,_Gf,_Gf,_Gf,_Df ];

    global.anim_lib = {};

    global.anim_lib[$ "idle"] = {
        loop:true, length:120,
        kf:[
            { t:0.00, angles:[ 0,  0, 155, 165, 205, 195, 180, 180, 180, 180] },
            { t:0.50, angles:[ 2,  2, 153, 163, 207, 197, 182, 182, 182, 182] },
        ]
    };

    global.anim_lib[$ "run"] = {
        loop:true, length:36,
        kf:[
            { t:0.00, angles:[ 5,  3, 175, 178, 188, 183, 150, 163, 210, 196] },
            { t:0.25, angles:[ 2,  1, 155, 165, 205, 195, 180, 180, 180, 180] },
            { t:0.50, angles:[ 5,  3, 188, 183, 175, 178, 210, 196, 150, 163] },
            { t:0.75, angles:[ 2,  1, 155, 165, 205, 195, 180, 180, 180, 180] },
        ]
    };

    global.char_fk = function(anim_name, t) {
        var _parts  = global.char_parts;
        var _n      = array_length(_parts);
        var _result = array_create(_n, undefined);
        var _angles = array_create(_n, 0);
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
            for (var _i = 0; _i < _n; _i++) _angles[_i] = lerp(_k0.angles[_i], _k1.angles[_i], _f);
        } else {
            for (var _i = 0; _i < _n; _i++) _angles[_i] = _parts[_i].ang;
        }
        for (var _i = 0; _i < _n; _i++) {
            var _p = _parts[_i];
            var _piv_bx, _piv_bz;
            if (_p.parent == -1) { _piv_bx=0; _piv_bz=global.char_root_bz; }
            else {
                var _par = _result[_p.parent];
                _piv_bx = _par.end_bx + _p.pdx;
                _piv_bz = _par.end_bz + _p.pdz;
            }
            var _ar = degtorad(_angles[_i]);
            _result[_i] = {
                piv_bx:_piv_bx, piv_bz:_piv_bz,
                end_bx:_piv_bx+_p.len*sin(_ar),
                end_bz:_piv_bz+_p.len*cos(_ar),
                angle:_angles[_i]
            };
        }
        return _result;
    };

    global.anim_save = function() {
        var _f = file_text_open_write(working_directory+"char_animations.json");
        file_text_write_string(_f, json_stringify(global.anim_lib));
        file_text_close(_f);
    };

    global.anim_load = function() {
        var _path = working_directory+"char_animations.json";
        if (!file_exists(_path)) return;
        var _f = file_text_open_read(_path);
        var _s = ""; while (!file_text_eof(_f)) _s += file_text_readln(_f);
        file_text_close(_f);
        var _d = json_parse(_s);
        var _names = variable_struct_get_names(_d);
        for (var _i = 0; _i < array_length(_names); _i++)
            global.anim_lib[$ _names[_i]] = _d[$ _names[_i]];
    };

    global.anim_load();
}

var _anim_names = variable_struct_get_names(global.anim_lib);
if (array_length(_anim_names) > 0) ed_sel_anim = _anim_names[0];
else ed_sel_anim = "idle";
