# Useful for televisions, but theoretically this kind of thing could be used for any message with some tweaking.
# It is based on the BW/B2W2 TVs, though instead of the channels being called Celebrity, Battle, and Variety, they have more traditional generic TV channel names.
# To use, put only Script: anTelevisionScript in all TV events that should display this.
# (Not all TVs need to display this script, after all, plus you may also use a page of a TV to display a specific broadcast for story progression. This is just for generic televisions.)
def anTelevisionScript
	# Select channel
	channels = [_INTL("News"),_INTL("Sports"),_INTL("Games")]
	cancelChannel = -1
	channelToDisplay = pbMessage(_INTL("Which channel would you like to view?"), channels, cancelChannel)
	case channelToDisplay
		when -1
			pbMessage(_INTL("Did not watch TV."))
			return nil
		when 0
			# Header
			pbMessage(_INTL("\\xn[Noti Sias]\\bHello from São Samba City. I'm Noti Sias-"))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\r-and this is Noti Ficaciones-"))
			pbMessage(_INTL("\\xn[Noti Sias]\\b-and this is the current news, delivered to you as it happens."))
			# Read the news
			anNewsChannelScript
			# Sign off
			pbMessage(_INTL("\\xn[Noti Sias]\\bWell, I'm Noti Sias-"))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\r-and this is Noti Ficaciones-"))
			pbMessage(_INTL("\\xn[Noti Sias]\\b-and we are signing off for now."))
			pbMessage(_INTL("\\xn[Both Notis]\\ySee you next time!"))
			return nil
		when 1
			anSportsChannelScript
			return nil
		when 2
			anGamesChannelScript
			return nil
	end
end

