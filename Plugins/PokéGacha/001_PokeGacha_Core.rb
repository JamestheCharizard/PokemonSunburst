#==============================================================================
# PokeGacha System - Bringing the worst outcome of microtransactions to life!
# By: DerxwnaKapsyla, with considerable help from Vendily and Lucidious89
#===============================================================================
# This system will allow you to add a gacha system to your project. In its
# current state, this only allows for a Single Pull, or a Ten Pull. I have
# no plans at the moment to accept non-standard denominations (5, 20, 300, etc).
# 
# The system requires an item to be consumed on every use. By default this is
# defined as Comet Shards. This can be changed by editing relevant lines. In
# future versions, this will be a setting that users can change.
#
# By default the system uses flags defined on species defined in Pokemon.txt
# to determine rarity. You could totally find another way to do it, this is just
# the one I went with.
#
# Future versions will allow for more robust "banner" creation, which you can
# use to make your own rules for the rarity, species to be included, etc.
# 
# In its current state, this only works for species defined in Pokemon.txt and
# Pokemon_Forms.txt. Future versions may include a way to do the system for
# items as well.
#
# There are currently no animations. Future versions should rectify this.
#
# This also comes with a system to mass flag species, as well as a system to
# mass unflag species. They can be called with the following lines in an event's
# script command:
#
# "compile_gacha_flags" # Mass Flag Adder
# "remove_gacha_flags"  # Mass Flag Remover
#
# If you want a species to be blacklisted from the Gacha, for whatever reason,
# you would add the following flag to that species in Pokemon.txt and
# Pokemon_Forms.txt:
#
# "ExcludeFromRandomSearch"
#
# If you somehow make this system pay-to-use with real money I will find you,
# and I will subject you to 4 Dimensional Chess against an AI that has no idea
# how to play chess so it keeps making up rules.
#===============================================================================
# To call the system in game, you would use this following line in an event's
# script command:
#
# "pgPokeGacha"
#
#===============================================================================

class Game_Temp
  attr_accessor :poke_gacha_tiers
end

module GameData
  class Species
    attr_accessor :flags
  end
end

alias gacha_pbClearData pbClearData
def pbClearData
  gacha_pbClearData
  $game_temp.poke_gacha_tiers = nil if $game_temp
end

# To-Do: Make it so the Information option returns to the top.
def pgPokeGacha
  pbMessage(_INTL("Welcome to the PokeGacha System!"))
  pbMessage(_INTL("This is a very conceptual system that is meant to replicate the effects of a Mobage's gacha system."))
  @sel_choice = self.pgChoices
  return pgExitGacha if !@sel_choice
  if @sel_choice == 0
	pgSingleRoll
  elsif @sel_choice == 1
	pgTenRoll
  else
    pgInformation
  end
  pgExitGacha
end

def pgChoices
  choices = [_INTL("Single Pull"),_INTL("Ten Pull"),_INTL("Information"),_INTL("Cancel")]
  cmd = pbMessage(_INTL("What would you like to do?"),choices,choices.length)
  return false if cmd == choices.length-1
  return cmd
end

# To-Do: Condence the rolls into one handler that just checks the option you picked and sets a value
def pgSingleRoll
  if $bag.has?(:COMETSHARD, 10)
    $bag.remove(:COMETSHARD, 10)
  else
    pbMessage(_INTL("You do not have enough Comet Shards."))
	return false
  end
  pbMessage(_INTL("Executing Single Roll."))
  tiers = pgGenerateTiers
  rarity = pgDetermineRarity
  pkmn = tiers[rarity].sample
  pbAddPokemon(pkmn, 20)
end

def pgTenRoll
  if $bag.has?(:COMETSHARD, 100)
    $bag.remove(:COMETSHARD, 100)
  else
    pbMessage(_INTL("You do not have enough Comet Shards."))
	return false
  end
  pbMessage(_INTL("Executing Ten Roll."))
  tiers = pgGenerateTiers
  10.times do
    rarity = pgDetermineRarity
    pkmn = tiers[rarity].sample
    pbAddPokemon(pkmn, 20)    
  end
end

