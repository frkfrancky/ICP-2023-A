/// @function spawn_level_objects(level_data)
/// @description Crée les objets du match à partir des données du niveau
/// @param {array} level_data - Array d'objets de niveau chargés

function spawn_level_objects(_level_data) {
    var _spawned = [];

    for (var _i = 0; _i < array_length(_level_data); _i++) {
        var _o = _level_data[_i];

        switch (_o.type) {
            case "mesh":
            case "cube":
                // Créer un objet de collision/obstacle
                // TODO: Créer une entité collision ou utiliser un objet existant
                break;

            case "light":
                // Créer une lumière ponctuelle
                // Ces propriétés peuvent être lues par le shader
                // intensity et range sont déjà dans _o
                array_push(_spawned, _o);
                break;

            case "terrain":
                // Terrain de jeu - généralement unique
                // Cette donnée configure le terrain principal
                array_push(_spawned, _o);
                break;

            case "char":
                // Personnage/joueur
                // Position et rotation depuis _o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz
                array_push(_spawned, _o);
                break;
        }
    }

    return _spawned;
}
