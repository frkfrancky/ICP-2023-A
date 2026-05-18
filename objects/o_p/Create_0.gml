//is_bot = false;
//reaction = 0;
//is_react = false;
is_me = false;
depth = -1

//refa bot namana
dest_x = 0;
dest_y = 0;
point_tt = 0;//point de destination coorespondant

//IA : pause et vitesse variable
is_idle    = false;
c_idle     = 0;
count_idle = 0;   // durée d'attente (tirage aléatoire à chaque arrivée)
sp_bot     = 2;   // vitesse cible courante du bot (recalculée à chaque déplacement)

dir = 0;
acc = 0.09;//acceleration


//attente avant action
mbol = false;
miandry = false;
miandry_passe = false;

fanina = false;
count_fanina = 200;
c_f = 0;

can_act = true;
count_act = 60;
c_a = 0;

can_pass = true;
c_p = 0;
count_pass = 60;

can_act1 = true;
c_a1 = 0;
count_act1 = 20;
///////////////////////

ekipa = 1;
index = -1;
akaiky = false;
//poste = 0;


//touche initiallise any am controller
key_direction = 0;
key_action = 0;

//PARAM DU JOUEUR
sp = 20/20*2;//speed
tec = 20; //technique ou drible
alavany = 120;

limiteur_speed = 0;
image_speed = 0;
image_alpha = 0.9;

afficheo = "";

//point de match
pt3s = true;
last_3pt = pt3s;


//3d ///////////////////
var _spr_init = (ekipa == 1) ? base1 : base2;
textureTop = sprite_get_texture(_spr_init, 0);
z        = -10;
z_ground = -10;
jump_vz    = 0;
is_jumping = false;

// Jauge tir / passe (maintenir bouton pour charger)
jauge_tir         = 0;
jauge_passe       = 0;
is_charging_tir   = false;
is_charging_passe = false;
fire_tir          = false;
fire_passe        = false;

// Stat précision tir (0-100)
precision = 80;

// Multiplicateur de puissance de passe (futur stat joueur, 1 = défaut)
passe_power = 1;

// Cooldown IA steal indépendant
c_ia_steal     = 0;
count_ia_steal = 160;  // plus long = moins agressif

// Délai de réaction IA (évite la précision instantanée)
ia_react_timer = 0;
ia_react_delay = irandom_range(8, 22);

// Pre-move : programmé PENDANT que j'ai le ballon (brief press)
pm_action   = -1;   // -1=none, 0=passe, 1=tir
pm_jauge    = 0;
pm_target   = -1;   // receveur ciblé
hold_act1_c = 0;    // compteur de frames bouton act1 maintenu
hold_act2_c = 0;    // compteur de frames bouton act2 maintenu

//touche
up = false;
down = false;
right = false;
left = false;

//run = false;
act1 = false;
act2 = false;

haxis = 0;
vaxis = 0;


// === ANIMATION STATE ===
anim_current = "idle";
anim_time    = 0.0;

// === INIT SQUELETTE (une seule fois pour tous les joueurs) ===
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

    // frame : 0=face(dir90) 1=NW 2=W(côtéD) 3=SW 4=dos(dir270) 5=SE 6=E(côtéG) 7=NE
    var _F_front = [8,9,6,7, 0, 4,5,2,3, 1]; // face : tête devant
    var _F_back  = [1, 2,3,4,5, 0, 6,7,8,9]; // dos  : tête derrière
    var _D_front = [4,5,8,9, 0, 1, 2,3,6,7]; // côté D : tête entre corps et bras D
    var _G_front = [2,3,6,7, 0, 1, 4,5,8,9]; // côté G : tête entre corps et bras G
    global.char_layer_order = [_F_front,_D_front,_D_front,_D_front,_F_back,_G_front,_G_front,_G_front];

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

    global.anim_save = function() {
        var _f = file_text_open_write(working_directory + "char_animations.json");
        file_text_write_string(_f, json_stringify(global.anim_lib));
        file_text_close(_f);
    };
    global.anim_load = function() {
        var _path = working_directory + "char_animations.json";
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

// Toujours réinitialiser char_fk avec la version 3D complète + root_z + ball
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
                var _da  = ((_k1.angles[_i]  - _k0.angles[_i]  + 540) mod 360) - 180;
                var _dal = ((_lat1[_i]        - _lat0[_i]        + 540) mod 360) - 180;
                _angles[_i]     = _k0.angles[_i]  + _da  * _f;
                _angles_lat[_i] = _lat0[_i]        + _dal * _f;
            }
            _root_z = lerp(
                variable_struct_exists(_k0,"root_z") ? _k0.root_z : 0,
                variable_struct_exists(_k1,"root_z") ? _k1.root_z : 0, _f);
            var _b0 = variable_struct_exists(_k0,"ball") ? _k0.ball : {bx:5,by:10,bz:30};
            var _b1 = variable_struct_exists(_k1,"ball") ? _k1.ball : {bx:5,by:10,bz:30};
            _ball_bx = lerp(_b0.bx, _b1.bx, _f);
            _ball_by = lerp(_b0.by, _b1.by, _f);
            _ball_bz = lerp(_b0.bz, _b1.bz, _f);
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
                angle : _angles[_i], angle_lat : _angles_lat[_i]
            };
        }
        _result[10] = { bx : _ball_bx, by : _ball_by, bz : _ball_bz + _root_z };
        return _result;
    };
}

// Variables ballon animé (mises à jour dans Draw_0 chaque frame)
anim_ball_wx = 0; anim_ball_wy = 0; anim_ball_wz = 0;

//TEST SMF ENGINE ////////////

