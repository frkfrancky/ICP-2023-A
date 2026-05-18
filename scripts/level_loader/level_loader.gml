/// @function level_loader(filename)
/// @description Charge un niveau sauvegardé depuis JSON dans le dossier datafiles
/// @param {string} filename - Nom du fichier JSON (ex: "niveau.json")
/// @return {array} Array d'objets créés

function level_loader(_filename) {
    if (!file_exists(_filename)) {
        show_error("Fichier niveau non trouvé: " + _filename, true);
        return [];
    }

    // Lire le fichier texte
    var _f = file_text_open_read(_filename);
    var _json_str = "";
    while (!file_text_eof(_f)) {
        _json_str += file_text_readln(_f);
    }
    file_text_close(_f);

    // Parser le JSON
    var _sdata = json_parse(_json_str);

    var _result = [];

    // Parcourir les objets chargés directement par index
    for (var _i = 0; _i < 100; _i++) {
        var _key = "obj_" + string(_i);

        // Vérifier si la clé existe dans la struct
        if (!variable_struct_exists(_sdata, _key)) continue;

        var _obj = _sdata[$ _key];
        if (is_undefined(_obj)) continue;

        // Créer un struct avec toutes les propriétés
        var _o = {
            type: _obj.type,
            name: _obj.name,
            x: _obj.x, y: _obj.y, z: _obj.z,
            rx: _obj.rx, ry: _obj.ry, rz: _obj.rz,
            sx: _obj.sx, sy: _obj.sy, sz: _obj.sz,
            col: _obj.col,
            vb: -1
        };

        // Créer vertex buffers pour les objets rendus
        if (_obj.type == "mesh") {
            var _scale = max(_obj.sx, max(_obj.sy, _obj.sz));
            _o.vb = create_cube_vb(_scale * 50);
            if (variable_struct_exists(_obj, "tex_spr")) _o.tex_spr = _obj.tex_spr;
        }

        if (_obj.type == "terrain") {
            _o.vb = create_terrain_vb(_obj.sx * 200, _obj.sy * 200);
        }

        if (_obj.type == "char") {
            _o.vb = create_character_vb(_obj.sx * 30, _obj.sz * 80);
        }

        // Propriétés optionnelles pour lumières
        if (_obj.type == "light") {
            if (variable_struct_exists(_obj, "intensity")) _o.intensity = _obj.intensity;
            if (variable_struct_exists(_obj, "range")) _o.range = _obj.range;
        }

        array_push(_result, _o);
    }

    return _result;
}
