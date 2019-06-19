#include "script_component.hpp"
/*
 * Author: mharis001
 * Checks if CPR can be performed on the patient.
 *
 * Arguments:
 * 0: Medic (not used) <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * Can CPR <BOOL>
 *
 * Example:
 * [player, cursorObject] call ace_medical_treatment_fnc_canCPR
 *
 * Public: No
 */

params ["", "_patient"];

!(_patient call EFUNC(common,isAwake)) && {!(_patient getVariable [QGVAR(isReceivingCPR), false])}