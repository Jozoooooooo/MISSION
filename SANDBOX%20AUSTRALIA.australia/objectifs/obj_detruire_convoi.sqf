// objectifs/obj_detruire_convoi.sqf

// Liste des marqueurs représentant les points du chemin du convoi
_pathMarkers = [];
{
    if (markerText _x find "convoy_path" != -1) then {
        _pathMarkers pushBack _x;
    };
} forEach allMapMarkers;

_pathMarkers sort true; // Pour suivre l'ordre (convoy_path1, convoy_path2...)

// Vérification
if (count _pathMarkers < 2) exitWith {
    hint "Erreur : il faut au moins deux marqueurs 'convoy_pathX' pour cette mission.";
    missionNamespace setVariable ["mission_terminee", true];
};

// Afficher le marqueur et le message d'objectif
[_pos call BIS_fnc_nearestMarker, "Attaquez le convoi"] execVM "scripts\afficherMarqueurMission.sqf";


// Création du convoi
_convoy = [];

// Types de véhicules du convoi
_vehicleTypes = [
    "O_Truck_03_transport_F",
    "O_Truck_03_covered_F",
    "O_MRAP_02_hmg_F"
];

_startPos = getMarkerPos (_pathMarkers select 0);

// Générer les véhicules et équipages
{
    private _veh = createVehicle [_x, _startPos, [], 5, "NONE"];
    private _crew = createVehicleCrew _veh;
    _convoy pushBack _veh;
    sleep 0.3;
} forEach _vehicleTypes;

// Donner une route aux véhicules
{
    _veh = _convoy select _forEachIndex;
    {
        _veh addWaypoint [getMarkerPos _x, 0];
    } forEach _pathMarkers;
    _veh setConvoySeparation 20;
} forEach _convoy;

// Renforts après 90 secondes
[] spawn {
    sleep 90;
    private _reinforceGrp = [getPos player, east, [
        "O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"
    ]] call BIS_fnc_spawnGroup;

    private _target = (_convoy select 0);
    if (!isNull _target) then {
        _reinforceGrp move position _target;
    };
    { _x setSkill 0.7 } forEach units _reinforceGrp;
    hint "Renforts ennemis en approche !";
};

// Trigger de fin : tous les véhicules détruits
[] spawn {
    waitUntil {
        sleep 5;
        { alive _x } count _convoy == 0
    };
    hint "Convoi détruit avec succès !";
    deleteMarker 'mission_zone';
    missionNamespace setVariable ["mission_terminee", true];
};
