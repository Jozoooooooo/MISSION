// objectifs/obj_recuperer_renseignement.sqf

// Sélection de la position aléatoire
_pos = ["intel_pos"] call fnc_getRandomMarker;
hint "Objectif : Récupérez le renseignement et retournez à la base.";

// Créer le document (représenté par une caisse)
_document = createVehicle ["Land_AmmoBox_01_F", _pos, [], 0, "NONE"];
_document setPos [_pos select 0, _pos select 1, 0];

// Créer les ennemis à proximité
_grp = createGroup east;
_units = [
    "O_Soldier_TL_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_Soldier_F"
];
{
    _unit = _grp createUnit [_x, _pos vectorAdd [random 10, random 10, 0], [], 3, "NONE"];
    _unit setSkill 0.6;
} forEach _units;

// Véhicules ennemis (surtout pour la protection du site)
_veh1 = createVehicle ["O_MRAP_02_hmg_F", _pos vectorAdd [10,10,0], [], 0, "NONE"];
_veh2 = createVehicle ["O_APC_Wheeled_02_rcws_v2_F", _pos vectorAdd [-20,-10,0], [], 0, "NONE"];
createVehicleCrew _veh1;
createVehicleCrew _veh2;

// Préparer l'agent pour récupérer l'objet
documentMarker = _document addAction [
    "Récupérer le renseignement",
    {
        _this select 0 setVariable ["intel_taken", true];
        hint "Renseignement récupéré !";
        _this select 0 hideObject true;
    },
    nil,
    1,
    false,
    true
];

// Renforts ennemis après 90 secondes
[] spawn {
    sleep 90;
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

// Trigger de succès : l'agent revient avec l'objet
_basePos = getMarkerPos "respawn_west";
_triggerSuccess = createTrigger ["EmptyDetector", _basePos];
_triggerSuccess setTriggerArea [10, 10, 0, false];
_triggerSuccess setTriggerActivation ["ANY", "PRESENT", true];
_triggerSuccess setTriggerStatements [
    "!(alive _document) && (alive player) && { player distance _basePos < 10 }",
    "
        hint 'Renseignement livré à la base !';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];

// Trigger d'échec : l'agent est tué après avoir récupéré le renseignement
_triggerFail = createTrigger ["EmptyDetector", position player];
_triggerFail setTriggerArea [10, 10, 0, false];
_triggerFail setTriggerActivation ["ANY", "PRESENT", true];
_triggerFail setTriggerStatements [
    "!(alive player) && (if (missionNamespace getVariable ['intel_taken', false]) then {true} else {false})",
    "
        hint 'Échec : agent tué après avoir récupéré le renseignement !';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];