# Tiers are generated based on the flags a species has. By default, there are four tiers.
# Tier 1: Base/Baby Pokemon
# Tier 2: Stage One/Pokemon with No Evolution
# Tier 3: Stage Two Pokemon
# Tier 4: Legendary, Mythical, and Paradox Pokemon, as well as Ultra Beasts.
#
# There is a check for Pokemon with a specific flag that will exclude them from being indexed into the random pool.
# Use this for things like Arceus' alternate forms, Mega Evolutions- things that 
# require specific conditions to change forms and/or don't persist after battle.
def pgGenerateTiers
  $game_temp = Game_Temp.new if !$game_temp
  if !$game_temp.poke_gacha_tiers
	tiers = []
	GameData::Species.each do |sp|
	  if sp.has_flag?("ExcludeFromRandomSearch")
	    next
	  elsif sp.has_flag?("Legendary") || sp.has_flag?("Mythical") || sp.has_flag?("UltraBeast") || sp.has_flag?("Paradox")
		rarity = 3
	  elsif sp.has_flag?("StageTwo")
		rarity = 2
	  elsif sp.has_flag?("StageOne") || sp.has_flag?("NoEvo")
		rarity = 1
	  else
		# This is for Base/Baby Pokemon
		rarity = 0
	  end
	  tiers[rarity] = [] if tiers[rarity].nil?
	  tiers[rarity].push(sp.id)
	end
	$game_temp.poke_gacha_tiers = tiers
  end
  return $game_temp.poke_gacha_tiers
end

# To-Do: Come up with a Pity system and/or a Spark system.
# Odds are determined by a random number, generated between 1 and 100 (inclusive).
# Tier 1: 60%
# Tier 2: 20%
# Tier 3: 15%
# Tier 4: 5%
def pgDetermineRarity
  rarity = nil
  rand_num = rand(100) + 1
  #p rand_num
  
  case rand_num
  when 1..60
	rarity = 0
  when 61..80
	rarity = 1
  when 81..95
	rarity = 2
  when 96..100
	rarity = 3
  end
  
  return rarity
end

def pgInformation
  pbMessage(_INTL("The PokeGacha System works similarly to those found in mobages."))
  pbMessage(_INTL("You will have two options. A single pull, or a ten pull. These are self explanatory."))
  pbMessage(_INTL("The system makes use of a \"Premium\" Currency, which in this case will be Comet Shards."))
  pbMessage(_INTL("A Single Pull costs 10 Comet Shards. A Ten Pull costs 100 Comet Shards."))
  pbMessage(_INTL("There is currently no plans for things like Six Pulls, Twenty Pulls, Three Hundred Pulls, etc."))
  pbMessage(_INTL("This system is entirely for proof of concept, and an experiment to see if I could do it."))
end
  
  
def pgExitGacha
  pbMessage(_INTL("Please save up additional Comet Shards and return again!"))
  return false
end

