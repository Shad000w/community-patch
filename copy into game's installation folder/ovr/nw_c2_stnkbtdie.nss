//::///////////////////////////////////////////////
//:: Stink Beetle OnDeath Event
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Releases the Stink Beetle's Stinking Cloud
    special ability OnDeath.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew
//:: Created On: Jan 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- script will additionally run default OnDeath script handler for npcs
*/

void main()
{
    //Declare major variables
    effect eAOE = EffectAreaOfEffect(AOE_MOB_TYRANT_FOG,"NW_S1_Stink_A");
    location lTarget = GetLocation(OBJECT_SELF);

    //Create the AOE object at the selected location
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, lTarget, RoundsToSeconds(2));

    //1.72: checking this is neccessary in order to avoid endless loop that would lock down game
    //in a case where user would already do this but the other way around, ie. executing this
    //script from nw_c2_default7
    if(GetEventScript(OBJECT_SELF,EVENT_SCRIPT_CREATURE_ON_DEATH) == "nw_c2_stnkbtdie")
    {
        ExecuteScript(GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_NONE ? "nw_c2_default7" : "nw_ch_ac7",OBJECT_SELF);
    }
}
