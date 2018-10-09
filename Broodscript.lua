local AutoSpawnSpiderlings = {}
AutoSpawnSpiderlings.enabled = Menu.AddOption({"Hero Specific", "Broodmother"}, "Auto-Cast Spawn Spiderlings", "Automatically cast spawn spiderlings on nearby creeps/neutrals. Will prioritize heroes if they can be killed.")
AutoSpawnSpiderlings.savePercent = Menu.AddOption({"Hero Specific", "Broodmother"}, "Auto-Cast Save Percent", "Auto-Cast on creeps/neutrals will be disabled if a nearby hero is within X percent of the damage needed to be killed", 0, 100, 5)

function AutoSpawnSpiderlings.OnUpdate()
	if not Engine.IsInGame() or not Menu.IsEnabled(AutoSpawnSpiderlings.enabled) then return end

	local me = Heroes.GetLocal()
	if not me or not Entity.IsAlive(me) or NPC.GetUnitName(me) ~= "npc_dota_hero_broodmother" then return end

	local spell = NPC.GetAbilityByIndex(me, 0)
	if not spell or not Ability.IsReady(spell) or not Ability.IsCastable(spell, NPC.GetMana(me)) then return end

	local damage = Ability.GetLevelSpecialValueFor(spell, "damage")
	local npcs = Entity.GetUnitsInRadius(me, 750, Enum.TeamType.TEAM_ENEMY)
	local targets = {}
	for k,v in ipairs(npcs) do
		if not v or not Entity.IsAlive(v) or NPC.HasState(v, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then goto cont1 end
		if Entity.IsDormant(v) or NPC.IsTower(v) or NPC.IsIllusion(v) then goto cont1 end

		local realDamage = damage - (damage*NPC.GetMagicalArmorValue(v))
		if Entity.GetHealth(v) <= realDamage then
			if NPC.IsHero(v) then
				table.insert(targets, 1, v)
				--Engine.ExecuteCommand("say Adding hero to list")
			else
				table.insert(targets, v)
				--Engine.ExecuteCommand("say Adding creep/neutral to list")
			end
		elseif NPC.IsHero(v) and realDamage / Entity.GetHealth(v) >= Menu.GetValue(AutoSpawnSpiderlings.savePercent) then
			--Engine.ExecuteCommand("say Clearing targets")
			for k2,v2 in pairs(targets) do targets[k2]=nil end
			break 
		end
		::cont1::
	end
	--Engine.ExecuteCommand("say Targets: "..#targets)
	if #targets == 0 then return end
	--Engine.ExecuteCommand("say Casting spiderlings")
	Ability.CastTarget(spell, targets[1])
end

return AutoSpawnSpiderlings