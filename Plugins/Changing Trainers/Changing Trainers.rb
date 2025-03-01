#============================================================================================
# This is the basis of a trainer modifier. It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
#--------------------------------------------------------------------------------------------
# This is the main code. Head to the bottom to create your own changing trainers.
#
# Instead of Trainer.battle, you'll used changingTrainerBattle.
#============================================================================================

class ModifiablePokemonData
  attr_accessor :species, :form, :position, :level, :gender, :ability, :poke_ball, :item, :moves, :evs, :ivs

  def initialize(species:, form: 0, position: nil, level: nil, gender: nil, ability: nil, poke_ball: nil, item: nil, moves: [], evs: nil, ivs: nil)
    @species = species
    @form = form
    @position = position
    @level = level
    @gender = gender
    @ability = ability
    @poke_ball = poke_ball
    @item = item
    @moves = moves
    @evs = evs || [0, 0, 0, 0, 0, 0]
    @ivs = ivs || [31, 31, 31, 31, 31, 31]
  end
end

class ModifiableTrainerData
  attr_accessor :trainer_type, :name, :version, :map_id, :lose_text, :items, :pokemon_count, :pokemon_slots

  def initialize(trainer_type:, name:, version:, map_id: $game_map.map_id, lose_text: "You win!", items: [], pokemon_count: 1, pokemon_slots: [])
    @trainer_type = trainer_type
    @name = name
    @version = version
    @map_id = map_id
    @lose_text = lose_text
    @items = items
    @pokemon_count = pokemon_count
    @pokemon_slots = pokemon_slots
  end
end

def changingTrainerBattle(*args)
  trainers = []
  cnt = 1
  cnt = args.length / 3 if args.length > 3
  for ou in 0...cnt
    trainer = NPCTrainer.new(args[1+ou*3], args[0+ou*3], args[2+ou*3])
    changingTrainer = "N/A"
    CHANGERTRAINERS.each do |trnr|
      next if trnr.trainer_type != trainer.trainer_type
      next if trnr.name != trainer.name
      next if trnr.version != trainer.version
      next if trnr.map_id != $game_map.map_id
      changingTrainer = trnr
      break
    end
    return if changingTrainer == "N/A"
    trainer.lose_text = changingTrainer.lose_text
    trainer.items = changingTrainer.items
    trainer.id = $player.make_foreign_ID
    used_pokemon = []
    for index in 0...changingTrainer.pokemon_count
      slot_options = changingTrainer.pokemon_slots.flatten
      next unless slot_options
      valid_options = slot_options.select do |data|
        !used_pokemon.include?(data) && (data.position.nil? || data.position.include?(index))
      end
      if valid_options.empty?
        valid_options = slot_options.select do |data|
          !used_pokemon.include?(data) && (data.position.nil? || data.position.all? { |pos| pos >= index })
        end
      end
      break if valid_options.empty?
      species_data = valid_options.sample
      next unless species_data
      used_pokemon << species_data
      pkmn = Pokemon.new(species_data.species,species_data.level,trainer,false)
      pkmn.form = species_data.form
      if species_data.gender
        case species_data.gender
        when "M", "m"
          pkmn.gender = 0
        when "F", "f"
          pkmn.gender = 1
        else
          pkmn.gender = 2
        end
      end
      pkmn.ability = species_data.ability if species_data.ability
      pkmn.poke_ball = species_data.poke_ball if species_data.poke_ball
      pkmn.item = species_data.item if species_data.item
      if species_data.moves
        species_data.moves.each { |move| pkmn.learn_move(move) }
      end
      if species_data.evs
        [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE].each_with_index do |stat, i|
          pkmn.ev[stat] = species_data.evs[i]
        end
      end
      if species_data.ivs
        [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE].each_with_index do |stat, i|
          pkmn.iv[stat] = species_data.ivs[i]
        end
      end
      trainer.party.push(pkmn)
    end
    trainers.append(trainer)
  end
  if trainers.length == 1
    return TrainerBattle.start(trainer)
  elsif trainers.length == 2
    return TrainerBattle.start(trainers[0],trainers[1])
  elsif trainers.length == 3
    return TrainerBattle.start(trainers[0],trainers[1],trainers[2])
  end
