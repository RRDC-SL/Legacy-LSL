// [SGD] RRDC Jumpsuit Mini-HUD - HUD v1.0 - Copyright 2021 Sasha Wyrding (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================
integer g_appChan     = -78398383;              // The channel for this application set.
integer g_hideCrotch  = FALSE;                  // If TRUE, hide the jumpsuit crotch.

// getAvChannel - Given an avatar key, returns a static channel XORed with g_appChan.
// ---------------------------------------------------------------------------------------------------------
integer getAvChannel(key av)
{
    return (0x80000000 | ((integer)("0x"+(string)av) ^ g_appChan));
}

setCrotchState()
{
    llWhisper(getAvChannel(llGetOwner()),
        "JUMPSUIT_CROTCH_" + llList2String(["SHOW", "HIDE"], g_hideCrotch));
    llSetLinkPrimitiveParamsFast(LINK_THIS, [
        PRIM_TEXTURE, ALL_SIDES, "9ba301a6-4d73-c7e8-d09c-617f3ea3b2c8", <1.0, 1.0, 0.0>,
        <0.0, (0.5 * g_hideCrotch), 0.0>, 0.0
    ]);
}

default
{
    state_entry()
    {
        llSetMemoryLimit(llGetUsedMemory() + 1024);
        setCrotchState();
    }

    on_rez(integer start)
    {
        llSetTimerEvent(5.0);
    }

    timer()
    {
        llSetTimerEvent(0.0);
        setCrotchState();
    }

    touch_start(integer num)
    {
        llPlaySound("d57b8592-b9d7-be1b-25ea-35fcbe4d9070", 1.0);
        g_hideCrotch = !g_hideCrotch;
        setCrotchState();
    }
}
