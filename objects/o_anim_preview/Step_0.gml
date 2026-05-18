// Rotation du personnage avec flèches
if (keyboard_check(vk_left))  dir = (dir - rot_speed + 360) mod 360;
if (keyboard_check(vk_right)) dir = (dir + rot_speed) mod 360;

// Sync animation avec l'éditeur
if (instance_exists(o_anim_editor)) {
    anim_current = o_anim_editor.ed_sel_anim;
}

// Avancer le temps
if (variable_global_exists("char_fk") && variable_struct_exists(global.anim_lib, anim_current)) {
    var _len = global.anim_lib[$ anim_current].length;
    anim_time = (anim_time + 1.0 / _len) mod 1.0;
}