def anNewsChannelScript
	# If any roaming pokemon is present, talk about the sighting of one on their current map position
	roaming_list = anIsAnyRoamerOn?
	if roaming_list.length > 0 && rand(10) >= 5 # 50% chance to report on the roaming pokemon if one exists.
		# select a random roamer
		reporting_index = roaming_list.sample
		reporting_species = Settings::ROAMING_SPECIES[reporting_index]
		reporting_map_id = $PokemonGlobal.roamPosition[reporting_index]
		reporting_map_name = $MapFactory.get_map(reporting_map_id).name
		# actual report
		pbMessage(_INTL("\\xn[Noti Sias]\\bDid you hear? There has been a rare Pokémon sighting! It might even be a Legendary."))
		pbMessage(_INTL("\\xn[Noti Ficaciones]\\rWait, really? Who? Tell us!"))
		pbMessage(_INTL("\\xn[Noti Casio]\\bWell, last I saw, {1} was in {2}.",reporting_species, reporting_map_name))
		pbMessage(_INTL("\\xn[Noti Ficaciones]\\rOh wow... That's incredible."))
		return nil
	end
	
	
	# Main story-based news
	main_story_progress_position = $game_variables[990]
	case main_story_progress_position
		when 131..209 # Finished the Sorrel battle, to finishing the first Risen battle
			pbMessage(_INTL("\\xn[Noti Sias]\\bAlas, today for you I have some bad news... Noti?"))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rRecently, a group of strangely miscolored humanoid beings was spotted on Maracaleza Beach."))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rThey are currently being referred to as the Risen, as they have been seen rising from the sand like zombies."))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rTheir status as the living dead has not been confirmed however, but they do not seem to be capable of articulating words, only moaning and groaning."))
			pbMessage(_INTL("\\xn[Noti Sias]\\bSo basically, if you're in Maracaleza Town, you should bunker down for a bit?"))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rPrecisely. All Pokémon around the area have been running from them, and if it has even an Onsurround spooked, it isn't safe to mess with it."))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rThis is already being decried as the most prominent thing to occur in the relatively calm seaside resort since the boat crashes of 1520, but I don't think it's time to go that far yet."))
			pbMessage(_INTL("\\xn[Noti Sias]\\bThis is still very alarming, however... Hopefully they can be removed soon..."))
			return nil
		when 210..220 # Finished the first Sorrel battle, to finishing the Mona battle
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rBreaking news! But this time it's good."))
			pbMessage(_INTL("\\xn[Noti Sias]\\bOh? Please, tell the public."))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rThe Risen spotted in Maracaleza Town have dispersed."))
			pbMessage(_INTL("\\xn[Noti Sias]\\bOh! That is good news!"))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rMhm! There seems to be minimal damage, thankfully. Three unnamed Pokémon Trainers confronted a group of them at the beach, and they retreated into the sand they came from."))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rReporters tried to talk to one of them, a blue-haired boy, but he did not wish to speak."))
			pbMessage(_INTL("\\xn[Noti Sias]\\bOh damn... It would have been nice to hear his perspective."))
			pbMessage(_INTL("\\xn[Noti Ficaciones]\\rYeah, but ah well. That's the way news works - you gotta respect privacy and all that."))
			return nil
		when 400..410 # First Xibal event finished, to Sorrel battle
			return nil
	end
	
	# Generic news
	generic_stories = ["pokemon","robbery","disaster","weather","weather","weather","finance","finance"]
	generic_stories.push("traffic","traffic") if pbIsWeekday(-1,1,2,3,4,5) # Is Monday thru Friday
	generic_stories.push("traffic","movie") if pbIsWeekday(-1,0,6) # Is Saturday or Sunday
	generic_stories.push("parade","parade","sunset_league") if pbGetTimeNow.mday == 14..15 # Carnivals happen on the 14th and 15th of the month
	generic_stories.push("parade_prep") if pbGetTimeNow.mday == 12..13
	generic_stories.push("frontier","sunset_league","foreign_league") if pbGetTimeNow.mday != 14..15
	generic_stories.push("holiday") if anIsHoliday? > -1
	story_this_time = generic_stories.sample
	# Planned generic story templates:
	# Pokemon attack
	# Robbery
	# Natural disaster
	# Weather (weight 3)
	# Traffic (weight 2 if weekday, 1 otherwise)
	# Parade preparation (weight 2 if carnival is active, 0 otherwise)
	# Battle Frontier news (weight 0 if carnival is active, 1 otherwise)
	# Sunset League news (weight 1 if carnival is active, 2 otherwise)
	# Non-Sunset League news (weight 0 if carnival is active, 1 otherwise)
	# Movie release news (weight 0 if weekday, 1 otherwise)
	# Finance news (weight 2)
	case story_this_time
		# Truly generic news
		when "weather"
			return nil
		when "finance"
			return nil
		when "traffic"
			return nil
		# Crime news
		when "pokemon"
			return nil
		when "robbery"
			return nil
		when "disaster"
			return nil
		# League news (this should only be for Hall of Fame challenges and Championship Tournaments - individual Gym battles will be covered in the Sports channel)
		when "sunset_league"
			return nil
		when "foreign_league"
			return nil
		# Sports news (Parade is not included in sports channnel script, while Frontier should not focus on challenges as the Sports channel will probably cover that)
		when "parade"
			return nil
		when "parade_prep"
			return nil
		when "frontier"
			return nil
		# Other
		when "movie"
			return nil
		when "holiday"
			return nil
	end
end

