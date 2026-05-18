/// Scan datafiles folder for JSON level files
function scan_level_files() {
    var _levels = [];

    // Try to find JSON files in datafiles folder
    var _handle = file_find_first("*.json", 0);

    while (_handle != "") {
        if (string_length(_handle) > 5) {
            array_push(_levels, _handle);
        }
        _handle = file_find_next();
    }

    file_find_close();

    // Sort alphabetically
    array_sort(_levels, false);

    return _levels;
}
