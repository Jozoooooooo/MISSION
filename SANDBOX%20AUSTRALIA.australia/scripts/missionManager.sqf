waitUntil { time > 1 }; // attendre le démarrage complet

_missions = [
    "obj_detruire_tour",
    "obj_recuperer_otage",
    "obj_reprendre_ville",
    "obj_detruire_convoi",
    "obj_recuperer_renseignement",
    "obj_camp_ennemi",
    "obj_detruire_avions"
];

while {true} do {
    _mission = selectRandom _missions;
    diag_log format ["[MissionManager] Chargement de la mission : %1", _mission];

    call compile preprocessFileLineNumbers format ["objectifs\%1.sqf", _mission];

    waitUntil { missionNamespace getVariable ["mission_terminee", false] };
    missionNamespace setVariable ["mission_terminee", false];

    hint "Mission terminée. Nouvelle mission dans 30 secondes.";
    sleep 30;
};
