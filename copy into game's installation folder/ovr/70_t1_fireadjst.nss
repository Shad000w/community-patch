//::///////////////////////////////////////////////
//:: Adjustable Fire Trap
//:: 70_t1_fireadjst
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Adjustable aoe fire trap. Reflex save versus damage, evasion is applicable.

This trap can be adjusted by builder via variables on trap trigger. If you do not
set all required variables, the trap might not have work as intended, see detailed
variables list below (may differ per trap type)

--------------------------------------------------
|  Name     | Type | Value
--------------------------------------------------
| DC        | int  | desired DC to avoid damage, if unset, save won't be possible!
| DamageMin | int  | minimal damage done to target(s), if unset, 1 will be used,
|                  | if greater than maximum, damage will use minimum and will be fixed
| DamageMax | int  | maximal damage done to target(s), if unset, minimum will be used
|                  | note: if both DamageMin and DamageMax won't be set, no damage will be done!
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

#include "70_inc_spells"

void main()
{
    //1.72: fix for bug where traps are being triggered where they really aren't
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_TRIGGER && !GetIsInSubArea(GetEnteringObject()))
    {
        return;
    }
    //Declare major variables
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(oTarget);
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eDam;

    int nDC = GetLocalInt(OBJECT_SELF,"DC");
    float fDuration = GetLocalFloat(OBJECT_SELF,"Duration");
    int minDamage = GetLocalInt(OBJECT_SELF,"DamageMin");
    int maxDamage = GetLocalInt(OBJECT_SELF,"DamageMax");
    if(minDamage+maxDamage < 1)
    {
        return;//wrong setting, do not waste the resources
    }
    int nDamage;

    //Get first object in the target area
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    //Cycle through the target area until all object have been targeted
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            if(minDamage >= maxDamage)
            {
                nDamage = minDamage;//max unset or equal or lower than min, min will be used
            }
            else
            {
                if(minDamage < 1)//if min damage is not set
                {
                    minDamage = 1;//lets set trap to do at least 1 damage
                }
                nDamage = minDamage+Random(maxDamage-minDamage+1);//get random value between min and max
            }
            if(nDC > 0)
            {
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);
            }
            if(nDamage > 0)
            {
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
        }
        //Get next target in shape
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    }
}
