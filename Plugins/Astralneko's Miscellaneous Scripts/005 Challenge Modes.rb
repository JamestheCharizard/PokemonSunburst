#module Settings
#    # The Switch that when ON, turns on Genwunner Mode.
#    GENWUNNER_MODE_SWITCH = 100
#end
#  
#class PokeBattle_Move
#  
#  alias pbAccuracyCheck_normal pbAccuracyCheck
#  def pbAccuracyCheck(user,target)
#    if $game_switches[Settings::GENWUNNER_MODE_SWITCH]
#      # "Always hit" effects and "always hit" accuracy
#      return true if target.effects[PBEffects::Telekinesis]>0
#      return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
#      baseAcc = pbBaseAccuracy(user,target)
#      return true if baseAcc==0
#      # Calculate all multiplier effects
#      modifiers = {}
#      modifiers[:base_accuracy]  = baseAcc
#      modifiers[:accuracy_stage] = user.stages[:ACCURACY]
#      modifiers[:evasion_stage]  = target.stages[:EVASION]
#      modifiers[:accuracy_multiplier] = 1.0
#      modifiers[:evasion_multiplier]  = 1.0
#      pbCalcAccuracyModifiers(user,target,modifiers)
#      # Check if move can't miss
#      return true if modifiers[:base_accuracy] == 0
#      # Calculation
#      accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
#      evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
#      stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
#      stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
#      accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
#      evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
#      accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
#      evasion  = (evasion  * modifiers[:evasion_multiplier]).round
#      evasion = 1 if evasion < 1
#      # Calculation
#      ret = @battle.pbRandom(100) < modifiers[:base_accuracy] * accuracy / evasion * 255 / 256 # Gen 1 Miss
#      return ret
#    else
#      return pbAccuracyCheck_normal(user,target)
#    end
#  end
#end