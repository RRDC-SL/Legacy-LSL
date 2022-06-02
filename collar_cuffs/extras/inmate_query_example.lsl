// [SGD] RRDC Inmate Number Query Stub v1.2.1 - Copyright 2020 Alex Pascal (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================

// System Configuration Variables
// ---------------------------------------------------------------------------------------------------------
integer g_appChan     = -89039937;                              // The channel for this application set.
// ---------------------------------------------------------------------------------------------------------

// getAvChannel - Given an avatar key, returns a static channel XORed with g_appChan.
// ---------------------------------------------------------------------------------------------------------
integer getAvChannel(key av)
{
    return (0x80000000 | ((integer)("0x"+(string)av) ^ g_appChan));
}

default
{
    state_entry()
    {
        llSetMemoryLimit(llGetUsedMemory() + 1024);
        llListen(g_appChan, "", "", ""); // Listen on the appChan.
    }

    touch_start(integer num)
    {
        // Query sent using a range appropriate command on the user's av channel for collars as shown.
        // Syntax: inmatequery <user-key>
        llSay(getAvChannel(llDetectedKey(0)), "inmatequery " + (string)llDetectedKey(0));
    }

    listen(integer chan, string name, key id, string mesg)
    {
        // Reply Syntax: inmatereply <user-key> <inmate-number>|<inmate-name>
        list l = llParseString2List(mesg, [" "], []);
        if (llToLower(llList2String(l, 0)) == "inmatereply" && // Verify message is genuine reply.
            llList2String(l, 1) == (string)llGetOwnerKey(id))
        {
            // Do something with the response.
            // A response of 00000 means the user hasn't set up the collar yet or isn't in the system.
            llSay(0, llList2String(l, 3) + " (" + llKey2Name(llGetOwnerKey(id)) + 
                ")'s inmate number is " + llList2String(l, 2));
        }
    }
}