def anSportsChannelScript
	sports_types = ["sunset_league","sunset_league","bug_contest","surfing","racing","pokeathlon","battle_frontier","galar_league","unova_league","paldea_league"]
	sport_this_time = sports_types.sample
	challenger = anRandomName
	gender = anRandomGender(challenger)
	elite_four = false
	case sport_this_time
		when "sunset_league"
			leaders = [_INTL("Aria"),_INTL("Desiree"),_INTL("Diego"),_INTL("Katy"),
			              _INTL("Neka"),_INTL("Rayann"),_INTL("Enrique"),_INTL("Arthur"),
						  _INTL("Akita"),_INTL("Fritz"),_INTL("Sauta"),_INTL("Mateo"),
			              _INTL("Virgo"),_INTL("Amber"),_INTL("Vergil"),_INTL("Rivola")]
			elite_four = [_INTL("Palmer"),_INTL("Astley"),_INTL("Bankoro"),_INTL("Rusty"),_INTL("Anemone")]
			if rand(5) == 0 # 1/5 chance to use E4 instead of a Gym Leader
				trainer_battled = rand(elite_four.length)
				elite_four = true
				location = _INTL("Vitori Pikta")
			else
				trainer_battled = rand(leaders.length)
				location = [_INTL("Alipigra Gym"),_INTL("Rocavideo Gym"),_INTL("Frenaval Gym"),_INTL("Tangoseiro Gym"),_INTL("Hirihopa Gym"),
						      _INTL("Sitares Cantus Cathedral"),_INTL("São Samba Gym"),_INTL("Veriachi Gym"),_INTL("Maracaleza Gym"),_INTL("Lyra Alley"),
						      _INTL("Torchton Steak"),_INTL("Nova Cancioba Gym"),_INTL("Forroxada Gym"),_INTL("Choraçu Gym"),_INTL("Route 12"),
							  _INTL("Popasaha Stadium")][trainer_battled]
			end
			pbMessage(_INTL("\\xn[Boleta]\\rAhah, so here we see {{1}} in {{2}}...",challenger,location))
			return nil
		when "galar_league"
			leaders = [_INTL("Milo"),_INTL("Nessa"),_INTL("Kabu"),_INTL("Bea"),_INTL("Allister"),
			              _INTL("Bede"),_INTL("Melony"),_INTL("Gordie"),_INTL("Marnie"),_INTL("Raihan"),
						  _INTL("Klara"),_INTL("Avery")]
			# No elite four for Galar
			elite_four = []
			trainer_battled = rand(leaders.length)
			location = [_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),
			              _INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),
						  _INTL("?"),_INTL("?")][trainer_battled]
			return nil
		when "unova_league"
			leaders = [_INTL("Cheren"),_INTL("Roxie"),_INTL("Burgh"),_INTL("Elesa"),
			              _INTL("Clay"),_INTL("Skyla"),_INTL("Drayden"),_INTL("Marlon"),
						  _INTL("Chili"),_INTL("Cilan"),_INTL("Cress")]
			elite_four = [_INTL("Shauntal"),_INTL("Grimsley"),_INTL("Caitlin"),_INTL("Marshall"),_INTL("Iris")]
			if rand(5) == 0 # 1/5 chance to use E4 instead of a Gym Leader
				trainer_battled = rand(elite_four.length)
				elite_four = true
				location = _INTL("Unova League")
			else
				trainer_battled = rand(leaders.length)
				location = [_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),
			                  _INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),
						      _INTL("?"),_INTL("?")][trainer_battled]
			end
			return nil
		when "paldea_league"
			leaders = [_INTL("Katy"),_INTL("Brassius"),_INTL("Iono"),_INTL("Kofu"),
			              _INTL("Larry"),_INTL("Ryme"),_INTL("Grusha"),_INTL("Tulip")]
			elite_four = [_INTL("Rika"),_INTL("Poppy"),_INTL("Larry"),_INTL("Hassel"),_INTL("Geeta")]
			if rand(5) == 0 # 1/5 chance to use E4 instead of a Gym Leader
				trainer_battled = rand(elite_four.length)
				elite_four = true
				location = _INTL("Unova League")
			else
				trainer_battled = rand(leaders.length)
				location = [_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),
			                  _INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),_INTL("?"),
						      _INTL("?"),_INTL("?")][trainer_battled]
			end
			return nil
		when "battle_frontier"
			frontier_brains = [_INTL("Dahlia"),_INTL("Kamil"),_INTL("Trevor"),_INTL("Diamante"),_INTL("Monika")]
			trainer_battled = rand(frontier_brains.length)
			case trainer_battled
				when 0 # Dahlia
					location = _INTL("Battle Arcade")
				when 1 # Kamil
					location = _INTL("Battle Stadium")
				when 2 # Trevor
					location = _INTL("Battle Factory")
				when 3 # Diamante
					location = _INTL("Battle Valley")
				when 4 # Monika
					location = _INTL("Battle Dungeon")
			end
			return nil
		when "surfing"
			location = [_INTL("Maracaleza Beach"),_INTL("Bossanova River"),_INTL("Paragonas River"),_INTL("Iguana River"),_INTL("Sao Samba Seaboard")]
			return nil
		when "racing"
			location = [_INTL("Rua Octava"),_INTL("Rocavideo Highlands"),_INTL("Mato Diamante")]
			return nil
		when "bug_contest"
			location = _INTL("Forroxada Town")
			return nil
	end
	return nil
end

def anGamesChannelScript
	return nil
end