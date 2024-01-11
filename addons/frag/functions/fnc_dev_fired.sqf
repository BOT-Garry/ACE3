#include "..\script_component.hpp"
/*
 * Author: Lambda.Tiger
 * Add fired rounds to dev track.
 * 
 * Arguments:
 * None. Parameters inherited from EFUNC(common,firedEH)
 *
 * Return Value:
 * None
 *
 * Example:
 * [clientFiredBIS-XEH] call ace_frag_fnc_fired
 *
 * Public: No
 */

[_projectile, true, ((side _unit) getFriend (side ACE_player)) >= 0.6] call FUNC(dev_addRound);