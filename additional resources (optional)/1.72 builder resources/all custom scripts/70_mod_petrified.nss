//::///////////////////////////////////////////////
//:: Community Patch OnPetrified event script
//:: 70_mod_petrified
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Server primarily as an easy way to enforce persistency, add extra effects,
penalties or even to remove the petrification effect entirely.

Fires after target is petrified, to prevent petrify to happen you need to use
spellhook.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 28-12-2015
//:://////////////////////////////////////////////

void main()
{
    //declare major variables
    object oPC = OBJECT_SELF;
    object oCreator = OBJECT_INVALID;

    effect ePetrify = GetFirstEffect(oPC);
    while(GetIsEffectValid(ePetrify))
    {
        if(GetEffectType(ePetrify) == EFFECT_TYPE_PETRIFY)
        {
            oCreator = GetEffectCreator(ePetrify);
            break;
        }
        ePetrify = GetNextEffect(oPC);
    }

    //do something
}
