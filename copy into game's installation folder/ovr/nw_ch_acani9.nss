//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

This must support the OC henchmen and all summoned/companion
creatures.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed potential incorporeal familiar/animal companion not getting the benefits of this condition
- added flying and waterbreathing effect icon to the summons that are considered as such
*/

#include "x0_inc_henai"
#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);

    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Distance: make henchmen stick closer
    SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    if (GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN)
    {
        SetAssociateState(NW_ASC_DISTANCE_2_METERS);
    }

    //1.72: support for incorporeal animal companion or familiar
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL))
    {
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        effect eGhost = EffectCutsceneGhost();
        effect eKDImmunity = EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN);
        effect eImmunity = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
        effect eLink = EffectLinkEffects(eConceal,eGhost);
        eLink = EffectLinkEffects(eLink,eKDImmunity);
        eLink = EffectLinkEffects(eLink,eImmunity);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eLink), OBJECT_SELF);
    }

    //1.72: custom effect icon to describe summoned monster special qualities to player
    if(spellsIsFlying(OBJECT_SELF))
    {
        if(Get2DAString("effecticons","Icon",151) == "ief_fly")//this will make sure the 2DA files are merged and icon is the correct one, if not, do nothing
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectIcon(151)),OBJECT_SELF);
        }
    }
    if(spellsIsImmuneToDrown(OBJECT_SELF))
    {
        if(Get2DAString("effecticons","Icon",152) == "ief_bubble")//this will make sure the 2DA files are merged and icon is the correct one, if not, do nothing
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectIcon(152)),OBJECT_SELF);
        }
    }

    // Set starting location
    SetAssociateStartLocation();
}
