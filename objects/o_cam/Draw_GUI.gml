/// Debug: afficher les positions des objets chargés

if (instance_exists(o_match_setup)) {
    var _objs = o_match_setup.level_objects;

    draw_set_color(c_white);
    draw_text(10, 700, "Objets chargés: " + string(array_length(_objs)));
    for (var _i = 0; _i < array_length(_objs) && _i < 5; _i++) {
        var _o = _objs[_i];
        draw_text(10, 720 + _i*15, _i + ": " + _o.type + " (" + string(_o.x) + "," + string(_o.y) + ")");
    }
}
