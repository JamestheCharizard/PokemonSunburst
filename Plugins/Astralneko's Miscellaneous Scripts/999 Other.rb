#=====================================================================================
# NOTE FOR FUTURE ASTRALNEKO:
# These are not to be included in future versions of ANMS plugin.
# Exclude this file when creating them.
#=====================================================================================

# Deprecated: Will replace with a better version later.
# Set encounter table
#Events.onMapChange += proc { |_sender, e|
#  $PokemonGlobal.encounter_version = 0
#  $PokemonGlobal.encounter_version = pbGetSeason
#  $PokemonGlobal.encounter_version += $game_variables[27] * 4
#}

# Freeze becomes frostbite
Events.onEndBattle += proc { |_sender,e|
	$Trainer.party.each do |pkmn|
		pkmn.status = :FROSTBITE if pkmn.status == :FREEZE
	end
}

# When the player moves to a new map, step them forward if they're coming from Map Glitch maps. (Route 4 North, Alipigra City)
# Map Glitch: When moving onto certain maps, the map visually glitches and shows a different area for 1 frame for some bizarre reason. Can't figure out why, but this soft fix makes it not happen so
Events.onMapChange += proc { |_sender,e|
	oldMapID = e[0]
	newMapID = $game_map.map_id
	# Map Glitch only occurs when walking through a map connection.
	# On load, oldMapID and newMapID are the same.
	next if oldMapID == newMapID
	glitchedMaps = [14, # Route 4 North
					33  # Alipigra City
	]
	next if !glitchedMaps.include?(oldMapID)
	$game_player.move_forward
}
# Note: This soft fix is not perfect. The player will attempt to move forward again if they enter a door on a map glitch map, because this function is called when walking into a door. Map Glitch doesn't occur in that case.
# I might be able to use the transition flag to tell it not to run on doors. However, it's probably better to just actually find the root of the glitch and patch it.

# Since ebdx PBS files aren't translated, I have to do this
# This saves me from having to run equivalent code every time
Events.onStartBattle += proc { |_sender|
	anLocalizeEBDXMenu($PokemonSystem.language)
}
def anLocalizeEBDXMenu(language)
	data = EliteBattle.get_data(:FIGHTMENU, :Metrics, :METRICS)
	if language == 1 && data[:TYPEGRAPHIC] != "types_es"
		EliteBattle.add_data(:FIGHTMENU, :METRICS, { "TypeGraphic" => "types_es" })
	elsif language == 0 && data[:TYPEGRAPHIC] != "types"
		EliteBattle.add_data(:FIGHTMENU, :METRICS, { "TypeGraphic" => "types" })
	end
end

# Remove overworld shadows from all events if applicable. @Maruno fix your gd "shaders" in PE22
def anToggleAllEventTransparency
	for event in $game_map.events.values
		event.transparent = !event.transparent if event != $game_player 
	end
end

def anHasDynamaxBand?
	if defined?(Settings::DMAX_BANDS)
		Settings::DMAX_BANDS.each { |item| return true if $PokemonBag.pbHasItem?(item) }
	end
	return false
end

# Decides a random nickname or the species name
def anDecideNickname(speciesDefaultName = "Magikarp", nickArray = ["Psycho"])
	nickNum = rand(10 + nickArray.size) # 10 + number of nicks in the array
	nick = speciesDefaultName
	nick = nickArray[nickNum-10] if nickNum > 10
	return nick
end

# Determines a Vivillon form based on the gamemap
# Vivillon form data is in the config
def anVivillonFormDeterminer
	if $game_map
		curform = 0
		for map_list in Astralneko_Config::VIVILLON_FORMS
			curform = map_list if !map_list.is_a?(Array) # if this isn't an array, this is a form ID
			next if !map_list.is_a?(Array) # the rest of this section assumes array
			for map in map_list
				return curform if $game_map.map_id == map
			end
		end
	end
	# If on an invalid map, use secret ID as a placeholder
	return $Trainer.secret_ID % 18
end

#Events.onTrainerPartyLoad += proc { |_sender, trainer|
#  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
#    if (trainer[0].trainer_type==:GHOST || $game_switches[63])  #the clone trainer type
#      partytoload=$Trainer.party
#      for i in 0...6
#        if i<$Trainer.party_count && !partytoload[i].egg?
#          trainer[0].party[i]=partytoload[i].clone
#          trainer[0].party[i].heal     #remove this comment to make a perfectly healed
#        else                            #copy of the party
#          trainer[0].party.pop()
#        end
#      end
#    end
#  end
#}

