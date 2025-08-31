//::///////////////////////////////////////////////
//:: Default community patch OnModuleLoad module event script
//:: 70_mod_def_load
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
The 70_mod_def_* scripts are a new feature and will fire just before normal module events.

The purpose of this is to automatically enforce fixes/features that requires changes
in module events in any module player will play. Also, PW builders no longer needs
to merge scripts to get these functionalities.

If you are a builder you can reuse these events for your own purposes too. With
this feature, you can make a system like 3.5 ruleset which will work in any module
as long player is using patch 1.72.

Note: community patch doesn't include scripts for all these events, but only for
a few. You can create a script with specified name for other events. There was
just no point of including a script which will do nothing. So here is a list:
OnAcquireItem       - 70_mod_def_aqu
OnActivateItem      - 70_mod_def_act
OnClientEnter       - 70_mod_def_enter
OnClientLeave       - 70_mod_def_leave
OnCutsceneAbort     - 70_mod_def_abort
OnHeartbeat         - not running extra script
OnModuleLoad        - 70_mod_def_load
OnPlayerChat        - 70_mod_def_chat
OnPlayerDeath       - 70_mod_def_death
OnPlayerDying       - 70_mod_def_dying
OnPlayerEquipItem   - 70_mod_def_equ
OnPlayerLevelUp     - 70_mod_def_lvup
OnPlayerRespawn     - 70_mod_def_resp
OnPlayerRest        - 70_mod_def_rest
OnPlayerUnEquipItem - 70_mod_def_unequ
OnUnAcquireItem     - 70_mod_def_unaqu
OnUserDefined       - 70_mod_def_user

It is also possible to bypass the original script, use this command:
SetLocalInt(OBJECT_SELF,"BYPASS_EVENT",1);
This should be used wisely as you don't know what is original module event script
doing so, do this only if running original event has no longer sense.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 31-05-2017
//:://////////////////////////////////////////////

#include "70_inc_switches"

