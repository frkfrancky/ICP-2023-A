/// Match Setup - Charge le niveau et initialise la scène

// Variable de contrôle
level_loaded = false;
level_objects = [];
level_file = "";

// Level selection UI
available_levels = scan_level_files();
current_level_idx = -1;
level_selector_open = true;

// Fonction de chargement du niveau
load_level_from_file = function(_filename) {
    level_objects = level_loader(_filename);
    level_file = _filename;
    level_loaded = true;
    level_selector_open = false;
};

// Si on a des niveaux disponibles, charger le premier par défaut
if (array_length(available_levels) > 0) {
    // Chercher "niveau.json" dans la liste
    var _found = false;
    for (var _i = 0; _i < array_length(available_levels); _i++) {
        if (available_levels[_i] == "niveau.json") {
            current_level_idx = _i;
            load_level_from_file("niveau.json");
            _found = true;
            break;
        }
    }

    // Sinon charger le premier niveau disponible
    if (!_found && array_length(available_levels) > 0) {
        current_level_idx = 0;
        load_level_from_file(available_levels[0]);
    }
}
