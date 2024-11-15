#===============================================================================
#  Methods to determine a pokemon's tera type
#===============================================================================
# Determine the default tera type for this type combination
# Types are in an array
def anDefaultTeraType(types)
	if types.length == 1
		# Return primary type if no secondary type - anything else would make the type change
		return types[0]
	else
		# If either type is banned, return the other type
		return types[0] if AstralnekoConfig::BANNED_TERA_TYPES.include?(types[1])
		return types[1] if AstralnekoConfig::BANNED_TERA_TYPES.include?(types[0])
		# Otherwise return a random type
		return types.sample
	end
end

# Select a random tera type
def anRandomTeraType
	types = []
	GameData::Type.each { |t| types.push(t.id) if !t.pseudo_type && ! AstralnekoConfig::BANNED_TERA_TYPES.include?(t.id)}
	types.push(:STELLAR) if GameData::Type.exists?(:STELLAR) && $game_switches[AstralnekoConfig::STELLAR_UNLOCKED_SWITCH]
	return types.sample
end

# Get the full list of all valid Tera Types
def anPossibleTeraTypes
	types = []
	GameData::Type.each { |t| types.push(t.id) if !t.pseudo_type && ! AstralnekoConfig::BANNED_TERA_TYPES.include?(t.id)}
	return types
end


#===============================================================================
#  Additions to the Pokemon class for additional functionality
#===============================================================================
class Pokemon
	attr_accessor :tera_type, :terastalized
	
	def terastalized?
		return @terastalized
	end
	
	def terastalAble?
		return false if egg? || shadowPokemon?
		return true
	end
	
	def terastalize
		@terastalized = true
	end
	
	def unterastalize
		@terastalized = false
	end
	
	# Has unique Tera Type
	# You could use this to set tera type in a loop to ensure it's not a normal one for this species
	def hasUniqueTeraType?
		return !types.include?(@tera_type)
	end
	
	# Forces the user to have a certain Tera Type
	# Named such because "make this Pokémon Tera (type)" is what this function does
	def makeTera(newType)
		@tera_type = newType
	end
	
	# Can this Pokémon's Tera Type be changed normally?
	def canChangeTeraType?
		return !AstralnekoConfig::TERA_TYPE_CHANGE_BANNED.include?(self.species)
	end
	
	# Initialize tera types
	alias initialize_astraltera initialize unless self.method_defined?(:initialize_astraltera)
	def initialize(*args)
		initialize_astraltera(*args)
		@tera_type = rand(100000).to_r/1000r > AstralnekoConfig::SPECIAL_TERA_CHANCE ? anRandomTeraType : anDefaultTeraType(self.types)
		@tera_type = :NORMAL if self.species == :TERAPAGOS
		@tera_type = :FAIRY if self.species == :OGERPON
	end
end
