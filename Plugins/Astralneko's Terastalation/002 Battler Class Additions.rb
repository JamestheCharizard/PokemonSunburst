# Methods for coloring sprites
class AstralnekoTemp
	# Flag to determine that terastalization should occur
	attr_accessor :terastalization_flag
	
	alias astraltera_initialize initialize
	def initialize
		astraltera_initialize
		terastalization_flag = false
	end
end

module AstralnekoConfig
	def self.getTeraTypeColors(tera_type = :NORMAL, alpha = nil)
		if AstralnekoConfig::TERA_TYPE_COLORS && AstralnekoConfig::TERA_TYPE_COLORS.has_key?(tera_type)
			if alpha
				return Color.new(AstralnekoConfig::TERA_TYPE_COLORS[tera_type][0],
								 AstralnekoConfig::TERA_TYPE_COLORS[tera_type][1],
								 AstralnekoConfig::TERA_TYPE_COLORS[tera_type][2], alpha)
			else
				return Color.new(AstralnekoConfig::TERA_TYPE_COLORS[tera_type][0],
								 AstralnekoConfig::TERA_TYPE_COLORS[tera_type][1],
								 AstralnekoConfig::TERA_TYPE_COLORS[tera_type][2])
			end
		else
			return Color.new(0,0,0,0)
		end
	end
end

# Battler checking if they should be Terastalized
class PokeBattle_Battler
	def terastalized?
		return @pokemon && @pokemon.terastalized?
	end
	
	def hasTerastal?
		return false if @effects[PBEffects::Transform]
		return false if shadowPokemon?
		return false if mega?   || hasMega?
		return false if primal? || hasPrimal?
		return false if ultra?
		return false if dynamax?
		return @pokemon && pokemon.terastalAble?
	end
	
	alias astraltera_pbTypes pbTypes unless self.method_defined?(:astraltera_pbTypes)
	def pbTypes(withType3=false)
		if terastalized?
			ret = [@pokemon.tera_type]
			return ret
		else
			astraltera_pbTypes(withType3)
		end
	end
	
	def anTeraType
		return @pokemon.tera_type
	end
	
	def pbHasTypeWhenNotTerastalized?(type,withType3 = false)
		return false if !terastalized?
		return astraltera_pbTypes(withType3).include?(GameData::Type.get(type).id)
	end
	
	alias astraltera_canChangeType? canChangeType?
	def canChangeType?
		return false if terastalized?
		return astraltera_canChangeType?
	end
	
	#-----------------------------------------------------------------------------
	# Reverts the effects of Terastal.
	#-----------------------------------------------------------------------------
	def pbUnterastalize
		@pokemon.unterastalize
		pbUpdate(false)
		@battle.pbCommonAnimation("UnTerastalize",self)
		@battle.scene.pbChangePokemon(self,@pokemon)
		if @effects[PBEffects::Transform]
			back = !opposes?(self.index)
			pkmn = @effects[PBEffects::TransformPokemon]
			@battle.scene.sprites["pokemon_#{self.index}"].setPokemonBitmap(pkmn,back,nil,self)
		end
		text = "Terastal"
		@battle.pbDisplay(_INTL("{1}'s {2} energy left its body!",pbThis,text))
		@battle.scene.pbRefresh
	end
	alias unterastalize pbUnterastalize
end

