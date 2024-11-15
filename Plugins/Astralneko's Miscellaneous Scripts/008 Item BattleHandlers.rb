################################################################################
# 
# New Item/Pokeball AbilityEffects.
# 
################################################################################

#===============================================================================
# Pokeball handlers
#===============================================================================
Battle::PokeBallEffects::ModifyCatchRate.add(:JETBALL,proc { |ball,catchRate,battle,battler|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 3.5 : 3
  catchRate *= multiplier if battler.pbHasType?(:FLYING) || battler.ability == :LEVITATE
  next catchRate
})

Battle::PokeBallEffects::ModifyCatchRate.add(:STRANGEBALL,proc { |ball,catchRate,battle,battler|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 3.5 : 3
  catchRate *= multiplier if battler.pbHasType?(:GLITCH)
  next catchRate
})

Battle::PokeBallEffects::ModifyCatchRate.add(:STELLARBALL,proc { |ball,catchRate,battle,battler|
  multiplier = 4
  catchRate *= multiplier if battler.terastalized? || anIsParadox?(battler)
  next catchRate
})

#===============================================================================
# DamageCalcFromUser handlers
#===============================================================================
Battle::ItemEffects::DamageCalcFromUser.add(:CELESTIALGEM,
  proc { |item,user,target,move,mults,power,type|
    user.pbMoveTypePoweringUpGem(:CELESTIAL,move,type,mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GLITCHGEM,
  proc { |item,user,target,move,mults,power,type|
    user.pbMoveTypePoweringUpGem(:GLITCH,move,type,mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:NEBULAFRAGMENT,
  proc { |item,user,target,move,mults,power,type|
    mults[:base_damage_multiplier] *= 1.2 if type == :CELESTIAL
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:NEBULAFRAGMENT,:STARRYPLATE)

#===============================================================================
# DamageCalcFromTarget handlers
# NOTE: Species-specific held items consider the original species, not the
#       transformed species, and still work while transformed. The exceptions
#       are Metal/Quick Powder, which don't work if the holder is transformed.
#===============================================================================
Battle::ItemEffects::DamageCalcFromTarget.add(:NACHNABERRY,
  proc { |item,user,target,move,mults,power,type|
    target.pbMoveTypeWeakeningBerry(:CELESTIAL, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:GRANATCHBERRY,
  proc { |item,user,target,move,mults,power,type|
    target.pbMoveTypeWeakeningBerry(:GLITCH, type, mults)
  }
)

#===============================================================================
# OnSwitchIn handlers
#===============================================================================
Battle::ItemEffects::OnSwitchIn.add(:APUTRIGGER,
  proc { |item,battler,battle|
    battle.pbCommonAnimation("UseItem",battler)
    case battler.species
      when :VESPIQUEN
        battler.effects[PBEffects::ApuRevival] = 2
        battler.pbRaiseStatStageByCause(:SPEED,1,battler,battler.itemName,true,true)
      when :MEOWSCARADA
        battler.effects[PBEffects::ApuRevival] = 1
        battler.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,battler,battler.itemName,true,true)
        battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,battler,battler.itemName,true,true)
      when :MARASAGI
        battler.effects[PBEffects::ApuRevival] = 1
        battler.pbRaiseStatStageByCause(:DEFENSE,1,battler,battler.itemName,true,true)
    end
    battler.pbConsumeItem
  }
)