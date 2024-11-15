module AstralnekoConfig
	# Chance that a given pokemon is a "Special Tera Type"
	# (Has a tera type that doesn't maintain the type of the vanilla species)
	# Is a percentage, precise to 3 decimal points; keep the r
	SPECIAL_TERA_CHANCE = 1.25r
	
	# Types that cannot be Tera Types
	BANNED_TERA_TYPES = [:QMARKS]
	
	# HSL values to re-tone pokemon sprites
	# Use format as follows:
	# :TYPE_IN_ALL_CAPS => [hue,saturation,lightness]
	# Hue is between 0-360, s/l is a decimal between -1 and 1
	# Image's hue is set to new hue, while saturation and lightness are added to by S and L
	TERA_TYPE_COLORS = {
		:NORMAL =>    [0xAF,0xA8,0x8F],
		:FIGHTING =>  [0xCA,0x65,0x5D],
		:FLYING =>    [0xAE,0x9F,0xB8],
		:POISON =>    [0xC0,0x81,0xBA],
		:GROUND =>    [0xBE,0xAD,0x79],
		:ROCK =>      [0xB7,0xA4,0x58],
		:BUG =>       [0xB3,0xC4,0x60],
		:GHOST =>     [0x8C,0x76,0xA3],
		:STEEL =>     [0x8F,0x8F,0x8F],
		:FIRE =>      [0xD3,0x84,0x4F],
		:WATER =>     [0x57,0x8C,0xD4],
		:GRASS =>     [0x8C,0xCE,0x6C],
		:ELECTRIC =>  [0xD3,0xC8,0x60],
		:PSYCHIC =>   [0xDA,0x6D,0x91],
		:ICE =>       [0x84,0xBD,0xBC],
		:DRAGON =>    [0x7E,0x70,0xC9],
		:DARK =>      [0x91,0x81,0x70],
		:FAIRY =>     [0xC8,0x79,0xA7],
		:CELESTIAL => [0xAA,0x41,0xD6],
		:GLITCH =>    [0x35,0xCF,0x8E]
	}
	
	# Items that function as a Tera Orb in battle
	TERA_ORBS = [:ZRING,:ZPOWERRING]
	
	# Game switch that bans Terastalization
	NO_TERASTAL = 108
	# Game Switch number that unlocks the Stellar Tera Type
	STELLAR_UNLOCKED_SWITCH = 110
	
	# Bans type change for the following species
	TERA_TYPE_CHANGE_BANNED = [:OGERPON,:TERAPAGOS]

	# Unban the following categories
	CRAFTING_BANS_IGNORE_STARTERS    = false
	CRAFTING_BANS_IGNORE_LEGENDARIES = false
	CRAFTING_BANS_IGNORE_OTHERS      = false
	
	# Base form starters
	# (may remove if adding starter TM materials)
	STARTER_SPECIES = [
		# Kanto
		:BULBASAUR, :CHARMANDER,:SQUIRTLE,
		# Johto
		:CHIKORITA, :CYNDAQUIL, :TOTODILE,
		# Hoenn
		:TREECKO,   :TORCHIC,   :MUDKIP,
		# Sinnoh
		:TURTWIG,   :CHIMCHAR,  :PIPLUP,
		# Unova
		:SNIVY,     :TEPIG,     :OSHAWOTT,
		# Kalos
		:CHESPIN,   :FENNEKIN,  :FROAKIE,
		# Alola
		:ROWLET,    :LITTEN,    :POPPLIO,
		# Galar
		:GROOKEY,   :SCORBUNNY, :SOBBLE,
		# Paldea
		:SPRIGATITO,:FUECOCO,   :QUAXLY,
		# Verela
		:ANGEAL,    :RADIOSO,   :TEMPIXIE
	]
	
	# Legendary and Mythical Pokémon
	LEGENDARY_SPECIES = [
		# Kanto
		:ARTICUNO,  :ZAPDOS,   :MOLTRES,   :MEWTWO,     :MEW,
		# Johto
		:ENTEI,     :RAIKOU,   :SUICUNE,   :HOOH,       :LUGIA,
		:CELEBI,
		# Hoenn
		:REGIROCK,  :REGICE,   :REGISTEEL, :LATIAS,     :LATIOS,
		:GROUDON,   :KYOGRE,   :RAYQUAZA,  :JIRACHI,    :DEOXYS,
		# Sinnoh
		:UXIE,      :MESPRIT,  :AZELF,     :DIALGA,     :PALKIA,
		:GIRATINA,  :CRESSELIA,:HEATRAN,   :REGIGIGAS,  :MANAPHY,
		:PHIONE,    :SHAYMIN,  :ARCEUS,
		# Unova
		:COBALION,  :TERRAKION,:VIRIZION,  :TORNADUS,   :THUNDURUS,
		:LANDORUS,  :ZEKROM,   :RESHIRAM,  :KYUREM,     :VICTINI,
		:KELDEO,    :MELOETTA, :GENESECT,
		# Kalos
		:XERNEAS,   :YVELTAL,  :ZYGARDE,   :DIANCIE,    :HOOPA,
		:VOLCANION,
		# Alola
		:TYPENULL,  :SILVALLY, :TAPUKOKO,  :TAPULELE,   :TAPUBULU,
		:TAPUFINI,  :COSMOG,   :COSMOEM,   :SOLGALEO,   :LUNALA,
		:NECROZMA,  :MAGEARNA, :MARSHADOW, :ZERAORA,    :MELTAN,
		:MELMETAL,
		# Galar
		:ZACIAN,    :ZAMAZENTA,:ETERNATUS, :KUBFU,      :URSHIFU,
		:REGIELEKI, :REGIDRAGO,:GLASTRIER, :SPECTRIER,  :CALYREX,
		:ENAMORUS,  :ZARUDE,
		# Paldea
		:KORAIDON,  :MIRAIDON, :WOCHIEN,   :CHIENPAO,   :TINGLU,
		:CHIYU,     :OKIDOGI,  :MUNKIDORI, :FEZANDIPITI,:OGERPON,
		:TERAPAGOS, :PECHARUNT,
		# Verela
		:PARTAZURA, :DAROSEIKU,:BERANTEGON,:DIURAGON,   :VERNACHT,
		:CROWZOATCH,:AXOBALTL, :ITZAIMAN,  :CHUPANIDA,  :TENJIAU,
		:YATAHAGI,  :DIWACUCHA,:KACHILIDA, :NEMESETA
	]
	
	# Others (Paradoxes and UBs)
	OTHER_UNCRAFTABLES_SPECIES = [
		# Ultra Beasts
		:NIHILEGO,   :BUZZWOLE,   :PHEROMOSA,  :XURKITREE,  :CELESTEELA,
		:KARTANA,    :GUZZLORD,   :POIPOLE,    :NAGANADEL,  :STAKATAKA,
		:BLACEPHALON,
		# Paradox Pokémon
		:GREATTUSK,  :SCREAMTAIL, :BRUTEBONNET,:FLUTTERMANE,:SLITHERWING,
		:SANDYSHOCKS,:ROARINGMOON,:IRONTREADS, :IRONBUNDLE, :IRONHANDS,
		:IRONJUGULIS,:IRONMOTH,   :IRONTHORNS, :IRONVALIANT,:WALKINGWAKE,
		:IRONLEAVES, :GOUGINGFIRE,:RAGINGBOLT, :IRONBOULDER,:IRONCROWN
	]
end