void main()
{
    if(GetLocalInt(OBJECT_SELF,"70_mod_def_load_DOONCE")) return;//safety check to prevent running this multiple times
    SetLocalInt(OBJECT_SELF,"70_mod_def_load_DOONCE",TRUE);

    string sScript = GetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM);
    if(sScript != "70_mod_def_aqu")
    {
        SetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM,"70_mod_def_aqu");
        SetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM",sScript);
    }

    sScript = GetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM);
    if(sScript != "70_mod_def_equ")
    {
        SetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM,"70_mod_def_equ");
        SetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM",sScript);
    }

    sScript = GetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_PLAYER_LEVEL_UP);
    if(sScript != "70_mod_def_lvup")
    {
        SetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_PLAYER_LEVEL_UP,"70_mod_def_lvup");
        SetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_PLAYER_LEVEL_UP",sScript);
    }

    sScript = GetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_RESPAWN_BUTTON_PRESSED);
    if(sScript != "70_mod_def_resp")
    {
        SetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_RESPAWN_BUTTON_PRESSED,"70_mod_def_resp");
        SetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_RESPAWN_BUTTON_PRESSED",sScript);
    }

    sScript = GetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_LOSE_ITEM);
    if(sScript != "70_mod_def_unaqu")
    {
        SetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_LOSE_ITEM,"70_mod_def_unaqu");
        SetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_LOSE_ITEM",sScript);
    }

    sScript = GetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM);
    if(sScript != "70_mod_def_unequ")
    {
        SetEventScript(OBJECT_SELF,EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM,"70_mod_def_unequ");
        SetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM",sScript);
    }

   // * 1.72: Activating this switch below will modify curse effect to ignore immunity to ability decrease.
   // * Note: This is not custom content compatible. If you have custom spell(ability) with curse effect
   // * you need to add the same code as in nw_s0_bescurse. It also won't work on curse from weapon onhit.
   // SetModuleSwitch (MODULE_SWITCH_CURSE_IGNORE_ABILITY_DECREASE_IMMUNITY, TRUE);

   // * 1.72: Activating this switch below will allow to use only one damage shield spell at once.
   // * Affected spells: elemental shield, mestil's acid sheat, aura vs alignment, death armor
   // * and wounding whispers.
   // * When one of these spells is cast, any other such spell is dispelled.
   // SetModuleSwitch (MODULE_SWITCH_DISABLE_DAMAGE_SHIELD_STACKING, TRUE);

   // * 1.72: Activating this switch below will allow to use only one weapon boost spell at once.
   // * Affected spells: magic weapon, greater magic weapon, bless weapon, flame weapon, holy sword,
   // * deafning clang, keen edge, darkfire and black staff.
   // * When one of these spells is cast on same item, the item gets stripped of all
   // * temporary itemproperties.
   // SetModuleSwitch (MODULE_SWITCH_DISABLE_WEAPON_BOOST_STACKING, TRUE);

   // * 1.72: This switch controlls how much persistent AOE spells of the same type can player cast
   // * in the same area. This will stop the cheesy tactics to stack dozen of blade barries or
   // * acid fogs and lure monsters into it.
   // * Unlike weapon boosts and damage shields, this switch allows to set specific number of
   // * allowed aoes spells, so 1 = max 1, 2 = max 2 etc.
   // SetModuleSwitch (MODULE_SWITCH_DISABLE_AOE_SPELLS_STACKING, 1);

   // * 1.72: Activating this switch below will enable hardcore DnD rules for evasion and improved
   // * evasion. Evasion feats will only work in light or no armor. Also a character must not
   // * be helpless ie. under effects of stun, paralysis, petrify, sleep or timestop.
   // SetModuleSwitch (MODULE_SWITCH_HARDCORE_EVASION_RULES, TRUE);

   // * 1.72: Activating this switch below will allow to merge every items the character wears into
   // * every polymorph shape in game even Tenser's transformation. This automatically enables
   // * the "merge arms" switch.
   // * Note: for unarmed shapes only defensive properties from weapon will merge.
   // SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_EVERYTHING, TRUE);

   // * 1.71: Activating this switch below will enforce the SoU empower spell feat behavior.
   // * This behavior empowers only dice values and any bonuses are added to the final result.
   // * Note: By default, empower spell feat empowers result of dice+bonus reaching much higher
   // * values, often outshining the maximized spell feat result.
   // SetModuleSwitch (MODULE_SWITCH_SOU_EMPOWER_SPELL_BEHAVIOR, TRUE);

   // * 1.71: Activating this switch below will enable to summon more than one summoned
   // * creature at the same time. Value TRUE/1 means unlimited, but it can be set to 2,3, etc.
   // SetModuleSwitch (MODULE_SWITCH_UNLIMITED_SUMMONING, TRUE);

   // * 1.71: Activating this switch below will stack multiple same bonuses and penalties
   // * to the single ability together, by default only highest applies.
   // SetModuleSwitch (MODULE_SWITCH_POLYMORPH_STACK_ABILITY_BONUSES, TRUE);

   // * 1.71: Activating this switch below will enable to merge bracers/gloves when polymorphing.
   // * This will work only for shapes that merges items. Also only defensive abilities works.
   // SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_ARMS, TRUE);

   // * 1.71: Activating this switch below will calculate Pale master levels into
   // * caster level calculation. This will affect only arcane spells cast normally.
   // * Not all PM levels counts, under default 2DA setting the bonus to the caster
   // * level is (PM level/2)+1 - even levels do not affect spellcasting abilities.
   // SetModuleSwitch (MODULE_SWITCH_PALEMASTER_ADDS_CASTER_LEVEL, TRUE);

   // * 1.71: Activating this switch below will restrict usage of the musical instruments.
   // * Possible values:
   // * 1: instruments will be restricted to the Perform skill, DC for success
   // * is then same as for UMD, 7+(3*SpellLevel)
   // * 2: instruments will be restricted to the bard song feat, just the way
   // * the Lich lyric are, each casting will decrement one use of the bard song feat
   // SetModuleSwitch (MODULE_SWITCH_RESTRICT_MUSICAL_INSTRUMENTS, 1);

   // * 1.71: Activating this switch below will shorten the duration of all disable effects
   // * (stun, paralyse, charm, daze, confusion, dominate, entangle, knockdown, grapple)
   // * to the constant of 3rounds (unless effect comes from extended spell)
   // * Possible values:
   // * 1: apply only when caster isn't PC and target is PC or his associate
   // * 2: apply regardless of who is caster but only when target is PC or his associate
   // * 3: apply regardless of who is caster and who target
   // SetModuleSwitch (MODULE_SWITCH_SHORTENED_DURATION_OF_DISABLE_EFFECTS, 1);

   // * 1.71: By default creature affected by the poison effect itself is virtually
   // * immune to other poisons until this effect wears off. This switch changes this
   // * behavior and adds greater effect to the poisons.
   // SetModuleSwitch (MODULE_SWITCH_ALLOW_POISON_STACKING, TRUE);

   // * 1.71: Activating one of the switches below will enable to various weapon boost spells to
   // * affect additional weapons. Of course the spells still apply other rules such as slashing only
   // * etc. so this will not allow to cast keen on gloves.
   // SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_THROWING_WEAPONS, TRUE);
   // SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_RANGED_AND_AMMO, TRUE);
   // SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_GLOVES, TRUE);

   // * 1.70: Activating the switch below will enable the AOE heartbeat workaround solution
   // * if the default heartbeat solution doesn't work and AOEs do nothing
   // SetModuleSwitch (MODULE_SWITCH_AOE_HEATBEAT_WORKAROUND, TRUE);

   // * 1.70: Activating the switch below will enable item sold to store tracking, once the limit
   // * of sold items, in this case 100, will be reached, oldest item sold to store will be destroyed
   // SetModuleSwitch (MODULE_SWITCH_OVERFILLED_STORES_ISSUE_FIX, 100);

   // * 1.70: Activating the switch below will disable the spell resist check inside AOEs, thus
   // * these spells will ignore spell resistance, spell mantle and even spell immunity
   // SetModuleSwitch (MODULE_SWITCH_AOE_IGNORES_SPELL_RESISTANCE, TRUE);

   // * 1.70: Activating the switch below will revert the 1.70's "Spell Immunity precedence"
   // inside ResistSpell check back to the 1.69 behavior where spell mantle "goes first".
   // SetModuleSwitch (MODULE_SWITCH_SPELL_MANTLE_169_BEHAVIOR, TRUE);

   // * 1.70: Activating the switch below will revert the 1.70's Dusty Rose ioun stone dodge AC
   // balance change back to the 1.69 deflection.
   // SetModuleSwitch (MODULE_SWITCH_DUSTYROSE_IOUNSTONE_169_AC_TYPE, TRUE);

   // * 1.70: Activating the switch below will disable the 1.70's feature that mark item as stolen
   // SetModuleSwitch (MODULE_SWITCH_CONTINUAL_FLAME_ALLOW_EXPLOIT, TRUE);
}