# anPlayerPronoun is used whenever a message has \ppg[X][Y] in it.
# X is the person - 1 for first, 2 for second, 3 for third - use 0 for nonpronoun things such as Spanish adding -o/a/e to adjectives
# Y is a number with the following IDs:
# 1 = formal nominative 2 = formal accusative 3 = formal genitive 4 = formal dative
# 5 = informal nominative 6 = informal accusative 7 = informal genitive 8 = informal dative
# These handlers are used so that it's easy to identify these in translation - seeing as >1000 map IDs already mandate a separate english.dat from common, I consider this to be fine
# English translated text will likely use exclusively category 3 due to very rare gender agreement otherwise
def anPlayerPronoun
	gender = $Trainer.gender
	return [
		[ # Masculine
			[ # 0 is used only for non-pronoun things, such as adjective endings
				_INTL("masc adj ending 1"),_INTL("masc adj ending 2"),_INTL("masc adj ending 3"),_INTL("masc adj ending 4"),
				_INTL("masc adj ending 5"),_INTL("masc adj ending 6"),_INTL("masc adj ending 7"),_INTL("masc adj ending 8")
			],[ # First person
				_INTL("1SG.M.FOR.NOM"),_INTL("1SG.M.FOR.ACC"),_INTL("1SG.M.FOR.GEN"),_INTL("1SG.M.FOR.DAT"),
				_INTL("1SG.M.FAM.NOM"),_INTL("1SG.M.FAM.ACC"),_INTL("1SG.M.FAM.GEN"),_INTL("1SG.M.FAM.DAT")
			],[ # Second person
				_INTL("2SG.M.FOR.NOM"),_INTL("2SG.M.FOR.ACC"),_INTL("2SG.M.FOR.GEN"),_INTL("2SG.M.FOR.DAT"),
				_INTL("2SG.M.FAM.NOM"),_INTL("2SG.M.FAM.ACC"),_INTL("2SG.M.FAM.GEN"),_INTL("2SG.M.FAM.DAT")
			],[ # Third person
				_INTL("3SG.M.FOR.NOM"),_INTL("3SG.M.FOR.ACC"),_INTL("3SG.M.FOR.GEN"),_INTL("3SG.M.FOR.DAT"),
				_INTL("3SG.M.FAM.NOM"),_INTL("3SG.M.FAM.ACC"),_INTL("3SG.M.FAM.GEN"),_INTL("3SG.M.FAM.DAT")
			]
		],[ # Feminine
			[ # 0 is used only for non-pronoun things, such as adjective endings
				_INTL("fem adj ending 1"),_INTL("fem adj ending 2"),_INTL("fem adj ending 3"),_INTL("fem adj ending 4"),
				_INTL("fem adj ending 5"),_INTL("fem adj ending 6"),_INTL("fem adj ending 7"),_INTL("fem adj ending 8")
			],[ # First person
				_INTL("1SG.F.FOR.NOM"),_INTL("1SG.F.FOR.ACC"),_INTL("1SG.F.FOR.GEN"),_INTL("1SG.F.FOR.DAT"),
				_INTL("1SG.F.FAM.NOM"),_INTL("1SG.F.FAM.ACC"),_INTL("1SG.F.FAM.GEN"),_INTL("1SG.F.FAM.DAT")
			],[ # Second person
				_INTL("2SG.F.FOR.NOM"),_INTL("2SG.F.FOR.ACC"),_INTL("2SG.F.FOR.GEN"),_INTL("2SG.F.FOR.DAT"),
				_INTL("2SG.F.FAM.NOM"),_INTL("2SG.F.FAM.ACC"),_INTL("2SG.F.FAM.GEN"),_INTL("2SG.F.FAM.DAT")
			],[ # Third person
				_INTL("3SG.F.FOR.NOM"),_INTL("3SG.F.FOR.ACC"),_INTL("3SG.F.FOR.GEN"),_INTL("3SG.F.FOR.DAT"),
				_INTL("3SG.F.FAM.NOM"),_INTL("3SG.F.FAM.ACC"),_INTL("3SG.F.FAM.GEN"),_INTL("3SG.F.FAM.DAT")
			]
		],[ # Neuter
			[ # 0 is used only for non-pronoun things, such as adjective endings
				_INTL("neutral adj ending 1"),_INTL("neutral adj ending 2"),_INTL("neutral adj ending 3"),_INTL("neutral adj ending 4"),
				_INTL("neutral adj ending 5"),_INTL("neutral adj ending 6"),_INTL("neutral adj ending 7"),_INTL("neutral adj ending 8")
			],[ # First person
				_INTL("1SG.N.FOR.NOM"),_INTL("1SG.N.FOR.ACC"),_INTL("1SG.N.FOR.GEN"),_INTL("1SG.N.FOR.DAT"),
				_INTL("1SG.N.FAM.NOM"),_INTL("1SG.N.FAM.ACC"),_INTL("1SG.N.FAM.GEN"),_INTL("1SG.N.FAM.DAT")
			],[ # Second person
				_INTL("2SG.N.FOR.NOM"),_INTL("2SG.N.FOR.ACC"),_INTL("2SG.N.FOR.GEN"),_INTL("2SG.N.FOR.DAT"),
				_INTL("2SG.N.FAM.NOM"),_INTL("2SG.N.FAM.ACC"),_INTL("2SG.N.FAM.GEN"),_INTL("2SG.N.FAM.DAT")
			],[ # Third person
				_INTL("3SG.N.FOR.NOM"),_INTL("3SG.N.FOR.ACC"),_INTL("3SG.N.FOR.GEN"),_INTL("3SG.N.FOR.DAT"),
				_INTL("3SG.N.FAM.NOM"),_INTL("3SG.N.FAM.ACC"),_INTL("3SG.N.FAM.GEN"),_INTL("3SG.N.FAM.DAT")
			]
		]
	][gender]
end

def anHasPokemonUprising
	return pbSaveTest("Pokemon Uprising","Exist",nil,18)
end