# Battle checking if the player can Terastalize
class PokeBattle_Battle
	attr_accessor :terastal

	#-----------------------------------------------------------------------------
	# Initializes each battle mechanic.
	#-----------------------------------------------------------------------------
	alias astraltera_initialize initialize
	def initialize(*args)
		astraltera_initialize(*args)
		@terastal = [
			[-1] * (@player ? @player.length : 1),
			[-1] * (@opponent ? @opponent.length : 1)
		]
	end
	
	#-----------------------------------------------------------------------------
	# Checks for items required to utilize certain battle mechanics.
	#-----------------------------------------------------------------------------
	def pbHasTeraOrb?(idxBattler)
		return true if !pbOwnedByPlayer?(idxBattler)
		AstralnekoConfig::TERA_ORBS.each { |item| return true if $PokemonBag.pbHasItem?(item) }
		return false
	end
	
	def pbCanTerastalize?(idxBattler)
		battler = @battlers[idxBattler]
		side    = battler.idxOwnSide
		owner   = pbGetOwnerIndexFromBattlerIndex(idxBattler)
		return false if $game_switches[AstralnekoConfig::NO_TERASTAL] # Can't Tera if disallowed
		return false if battler.hasUltra?                             # No Tera if Ultra Burst is available first.
		return false if battler.dynamax?                              # No Tera if the user is Dynamaxed.
		return false if wildBattle? && opposes?(idxBattler)           # No Tera for wild Pokemon.
		return true if $DEBUG && Input.press?(Input::CTRL)            # Allows Tera with CTRL in Debug.
		return false if battler.effects[PBEffects::SkyDrop]>=0        # No Tera if in Sky Drop.
		return false if @terastal[side][owner]!=-1                    # No Tera if used this battle.
		return false if !pbHasTeraOrb?(idxBattler)                    # No Tera if no Tera Orb.
		return @terastal[side][owner]==-1
	end
	
	#-----------------------------------------------------------------------------
	# Registering Terastalization
	#-----------------------------------------------------------------------------
	def pbRegisterTerastal(idxBattler)
		side  = @battlers[idxBattler].idxOwnSide
		owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
		@terastal[side][owner] = idxBattler
	end

	def pbUnregisterTerastal(idxBattler)
		side  = @battlers[idxBattler].idxOwnSide
		owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
		@terastal[side][owner] = -1 if @terastal[side][owner]==idxBattler
	end

	def pbToggleRegisteredTerastal(idxBattler)
		side  = @battlers[idxBattler].idxOwnSide
		owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
		if @terastal[side][owner]==idxBattler
			@terastal[side][owner] = -1
		else
			@terastal[side][owner] = idxBattler
		end
	end

	def pbRegisteredTerastal?(idxBattler)
		side  = @battlers[idxBattler].idxOwnSide
		owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
		return @terastal[side][owner]==idxBattler
	end
	
	#=============================================================================
	# Terastalizing a battler
	#=============================================================================
	def pbAttackPhaseTerastal
		pbPriority.each do |b|
		next if wildBattle? && b.opposes?
		next unless @choices[b.index][0]==:UseMove && !b.fainted?
		owner = pbGetOwnerIndexFromBattlerIndex(b.index)
		next if @terastal[b.idxOwnSide][owner]!= b.index
		pbTerastalize(b.index)
		end
	end
	
	def pbTerastalize(idxBattler)
		battler = @battlers[idxBattler]
		return if !battler || !battler.pokemon
		return if !battler.hasTerastal? || battler.terastalized?
		$stats.times_terastalized  += 1 if battler.pbOwnedByPlayer?
		# displays trainer dialogue if applicable
		if Settings::EBDX_COMPAT
			@scene.pbTrainerBattleSpeech(playerBattler?(@battlers[index]) ? "tera" : "teraOpp")
		end
		trainerName = pbGetOwnerName(idxBattler)
		# Terastalize
		pbDisplay(_INTL("{1} used their Tera Orb on {2}!",trainerName,battler.pbThis))
		pbCommonAnimation("Terastalization",battler)
		back = !opposes?(idxBattler)
		pkmn = battler.effects[PBEffects::TransformPokemon]
		# Ogerpon form change
		if battler.isSpecies?(:OGERPON) && battler.form < 5
			battler.form += 5
		end
		# Terapagos form change
		if battler.isSpecies?(:TERAPAGOS) && battler.form == 1
			battler.form = 2
		end
		# EBDX Compatibility
		if Settings::EBDX_COMPAT
			battler.pokemon.terastalize
			@scene.pbChangePokemon(battler,battler.pokemon)
			if battler.effects[PBEffects::Transform]
				@scene.sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back,nil,battler)
			end
			@scene.sprites["pokemon_#{idxBattler}"].terastalized = true
			EliteBattle.playCommonAnimation(:ROAR, @scene, battler.index)
		else
			# Gets appropriate battler sprite if user was transformed prior to Terastalization.
			if battler.effects[PBEffects::Transform]
				$Astralneko_Temp.terastalization_flag = true
				@scene.sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back,battler)
				$Astralneko_Temp.terastalization_flag = false
			end
			pbCommonAnimation("Terastalization2",battler)
		end
		teraName = _INTL("Tera {1} {2}",battler.pokemon.tera_type,battler.pokemon.speciesName)
		teraName = _INTL("Tera {1} {2}",battler.form-5,battler.pokemon.speciesName)
		pbDisplay(_INTL("{1} has Terastalized into {2}!",battler.pbThis,teraName))
		# Mark terastalized
		side  = battler.idxOwnSide
		owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
		@terastal[side][owner] = -2
		battler.pbUpdate(false)
		# Activate Ogerpon's Ability
		if battler.isSpecies?(:OGERPON) && battler.form >= 5 # Form ID should be true, but just in case
			if battler.unstoppableAbility? || battler.abilityActive?
				BattleHandlers.triggerAbilityOnSwitchIn(battler.ability,battler,@battle)
			end
		end
		# Activate Terapagos's Ability
		if battler.isSpecies?(:TERAPAGOS) && battler.form == 2 # Form ID should be true, but just in case
			if battler.unstoppableAbility? || battler.abilityActive?
				BattleHandlers.triggerAbilityOnSwitchIn(battler.ability,battler,@battle)
			end
		end
	end
	
	#-----------------------------------------------------------------------------
	# Reverts Terastal at the end of battle.
	#-----------------------------------------------------------------------------
	alias astraltera_pbEndOfBattle pbEndOfBattle
	def pbEndOfBattle
		@battlers.each do |b|
			next if !b || !b.terastalized?
			b.unterastalize
		end
		astraltera_pbEndOfBattle
	end
end