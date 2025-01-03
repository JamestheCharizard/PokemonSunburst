################################################################################
# 
# New PBEffects.
# 
################################################################################


module PBEffects
  #===========================================================================
  # These effects apply to a battler
  #===========================================================================
  ApuRevival          = 120
  Overdose            = 121
  EventHorizon        = 122
  Magnadisk           = 123
  Defibrilate         = 124
  ResilienceDamage    = 125
  ChromaBlast         = 126
  # Note: ZUD uses effects 200-215
	
	#=============================================================================
  # These effects apply to a side
  #=============================================================================
  IceSpikes          = 822
  # Note: ZUD uses effects 830-835
end

#-------------------------------------------------------------------------------
# New effects and values to be added to the debug menu.
#-------------------------------------------------------------------------------
module Battle::DebugVariables
  BATTLER_EFFECTS[PBEffects::ApuRevival]   = { name: "The number of additional healthbars on this Pokémon", default: 0 }
  BATTLER_EFFECTS[PBEffects::EventHorizon]   = { name: "Event Horizon applies this round", default: false }
  BATTLER_EFFECTS[PBEffects::Magnadisk]   = { name: "Magnadisk applies this round", default: false }
  BATTLER_EFFECTS[PBEffects::Defibrilate]   = { name: "Defibrilate applies this round", default: false }
	# PBEffects::ResilienceDamage - not suitable for setting via debug
  BATTLER_EFFECTS[PBEffects::ChromaBlast]   = { name: "Chroma Blast has removed self's secondary type", default: false }
  SIDE_EFFECTS[PBEffects::IceSpikes]  = { name: "Ice Spikes layers (0-2)", default: 0 }
end

#-------------------------------------------------------------------------------
# Initialize new effects and values to be added to the debug menu.
#-------------------------------------------------------------------------------
class Battle::Battler
  alias astaryuu_pbInitEffects pbInitEffects
  def pbInitEffects(batonPass)
		if batonPass
      # These effects are passed on if Baton Pass is used, but they need to be
      # reapplied
		else
      # These effects are passed on if Baton Pass is used
			@effects[PBEffects::Overdose]            = 0
		end
    astaryuu_pbInitEffects(batonPass)
    @effects[PBEffects::ApuRevival]          = 0
    @effects[PBEffects::EventHorizon]        = false
    @effects[PBEffects::Defibrilate]         = false
    @effects[PBEffects::Magnadisk]           = false
    @effects[PBEffects::ResilienceDamage]    = 0
    @effects[PBEffects::ChromaBlast]         = false
  end
	
	##############################################################################
  # Related to battler typing.
  ##############################################################################
	
	
  #-----------------------------------------------------------------------------
  # Aliased for Chroma Blast effect.
  #-----------------------------------------------------------------------------
  alias astaryuu_pbTypes pbTypes
  def pbTypes(withType3 = false)
    ret = astaryuu_pbTypes(withType3)
    ret.delete(@type2) if @effects[PBEffects::ChromaBlast]
    return ret
  end
  
  alias astaryuu_pbChangeTypes pbChangeTypes
  def pbChangeTypes(newType)
    astaryuu_pbChangeTypes(newType)
    @effects[PBEffects::ChromaBlast] = false
    if abilityActive? && @proteanTrigger # Protean/Libero
      Battle::AbilityEffects.triggerOnTypeChange(self.ability, self, newType)
    end 
  end

  alias astaryuu_pbResetTypes pbResetTypes
  def pbResetTypes
    astaryuu_pbResetTypes
    @effects[PBEffects::ChromaBlast] = false
  end
end

#-------------------------------------------------------------------------------
# Initialize new effects and values to be added to the debug menu.
#-------------------------------------------------------------------------------
class Battle::ActiveSide
  attr_accessor :effects

	alias astaryuu_initialize initialize
  def initialize
    astaryuu_initialize
    @effects[PBEffects::IceSpikes]          = 0
  end
end