end

#============================================================================================
# Where trainers are customized. You still need to create basic information of 
# the trainer in the trainer.txt file for everything from trainer ID to their 
# items. You also need to give them Pokémon as a Pokémon count is still needed.
# Just put in something like Unown for each slot at level 1. It doesn't matter
# as it'll be changed on the trainer battle starting.
#--------------------------------------------------------------------------------------------
# ModifiableTrainerData:
# trainer_type = ID of the trainer. For example, :YOUNGSTER.
# name = Trainer's name. For example, "Joey".
# version = The version number. Different versions can have different items, lose text, etc.
# map_id = What map_id you fight this version of the trainer on. Allows for instances where 
# the same trainer has different team members depending on what map you fight them on.
# lose_text = What the trainer says on losing against the player.
# items = An array of items the use has.
# pokemon_count = The number of Pokémon the trainer uses.
# pokemon_slots = All of the possible Pokémon for that battle.
# 
# 
# ModifiablePokemonData:
# species: The species of the Pokémon.
# form: The form of the Pokémon.
# position: Where the Pokémon might be in the party. For example, if you put [0,1] for Pikachu,
# that means that Pikachu can show up in slot 0 or slot 1. nil means it can be in any slot.
# level: Level of the Pokémon. You can use functions like rand() if you want a range.
# gender: "m" = male, "f" = female, anything else is genderless.
# ability: The ability of the Pokémon.
# poke_ball: The ball of the Pokémon.
# item: The item of the Pokémon.
# moves: An array of moves for the Pokémon.
# evs: An array of EVs in the order HP, Attack, Defense, Speed, Special Attack, Special Defense.
# ivs: An array of IVs in the order HP, Attack, Defense, Speed, Special Attack, Special Defense.
# 
#============================================================================================

CHANGERTRAINERS = [
  #ModifiableTrainerData.new(
  #  trainer_type: :ID,
  #  name: "Name",
  #  version: 0,
  #  map_id: 1,
  #  lose_text: "You win!",
  #  items: [:ITEM,:ITEM], 
  #  pokemon_count: 3,
  #  pokemon_slots: [
  #    [ModifiablePokemonData.new(species: :SPECIES, form: FORM, position: nil, level: nil, gender: nil, ability: nil, poke_ball: nil, item: nil, moves: [], evs: nil, ivs: nil)],
  #    [ModifiablePokemonData.new(species: :RATTATA, form: 1, level: 10)],
  #    [ModifiablePokemonData.new(species: :CHINCHOU, form: 0, position: [0,1], level: 13, gender: "m", ability: :VOLTABSORB, poke_ball: :LUREBALL, moves: [:THUNDERSHOCK,:BUBBLE,:SUPERSONIC,:FLASH])],
  #  ]
  #),

  ModifiableTrainerData.new(
    trainer_type: :YOUNGSTER,
    name: "Debugo",
    version: 0,
    map_id: 5,
    lose_text: "You win!",
    items: [:MAXPOTION,:MAXPOTION], 
    pokemon_count: 3,
    pokemon_slots: [
      [ModifiablePokemonData.new(species: :RATTATA, form: 1, level: 10)],
    ]
  ),

  ModifiableTrainerData.new(
    trainer_type: :LASS,
    name: "Debuga",
    version: 0,
    map_id: 5,
    lose_text: "You definitely win!",
    items: [:FULLHEAL,:FULLHEAL,:FULLHEAL], 
    pokemon_count: 3,
    pokemon_slots: [
      [ModifiablePokemonData.new(species: :CHINCHOU, form: 0, position: [0,1], level: 13, gender: "m", ability: :VOLTABSORB, poke_ball: :LUREBALL, moves: [:THUNDERSHOCK,:BUBBLE,:SUPERSONIC,:FLASH])],
    ]
  ),
]