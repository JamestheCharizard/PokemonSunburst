################################################################################
# 
# Z-Moves are defined in Z-Move Effects.rb.
# 
################################################################################

#===============================================================================
# Life Steal
#===============================================================================
# User gains all the HP it inflicts as damage.
#-------------------------------------------------------------------------------
class Battle::Move::HealUserByDamageDone < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
    super
  end
end

#===============================================================================
# (old 781)
#===============================================================================
# Decreases the target's Special Attack by 2 stages.
#-------------------------------------------------------------------------------
class Battle::Move::LowerTargetSpAtk2 < Battle::Move::TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,2]
  end
end

#===============================================================================
# Ground Zero
#===============================================================================
# For 5 rounds, creates irradiated terrain which boosts Poison-type moves and
# boosts poison damage. Affects non-airborne Pokémon only.
#-------------------------------------------------------------------------------
class Battle::Move::StartIrradiatedTerrain < Battle::Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain == :Poison
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Poison)
  end
end

#===============================================================================
# Spirit Realm
#===============================================================================
# For 5 rounds, creates spirit terrain which boosts Ghost-type moves and
# debuffs Normal-type moves. Affects non-airborne Pokémon only.
#-------------------------------------------------------------------------------
class Battle::Move::StartIrradiatedTerrain < Battle::Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain == :Spirit
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Spirit)
  end
end

#===============================================================================
# Star Mash
#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations.
#-------------------------------------------------------------------------------
class Battle::Move::UseTargetSpDefInsteadOfDefense < PokeBattle_Move
  def pbGetDefenseStats(user,target)
    return target.spdef, target.stages[:SPECIAL_DEFENSE] + Battle::Battler::STAT_STAGE_MAXIMUM
  end
end

#===============================================================================
# Overdose
#===============================================================================
# Heals the first time. Deals massive damage if used again directly after.
#-------------------------------------------------------------------------------
class Battle::Move::ApplyOverdoseCondition < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Overdose]==0
      opponent.pbRecoverHP(((opponent.totalHP+1)/2.0).floor,true)
      opponent.effects[PBEffects::Overdose]=2
      return 0
    else
      opponent.effects[PBEffects::Overdose]=0
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

#===============================================================================
# Event Horizon
#===============================================================================
# User is protected against moves that target it this round. Faints the user
# of a stopped contact move.
# When used, the user loses 1/4 of their maximum HP.
#-------------------------------------------------------------------------------
class Battle::Move::ProtectUserEventHorizon < Battle::Move::ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::EventHorizon
  end
  
  def pbOnStartUse(user,targets)
    user.pbReduceHP(user.totalhp/4,false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# (old 787)
#===============================================================================
# Hits 1-2 times.
#-------------------------------------------------------------------------------
class Battle::Move::HitOneToTwoTimes < Battle::Move
  def multiHitMove?;            return true; end

  def pbNumHits(user, targets)
    hitchances=[1,1,2]
    ret=hitchances[@battle.pbRandom(hitchances.length)]
    ret=2 if user.hasActiveAbility?(:SKILLLINK)
    return ret
  end
end

#===============================================================================
# (old 788)
#===============================================================================
# Hits 1-3 times.
#-------------------------------------------------------------------------------
class Battle::Move::HitOneToThreeTimes < Battle::Move
  def multiHitMove?;            return true; end

  def pbNumHits(user, targets)
    hitchances=[1,1,2,2,3]
    ret=hitchances[@battle.pbRandom(hitchances.length)]
    ret=3 if user.hasActiveAbility?(:SKILLLINK)
    return ret
  end
end

#===============================================================================
# Magnadisk
#===============================================================================
# If the target is on the same side as the user, protects them. Renders user
# as not having Levitate.
#-------------------------------------------------------------------------------
class Battle::Move::ProtectUserMagnadisk < Battle::Move::ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Magnadisk
  end
end