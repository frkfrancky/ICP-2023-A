/// Level selector - displayed before level editor

available_levels = scan_level_files();
selected_idx = 0;
scroll_offset = 0;

load_and_edit = function(_filename) {
    if (_filename == "") {
        // Nouveau niveau - ne pas charger de fichier
        global.level_to_load = undefined;
    } else {
        // Store the level to load in a global variable
        global.level_to_load = _filename;
    }
    // Go to level editor
    room_goto(r_level_editor);
};

load_and_play = function(_filename) {
    if (_filename == "") {
        // Nouveau niveau - ne pas charger de fichier
        global.level_to_load = undefined;
    } else {
        // Store the level to load in a global variable
        global.level_to_load = _filename;
    }
    // Go to match game room
    room_goto(r_match_game);
};
