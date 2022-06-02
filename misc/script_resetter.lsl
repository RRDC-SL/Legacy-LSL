// [SGD] RRDC Role-Locked Script Resetter - Copyright 2020 Alex Pascal (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// Instructions:
//    1. Place script into the prim where the scripts to reset are. (only need to do this once)
//    2. Make sure the object's group is set to RRDC Estate.
//    3. Be the owner of the object or wear your RRDC Admin group tag.
//    4. Type in local chat: /77fixme
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================

// tagCheck - Given an avatar key, returns TRUE if they have one of the group tags listed in allowedTags
//             active. Note the prim this script is in must be set to the group that contains the tags.
// ---------------------------------------------------------------------------------------------------------
integer tagCheck(key av)
{
    list allowedTags = ["RRDC Admin"];
    integer found = llListFindList(allowedTags, 
        [llList2String(llGetObjectDetails(av, ([OBJECT_GROUP_TAG])), 0)]
    );
    return (llSameGroup(av) && found > -1);
}

default
{
    state_entry()
    {
        llSetMemoryLimit(llGetUsedMemory() + 512);
        llListen(77, "", "", "fixme");
    }

    listen(integer chan, string name, key id, string mesg)
    {   
        if (llGetOwnerKey(id) == id) // Sender is an avatar?
        {
            if (id == llGetOwner() || tagCheck(id)) // Allowed to reset?
            {
                for (chan = 0; chan < llGetInventoryNumber(INVENTORY_SCRIPT); chan++)
                {
                    name = llGetInventoryName(INVENTORY_SCRIPT, chan);

                    if (name != llGetScriptName())
                    {
                        llResetOtherScript(name);
                    }
                }

                llSleep(1.0);
                llWhisper(0, "Scripts in this object have been reset.");
                llSleep(0.5);
                llResetScript();
            }
            else
            {
                llWhisper(0, "Only admins can run 'fixme' (check your group tag).");
            }
        }
    }
}