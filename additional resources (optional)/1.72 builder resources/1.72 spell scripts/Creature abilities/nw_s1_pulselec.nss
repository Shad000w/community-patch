//::///////////////////////////////////////////////
//:: Pulse: Lightning
//:: NW_S0_CallLghtn.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within 10ft of the creature take
    1d6 per HD up to 10d6
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- wrong target check (could affect other NPCs)
- lightning beam vfx will appear always now
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nDamage;
    effect eVis = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
    effect eHowl = EffectVisualEffect(VFX_IMP_PULSE_COLD);
    DelayCommand(0.5, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eHowl, GetLocation(OBJECT_SELF)));

    effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, OBJECT_SELF,BODY_NODE_CHEST);
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + nHD;
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_LIGHTNING));
            //Roll the damage
            nDamage = d6(nHD);
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_ELECTRICITY);
            //Determine effect delay
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLightning,oTarget, 0.5));
            if(nDamage > 0)
            {
                eHowl = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    }
}
