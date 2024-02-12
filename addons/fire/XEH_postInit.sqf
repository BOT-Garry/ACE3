#include "script_component.hpp"

[QGVAR(burn), LINKFUNC(burn)] call CBA_fnc_addEventHandler;
[QGVAR(burnEffects), LINKFUNC(burnEffects)] call CBA_fnc_addEventHandler;
[QGVAR(burnObjectEffects), LINKFUNC(burnObjectEffects)] call CBA_fnc_addEventHandler;
[QGVAR(burnSimulation), LINKFUNC(burnSimulation)] call CBA_fnc_addEventHandler;

// Only play sound if enabled in settings
[QGVAR(playScream), {
    if (!GVAR(enableScreams)) exitWith {};

    params ["_scream", "_source"];

    _source say3D _scream;
}] call CBA_fnc_addEventHandler;

if (!isServer) exitWith {};

["CBA_settingsInitialized", {
    TRACE_1("settingsInit",GVAR(enabled));

    if (!GVAR(enabled)) exitWith {};

    GVAR(fireSources) = createHashMap;

    [QGVAR(addFireSource), {
        params [
            ["_source", objNull, [objNull, []]],
            ["_radius", 0, [0]],
            ["_intensity", 0, [0]],
            ["_key", ""],
            ["_condition", {true}],
            ["_conditionArgs", []]
        ];

        private _isObject = _source isEqualType objNull;

        // Check if the source is valid
        if !(_isObject || {_source isEqualTypeParams [0, 0, 0]}) exitWith {};

        if (_isObject && {isNull _source}) exitWith {};
        if (_radius == 0 || _intensity == 0) exitWith {};
        if (_key isEqualTo "") exitWith {}; // key can be many types

        // If a position is passed, create a static object at said position
        private _sourcePos = if (_isObject) then {
            getPosATL _source
        } else {
            ASLToATL _source
        };

        private _fireLogic = createVehicle [QGVAR(logic), _sourcePos, [], 0, "CAN_COLLIDE"];

        // If an object was passed, attach logic to the object
        if (_isObject) then {
            _fireLogic attachTo [_source];
        };

        // hashValue supports more types than hashmaps do by default, but not all (e.g. locations)
        private _hashedKey = hashValue _key;

        if (isNil "_hashedKey") exitWith {
            ERROR_3("Unsupported key type used: %1 - %2 - %3",_key,typeName _key,typeOf _key);
        };

        // To avoid issues, remove existing entries first before overwriting
        if (_hashedKey in GVAR(fireSources)) then {
            [QGVAR(removeFireSource), _key] call CBA_fnc_localEvent;
        };

        GVAR(fireSources) set [_hashedKey, [_fireLogic, _radius, _intensity, _condition, _conditionArgs]];
    }] call CBA_fnc_addEventHandler;

    [QGVAR(removeFireSource), {
        params ["_key"];

        private _hashedKey = hashValue _key;

        if (isNil "_hashedKey") exitWith {
            ERROR_3("Unsupported key type used: %1 - %2 - %3",_key,typeName _key,typeOf _key);
        };

        (GVAR(fireSources) deleteAt _hashedKey) params [["_fireLogic", objNull]];

        detach _fireLogic;
        deleteVehicle _fireLogic;
    }] call CBA_fnc_addEventHandler;

    [LINKFUNC(fireManagerPFH), FIRE_MANAGER_PFH_DELAY, []] call CBA_fnc_addPerFrameHandler;
}] call CBA_fnc_addEventHandler;
