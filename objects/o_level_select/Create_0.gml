/// Level selector - displayed before level editor

available_levels = scan_level_files();
selected_idx = 0;
scroll_offset = 0;

load_and_edit = function(_filename) {
    // Store the level to load in a global variable
    global.level_to_load = _filename;
    // Go to level editor (assuming it's the r_level_editor room)
    room_goto(r_level_editor);
};
