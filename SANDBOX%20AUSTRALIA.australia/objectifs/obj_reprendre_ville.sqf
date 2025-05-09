// objectifs/obj_reprendre_ville.sqf

// Sélection de la position
_pos = ["city_pos"] call fnc_getRandomMarker;

hint "Objectif : Reprenez le contrôle de la ville ennemie.";

// Nombre de groupes ennemis à créer
_groupCount = 3;
_groupRadius = 100;

// Créer les groupes ennemis
for "_i" from 1 to _groupCount do {
    private _grp = [getPos player, east, [
        "O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F",
        "O_Soldier_GL_F", "O_Soldier_F"
    ]] call BIS_fnc_spawnGroup;

    private _offset = [
        (_groupRadius * cos (_i * 120)), 
        (_groupRadius * sin (_i * 120)), 
        0
    ];
    private _spawnPos = _pos vectorAdd _offset;

    _grp setFormDir (random 360);
    _grp setFormation "LINE";
    _grp move _spawnPos;
    { _x setSkill 0.6 } forEach units _grp;

    // Petit délai entre les spawns
    sleep 0.5;
}

// Véhicules ennemis
_veh1 = createVehicle ["O_MRAP_02_hmg_F", _pos vectorAdd [30,20,0], [], 0, "NONE"];
_veh2 = createVehicle ["O_APC_Wheeled_02_rcws_v2_F", _pos vectorAdd [-40,-30,0], [], 0, "NONE"];
createVehicleCrew _veh1;
createVehicleCrew _veh2;

// Hélicoptère de patrouille (optionnel)
if (random 1 < 0.5) then {
    _heli = createVehicle ["O_Heli_Light_02_dynamicLoadout_F", _pos vectorAdd [50,0,0], [], 0, "FLY"];
    _heli flyInHeight 80;
    _crew = createVehicleCrew _heli;
};

// Renforts ennemis après 2 minutes
[] spawn {
    sleep 120;
    private _reinforceGrp = [getPos player, east, [
        "O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"
    ]] call BIS_fnc_spawnGroup;

    _reinforceGrp move _pos;
    { _x setSkill 0.7 } forEach units _reinforceGrp;
    hint "Des renforts ennemis arrivent !";
};

// Trigger de succès : aucun ennemi à proximité + présence de joueur
_trigger = createTrigger ["EmptyDetector", _pos];
_trigger setTriggerArea [100, 100, 0, false];
_trigger setTriggerActivation ["WEST", "PRESENT", true];
_trigger setTriggerStatements [
    "this && { count (allUnits select { side _x == east && _x distance _pos < 120 && alive _x }) == 0 }",
    "
        hint 'Ville sécurisée !';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];