module Compiler
  module_function

  # These arrays are for flag overrides, as there is no way to automate the process of
  # flagging them. You can add/remove/change at will, this will not break anything if
  # you don't have the relevant species in your files.
  
  LEGENDARY 	= [:ARTICUNO, :ZAPDOS, :MOLTRES, :MEWTWO, :RAIKOU, :SUICUNE, :ENTEI,
				   :LUGIA, :HOOH, :REGIROCK, :REGICE, :REGISTEEL, :LATIAS, :LATIOS,
				   :KYOGRE, :GROUDON, :RAYQUAZA, :UXIE, :MESPRIT, :AZELF, :HEATRAN,
				   :REGIGIGAS, :CRESSELIA, :DIALGA, :PALKIA, :GIRATINA, :COBALION,
				   :TERRAKION, :VIRIZION, :TORNADUS, :THUNDURUS, :LANDORUS, :RESHIRAM,
				   :ZEKROM, :KYUREM, :TYPENULL, :XENERAS, :YVELTAL, :ZYGARDE, 
				   :SILVALY, :TAPUKOKO, :TAPULELE, :TAPUBULU, :TAPUFINI, :COSMOG,
				   :COSMOEM, :SOLGALEO, :LUNALA, :NECROZMA, :ZACIAN, :ZAMAZENTA,
				   :ETERNATUS, :KUBFU, :URSHIFU, :REGIELEKI, :REGIDRAGO, :GLASTRIER,
				   :SPECTRIER, :CALYREX, :ENAMORUS, :WOCHIEN, :CHIENPAO, :TINGLU,
				   :CHIYU, :KORAIDON, :MIRAIDON, :OGERPON, :TERAPAGOS,
				   :MARISAO, :YUYUKOO, :DEVASO, :KANAKOO, :REIMUO, :SARIELO]
  
  MYTHICAL 		= [:MEW, :CELEBI, :JIRACHI, :DEOXYS, :PHIONE, :MANAPHY, :DARKRAI,
				   :SHAYMIN, :ARCEUS, :VICTINI, :KELDEO, :MELOETTA, :GENESECT,
				   :DIANCIE, :HOOPA, :VOLCANION, :MAGEARNA, :MARSHADOW, :ZERAORA,
				   :MELTAN, :MELMETAL, :ZARUDE,
				   :AYAKASHI, :JKSANAE, :TENSOKUG, :CHAMPKASEN, :TWOHU, :ISAMI,
				   :SATSUKI, :AVIVIT, :AIZARD, :AIGYARADOS, :AINITE, :AIMENCE,
				   :AILATIOS, :AIRAYQUAZA, :AIGARCHOMP, :AIDIALGA, :AIPALKIA,
				   :AIGIRATINA, :NEPGEAR, :EMARISA, :MPSUIKA]
  
  ULTRABEAST 	= [:NIHILEGO, :BUZZWOLE, :PERHOMOSA, :XURKITREE, :CELESTEELA,
				   :KARTANA, :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA,
				   :BLACEPALON]
  
  PARADOX 		= [:GREATTUSK, :SCREAMTAIL, :BRUTEBONNET, :FLUTTERMANE, :SLITHERWING,
				   :SANDYSHOCKS, :ROARINGMOON, :WALKINGWAGE, :IRONTREADS, :IRONBUNDLE,
				   :IRONHANDS, :IRONJUGULIS, :IRONMOTH, :IRONTHORNS, :IRONVALIANT,
				   :IRONLEAVES]
				   
  # To-Do: Maybe automate the blacklist?

  def compile_gacha_flags
    GameData::Species.each do |sp|
	  next if sp.species == :CTEWI  # I'M A TRICKSTER SO I HAVE A NON STANDARD EVOLUTION FAMILY
	  next if sp.species == :TEWI   # LOOK AT ME SING AND DANCE AND PRANK EVERYONE AROUND
	  next if sp.species == :ATEWI  # AND IF YOU DON'T ACCOUNT FOR ME
	  next if sp.species == :DTEWI  # I'LL CRASH YOUR GAME WITHOUT GIVING YOU A TRACEBACK.
	  next if sp.species == :ADTEWI # This one is just to be safe.
	  sp.flags.push("Legendary") if LEGENDARY.include?(sp.species) && !sp.has_flag?("Legendary")
	  sp.flags.push("Mythical") if MYTHICAL.include?(sp.species) && !sp.has_flag?("Mythical")
	  sp.flags.push("UltraBeast") if ULTRABEAST.include?(sp.species) && !sp.has_flag?("UltraBeast")
	  sp.flags.push("Paradox") if PARADOX.include?(sp.species) && !sp.has_flag?("Paradox")
      family = sp.get_family_species || []
      if family.length <= 1
        next if sp.has_flag?("Legendary") || sp.has_flag?("Mythical") || 
                sp.has_flag?("UltraBeast") || sp.has_flag?("Paradox")
        flag = "NoEvo"
      else
        next if sp.species == family[0]
        prev = sp.get_previous_species
        if prev == family[0]
          flag = "StageOne"
        else
          flag = "StageTwo"
        end
      end
      echoln "#{sp.id}, #{flag}"
	  sp.flags.push(flag) if flag
      sp.flags.uniq!
    end
    GameData::Species.save
    Compiler.write_pokemon
    Compiler.write_pokemon_forms
    Compiler.compile_pokemon
    Compiler.compile_pokemon_forms
  end
  
  def remove_gacha_flags
    GameData::Species.each do |sp|
      sp.flags.each do |flag|
        if ["NoEvo", "StageOne", "StageTwo"].include?(flag)
          sp.flags.delete(flag)
        end
      end
    end
    GameData::Species.save
    Compiler.write_pokemon
    Compiler.write_pokemon_forms
  end
end