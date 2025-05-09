// objectifs/obj_recuperer_otage.sqf

// Position aléatoire via marqueur
_pos = ["hostage_pos"] call fnc_getRandomMarker;

// Bâtiment factice pour immersion
_house = createVehicle ["Land_i_House_Small_03_V1_F", _pos, [], 0, "NONE"];

// Créer l'otage
_otage = createUnit ["C_man_polo_4_F", _pos vectorAdd [2,0,0], [], 0, "NONE"];
_otage disableAI "MOVE";
_otage setCaptive true;
_otage setName "Otage";
_otage allowDamage false;

// Groupe ennemi autour
_grp = createGroup east;
_units = [
    "O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"
];
{
    _unit = _grp createUnit [_x, _pos vectorAdd [random 10, random 10, 0], [], 3, "NONE"];
    _unit setSkill 0.6;
} forEach _units;

// Véhicule de garde
_veh = createVehicle ["O_MRAP_02_F", _pos vectorAdd [10,5,0], [], 0, "NONE"];
_crew = createVehicleCrew _veh;
{ _x joinSilent _grp } forEach _crew;

// Débloquer l'otage quand il est approché
_otageLiberation = createTrigger ["EmptyDetector", position _otage];
_otageLiberation setTriggerArea [5, 5, 0, false];
_otageLiberation setTriggerActivation ["ANY", "PRESENT", true];
_otageLiberation setTriggerStatements [
    "player distance _otage < 5",
    "
        hint 'Otage libéré, ramenez-le à la base !';
        _otage enableAI 'MOVE';
        _otage setCaptive false;
        [_otage] joinSilent group player;
        _otage allowDamage true;
    ",
    ""
];

// Renfort après 90 secondes
[] spawn {
    sleep 90;
    _reinforcePos = _pos vectorAdd [150 + random 100, 150 + random 100, 0];
    _reinforceGrp = [getPos player, east, ["O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"]] call BIS_fnc_spawnGroup;
    _reinforceGrp move _pos;
    { _x setSkill 0.6 } forEach units _reinforceGrp;
    hint "Renforts ennemis en route !";
};

// Trigger de succès si l’otage est ramené vivant
_basePos = getMarkerPos "respawn_west";

_triggerSuccess = createTrigger ["EmptyDetector", _basePos];
_triggerSuccess setTriggerArea [10, 10, 0, false];
_triggerSuccess setTriggerActivation ["ANY", "PRESENT", true];
_triggerSuccess setTriggerStatements [
    "alive _otage && _otage distance _basePos < 10",
    "
        hint 'Otage ramené avec succès !';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];
// Échec de la mission si l'otage meurt
_triggerFail = createTrigger ["EmptyDetector", position _otage];
_triggerFail setTriggerArea [0, 0, 0, false];
_triggerFail setTriggerActivation ["ANY", "PRESENT", true];
_triggerFail setTriggerStatements [
    "!alive _otage",
    "
        hint 'Échec : l’otage a été tué !';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];