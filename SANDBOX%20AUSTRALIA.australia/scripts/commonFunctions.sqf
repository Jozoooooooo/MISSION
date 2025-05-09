// Renvoie un marqueur aléatoire correspondant à un type donné
fnc_getRandomMarker = {
    params ["_prefix"];
    private _markers = allMapMarkers select { _x find _prefix == 0 };
    private _chosen = selectRandom _markers;
    getMarkerPos _chosen
};
