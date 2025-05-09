// objectifs/obj_detruire_tour.sqf

// Obtenir une position aléatoire parmi les marqueurs "comms_posX"
_pos = ["comms_pos"] call fnc_getRandomMarker;

// Créer la tour de communication
_tour = createVehicle ["Land_TTowerBig_1_F", _pos, [], 0, "NONE"];
_tour allowDamage true;

// Créer l'infanterie ennemie
_grp = createGroup east;
_units = [
    "O_Soldier_SL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F",
    "O_Soldier_F", "O_Medic_F"
];
{
    _unit = _grp createUnit [_x, _pos, [], 5, "NONE"];
    _unit setSkill 0.6;
} forEach _units;

// Créer un véhicule ennemi
_veh = createVehicle ["O_MRAP_02_hmg_F", _pos vectorAdd [20,0,0], [], 0, "NONE"];
_crew = createVehicleCrew _veh;
{ _x joinSilent _grp } forEach _crew;

// Optionnel : créer un hélico de patrouille
if (random 1 < 0.5) then {
    _heli = createVehicle ["O_Heli_Light_02_unarmed_F", _pos vectorAdd [50,0,0], [], 0, "FLY"];
    _heli flyInHeight 60;
    _heliGrp = createGroup east;
    _crew = createVehicleCrew _heli;
    { _x joinSilent _heliGrp } forEach _crew;
};

// Prévoir un renfort après 2 minutes
[] spawn {
    sleep 120;
    _reinforcePos = _pos vectorAdd [150 + random 100, 150 + random 100, 0];
    _reinforceGrp = [getPos player, east, ["O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"]] call BIS_fnc_spawnGroup;
    _reinforceGrp move _pos;
    { _x setSkill 0.6 } forEach units _reinforceGrp;
    hint "Renforts ennemis détectés !";
};

// Créer un trigger pour valider la destruction de la tour
_trigger = createTrigger ["EmptyDetector", position _tour];
_trigger setTriggerArea [5, 5, 0, false];
_trigger setTriggerActivation ["ANY", "PRESENT", true];
_trigger setTriggerStatements [
    "!(alive _tour)",
    "
        hint 'Tour de communication détruite !';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];
