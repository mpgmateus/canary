local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_POISON)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Cure Poison")
spell:words("exana pox")
spell:group("healing")
spell:vocation("druid;true", "elder druid;true", "knight;true", "elite knight;true", "paladin;true",
               "royal paladin;true", "sorcerer;true", "master sorcerer;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CURE_POISON)
spell:id(29)
spell:cooldown(3000)
spell:groupCooldown(1000)
spell:level(10)
spell:mana(30)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
