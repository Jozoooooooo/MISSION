/*
    afficherMarqueurMission.sqf
    Affiche un marqueur et un message pour indiquer la position d'une mission

    Paramètres :
    0 : STRING - nom du marqueur utilisé comme base (position de la mission)
    1 : STRING - texte à afficher sur le marqueur
    2 : ARRAY  - taille du marqueur [x, y] (optionnel, par défaut [300, 300])
    3 : STRING - couleur du marqueur (optionnel, par défaut "ColorRed")
*/

params ["_nomMarqueur", "_texte", ["_taille", [300, 300]], ["_couleur", "ColorRed"]];

// Supprimer ancien marqueur s'il existe
if (markerExists "mission_zone") then { deleteMarker "mission_zone"; };

// Créer nouveau marqueur
private _pos = getMarkerPos _nomMarqueur;
private _m = createMarker ["mission_zone", _pos];
_m setMarkerShape "ELLIPSE";
_m setMarkerSize _taille;
_m setMarkerColor _couleur;
_m setMarkerAlpha 0.6;
_m setMarkerText _texte;

// Affichage d'un message
["Nouvel objectif", _texte] call BIS_fnc_showNotification;
