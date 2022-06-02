// [SGD] RRDC Group Tag Role-Lock Example v1.0 - Copyright 2020 Alex Pascal (Alex Carpenter) @ Second Life.
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
    list allowedTags = ["Red Rock Engineer", "Red Rock Guard", "Red Rock Trustee"];
    integer found = llListFindList(allowedTags, 
        [llList2String(llGetObjectDetails(av, ([OBJECT_GROUP_TAG])), 0)]
    );
    return (llSameGroup(av) && found > -1);
}

default
{
    touch_start(integer total_number)
    {
        if (tagCheck(llDetectedKey(0))) // Toucher has one of the allowed tags active?
        {
            llSay(0, "You have an allowed group tag active.");
        }
        else
        {
            llSay(0, "You DO NOT have an allowed group tag active.");
        }
    }
}
