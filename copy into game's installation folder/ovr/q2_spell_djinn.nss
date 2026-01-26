//::///////////////////////////////////////////////
//:: q2_spell_djinn
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The Djinn will never stick around if a spell
    is cast at him...
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Dec 12/02
//:://////////////////////////////////////////////
/*
Patch 1.72
- djinn no longer disappears if a beneficial spell is cast on him (which can happen automatically if player has mobile aura)
*/

#include "NW_I0_GENERIC"

void main()
{
    if(GetLastSpellHarmful())
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), GetLocation(OBJECT_SELF));
        DestroyObject(OBJECT_SELF, 2.0);
    }
}
