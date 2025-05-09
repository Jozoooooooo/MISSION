// objectifs/obj_attaquer_camp.sqf

// Sélection d'une position aléatoire pour le camp
_pos = ["camp_pos"] call fnc_getRandomMarker;
hint "Objectif : Attaquez et détruisez le camp ennemi.";

// Créer un camp avec des unités ennemies et des véhicules
_campSize = 5; // Nombre de groupes ennemis
_vehicles = [
    "O_Truck_03_transport_F", "O_Truck_03_covered_F", "O_MRAP_02_hmg_F"
];

// Créer les groupes ennemis
_campUnits = [];
for "_i" from 1 to _campSize do {
    private _group = [getPos player, east, [
        "O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"
    ]] call BIS_fnc_spawnGroup;

    private _offset = [
        (_i * 50), 
        (_i * 50), 
        0
    ];
    private _spawnPos = _pos vectorAdd _offset;

    _group setFormDir (random 360);
    _group setFormation "LINE";
    _group move _spawnPos;
    { _x setSkill 0.6 } forEach units _group;
    _campUnits pushBack _group;

    sleep 0.5;
};

// Créer des véhicules et des tourelles
_veh1 = createVehicle ["O_MRAP_02_hmg_F", _pos vectorAdd [30,20,0], [], 0, "NONE"];
_veh2 = createVehicle ["O_APC_Wheeled_02_rcws_v2_F", _pos vectorAdd [-40,-30,0], [], 0, "NONE"];
createVehicleCrew _veh1;
createVehicleCrew _veh2;

// Ajouter des tourelles ou des structures de camp
createVehicle ["Land_TTowerWooden_F", _pos vectorAdd [10,10,0], [], 0, "NONE"];
createVehicle ["Land_TTowerWooden_F", _pos vectorAdd [-10,-10,0], [], 0, "NONE"];

// Renforts ennemis après 2 minutes
[] spawn {
    sleep 120;
    private _reinforceGrp = [getPos player, east, [
        "O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"
    ]] call BIS_fnc_spawnGroup;

    private _target = (_veh1);
    if (!isNull _target) then {
        _reinforceGrp move position _target;
    };
    { _x setSkill 0.7 } forEach units _reinforceGrp;
    hint "Renforts ennemis arrivent !";
};

// Trigger de succès : aucun ennemi dans la zone
_triggerSuccess = createTrigger ["EmptyDetector", _pos];
_triggerSuccess setTriggerArea [100, 100, 0, false];
_triggerSuccess setTriggerActivation ["ANY", "PRESENT", true];
_triggerSuccess setTriggerStatements [
    "this && { count (allUnits select { side _x == east && _x distance _pos < 120 && alive _x }) == 0 }",
    "
        hint 'Camp détruit !';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];
