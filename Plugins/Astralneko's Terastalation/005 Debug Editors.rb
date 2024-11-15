#===============================================================================
# Adds Terastal debug tools to the Level/Stats menu.
#===============================================================================
PokemonDebugMenuCommands.register("terastal", {
  "parent"      => "levelstats",
  "name"        => _INTL("Terastal..."),
  "always_show" => defined?(Settings::ZUD_COMPAT),
  "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if !pkmn.egg? && !pkmn.shadowPokemon? && pkmn.terastalAble?
      cmd = 0
      loop do
        teratype = pkmn.tera_type
        cmd = screen.pbShowCommands(_INTL("Tera Type: {1}",teratype),[
             _INTL("Set Tera Type"),
             _INTL("Reset All")],cmd)
        break if cmd<0
        case cmd
        when 0   # Set Tera Type
          f =  pbChooseTypeList(pkmn.tera_type){ screen.pbUpdate }
          if f!=pkmn.tera_type
            pkmn.tera_type = f
            pkmn.calc_stats
            screen.pbRefreshSingle(pkmnid)
          end
        when 1   # Reset All
          pkmn.makeTera(anDefaultTeraType(pkmn.types))
          screen.pbDisplay(_INTL("All Terastal settings restored to default."))
          screen.pbRefreshSingle(pkmnid)
        end
      end
    else
      screen.pbDisplay(_INTL("Can't edit Terastal values on that Pokémon."))
      pkmn.makeTera(anDefaultTeraType(pkmn.types))
    end
    next false
  }
})