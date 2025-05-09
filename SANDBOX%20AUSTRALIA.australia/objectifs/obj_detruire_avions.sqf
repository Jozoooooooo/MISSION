// objectifs/obj_destruire_avions.sqf

// Liste des marqueurs pour les bases aériennes
_airbaseMarkers = ["airbase_pos"]; // Marqueur airbase_pos à utiliser
_pos = getMarkerPos selectRandom _airbaseMarkers; 
hint "Objectif : Détruisez tous les avions ennemis.";

// Afficher le marqueur et le message d'objectif
[_pos call BIS_fnc_nearestMarker, "Détruisez les avions ennemis"] execVM "scripts\afficherMarqueurMission.sqf";


// Créer des avions ennemis dans la zone
_planes = [
    "O_Plane_CAS_02_F", "O_Plane_Fighter_03_CAS_F", "O_Plane_Fighter_03_AA_F"
];

// Créer des avions ennemis et les faire décoller
{
    _plane = createVehicle [_x, _pos vectorAdd [random 300, random 300, 0], [], 0, "NONE"];
    _plane setPosATL [_pos select 0, _pos select 1, 500]; // Créer l'avion en hauteur
    _plane flyInHeight 150; // L'avion vole à une certaine hauteur
    _plane setVelocity [random 30, random 30, random 10]; // Donne à l'avion une trajectoire aléatoire

    createVehicleCrew _plane;
} forEach _planes;

// Ajout de renforts aériens après 3 minutes
[] spawn {
    sleep 180;
    private _reinforcePlane = createVehicle ["O_Plane_CAS_02_F", _pos vectorAdd [random 500, random 500, 0], [], 0, "NONE"];
    _reinforcePlane setPosATL [_pos select 0, _pos select 1, 500];
    _reinforcePlane flyInHeight 150;
    _reinforcePlane setVelocity [random 30, random 30, random 10];

    createVehicleCrew _reinforcePlane;
    hint "Renforts aériens ennemis arrivent !";
};

// Trigger de succès : tous les avions ennemis détruits
_triggerSuccess = createTrigger ["EmptyDetector", _pos];
_triggerSuccess setTriggerArea [500, 500, 0, false];
_triggerSuccess setTriggerActivation ["ANY", "PRESENT", true];
_triggerSuccess setTriggerStatements [
    "this && { count (allUnits select { side _x == east && alive _x && (typeOf _x isKindOf 'Air') }) == 0 }",
    "
        hint 'Tous les avions ennemis ont été détruits !';
        deleteMarker 'mission_zone';
        missionNamespace setVariable ['mission_terminee', true];
    ",
    ""
];
