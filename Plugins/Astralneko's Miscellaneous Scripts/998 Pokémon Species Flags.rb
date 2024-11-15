# Getting at the species flags
def anSpeciesFlags(pkmn)
	if pkmn.is_a?(Pokemon)
		return GameData::Species.get(pkmn.species).flags
	elsif pkmn.is_a?(Battler)
		return GameData::Species.get(pkmn.pokemon.species).flags
	elsif pkmn.is_a?(Symbol)
		return "" if !GameData::Species.exists?(pkmn)
		return GameData::Species.get(pkmn).flags
	end
end

# Tag ideas:
# c = Chimera (unused in the AN series until Ultraviolet/Infrared)
# f = Flying (unused in the AN series unless sky battles are introduced)
# k = Cute (unused, from かわいい, based on Amity Square)
# l = Legendary
# m = Mythical
# p = Paradox
# s = Starter (NOTE: THIS DIFFERS FROM "FIRST PARTNER POKÉMON" - Starter Pokémon are a subclass of first partner Pokémon that do not have TM Materials in Scarlet and Violet, which is basically the entire point of this species flag)
# t = Special (from 特別; this bans a Pokémon from most battle facilities)
# u = Ultra Beast
def anIsSubLegendary?(pkmn); return anSpeciesFlags(pkmn)[/[pu]/] && !anSpeciesFlags(pkmn)[/[lmt]/]; end
def anHasTMMaterials?(pkmn); return !anSpeciesFlags(pkmn)[/[lmpsu]/]; end # Paradox Pokémon, Legendary Pokémon, Mythical Pokémon, and starters do not have TM Materials in SV, it's safe to say Ultra Beasts would be included in that category
def anIsUltraBeast?(pkmn); return anSpeciesFlags(pkmn)[/u/]; end
def anIsParadox?(pkmn); return anSpeciesFlags(pkmn)[/p/]; end
def anIsLegendary?(pkmn); return anSpeciesFlags(pkmn)[/l/]; end
def anIsMythical?(pkmn); return anSpeciesFlags(pkmn)[/m/]; end
def anIsSpecial?(pkmn); return anSpeciesFlags(pkmn)[/t/]; end
def anIsStarter?(pkmn); return anSpeciesFlags(pkmn)[/s/]; end