//::///////////////////////////////////////////////
//:: Adjustable Frost Trap
//:: 70_t1_coldadjst
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Adjustable single target cold trap. Fort save vs paralyse, cold damage without save.

This trap can be adjusted by builder via variables on trap trigger. If you do not
set all required variables, the trap might not have work as intended, see detailed
variables list below (may differ per trap type)

--------------------------------------------------
|  Name     | Type | Value
--------------------------------------------------
| DC        | int  | desired DC to avoid paralyse, if unset, save won't be possible!
| Duration  | int  | desired length of the paralysation effect in seconds, if unset
|                  | paralyse effect will be omitted!
| DamageMin | int  | minimal damage done to target(s), if unset, 1 will be used,
|                  | if greater than maximum, damage will use minimum and will be fixed
| DamageMax | int  | maximal damage done to target(s), if unset, minimum will be used
|                  | note: if both DamageMin and DamageMax won't be set, no damage will be done!
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

#include "nw_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    effect eLink = EffectLinkEffects(EffectParalyze(), EffectVisualEffect(VFX_DUR_BLUR));
    int nDC = GetLocalInt(OBJECT_SELF,"DC");
    int nDuration = GetLocalInt(OBJECT_SELF,"Duration");
    int minDamage = GetLocalInt(OBJECT_SELF,"DamageMin");
    int maxDamage = GetLocalInt(OBJECT_SELF,"DamageMax");
    int nDamage;
    if(minDamage+maxDamage > 0)//if either min or max is set
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
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_COLD), oTarget);
    }
    if(nDuration > 0 && (nDC < 1 || !MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_TRAP)))
    {
        //Apply Hold
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, IntToFloat(nDuration));
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FROST_S), oTarget);
}
