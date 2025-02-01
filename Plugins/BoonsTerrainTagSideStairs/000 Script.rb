#-------------------------------------------------------------------------------
# Boon's Terrain Tag Side Stairs
# v1.3
# By Boonzeet
#-------------------------------------------------------------------------------
# Sideways stairs with pseudo 'depth' effect. Please credit if used
#-------------------------------------------------------------------------------
# v1.3 - Updated for v19
# v1.2 - Fixed bugs with ledges, surfing and map transfers
# v1.1 - Added v18 support
#-------------------------------------------------------------------------------
# Config moved to TerrainTag script section
# stair_type terrain tag property used instead of explicit terrain type tags
# (to make the code "modular" / work with Sounds on Step)
# Stair type 0 / No stair_type property defined = Not a stair
# Stair type 1 = StairLeft
# Stair type 2 = StairRight
# Stair type 3 = StairVertical
#-----------------------------------------------------------------------
# Existing Class Extensions
#-------------------------------------------------------------------------------
def pbTurnTowardEvent(event, otherEvent)
  sx = 0
  sy = 0
  if $map_factory
    relativePos = $map_factory.getThisAndOtherEventRelativePos(otherEvent, event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  sx += (event.width - otherEvent.width) / 2.0
  sy -= (event.height - otherEvent.height) / 2.0
  return if sx == 0 && sy == 0
  if sx.abs >= sy.abs # changed to >=
    (sx > 0) ? event.turn_left : event.turn_right
  else
    (sy > 0) ? event.turn_up : event.turn_down
  end
end

class Game_Character
  alias initialize_stairs initialize
  attr_accessor :offset_x
  attr_accessor :offset_y
  attr_accessor :real_offset_x
  attr_accessor :real_offset_y

  def initialize(*args)
    @offset_x = 0
    @offset_y = 0
    @real_offset_x = 0
    @real_offset_y = 0
    initialize_stairs(*args)
  end

  alias screen_x_stairs screen_x

  def screen_x
    @real_offset_x = 0 if @real_offset_x == nil
    return screen_x_stairs + @real_offset_x
  end

  alias screen_y_stairs screen_y

  def screen_y
    @real_offset_y = 0 if @real_offset_y == nil
    return screen_y_stairs + @real_offset_y
  end

  alias updatemovestairs update_move

  def update_move
    # compatibility with existing saves
    if @real_offset_x == nil || @real_offset_y == nil || @offset_y == nil || @offset_x == nil
      @real_offset_x = 0
      @real_offset_y = 0
      @offset_x = 0
      @offset_y = 0
    end
    if @real_offset_x != @offset_x || @real_offset_y != @offset_y
      @real_offset_x = @real_offset_x - 2 if @real_offset_x > @offset_x
      @real_offset_x = @real_offset_x + 2 if @real_offset_x < @offset_x
      @real_offset_y = @real_offset_y + 2 if @real_offset_y < @offset_y
      @real_offset_y = @real_offset_y - 2 if @real_offset_y > @offset_y
    end
    updatemovestairs
  end

  alias movetostairs moveto

  def moveto(x, y)
    # start edits
    @real_offset_x = 0
    @real_offset_y = 0
    @offset_x = 0
    @offset_y = 0
    # end
    @x = x % self.map.width
    @y = y % self.map.height
    @real_x = @x * Game_Map::REAL_RES_X
    @real_y = @y * Game_Map::REAL_RES_Y
    @prelock_direction = 0
    @moveto_happened = true
    calculate_bush_depth
    triggerLeaveTile
    movetostairs(x, y)
  end

  alias move_generic_stairs move_generic

  def move_generic(dir, turn_enabled = true)
    move_generic_stairs(dir, turn_enabled)
    if self.map.terrain_tag(@x, @y) == :StairLeft || self.map.terrain_tag(@x, @y) == :StairRight
      @offset_y = -16
    else
      @offset_y = 0
    end
  end

  alias move_upper_left_stairs move_upper_left
  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if can_move_in_direction?(7)
      @move_initial_x = @x
      @move_initial_y = @y
      @x -= 1
      @y -= 1
      @move_timer = 0.0
      increase_steps
    end
  end

  alias move_upper_right_stairs move_upper_right
  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if can_move_in_direction?(9)
      @move_initial_x = @x
      @move_initial_y = @y
      @x += 1
      @y -= 1
      @move_timer = 0.0
      increase_steps
    end
  end

  alias move_lower_left_stairs move_lower_left
  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if can_move_in_direction?(1)
      @move_initial_x = @x
      @move_initial_y = @y
      @x -= 1
      @y += 1
      @move_timer = 0.0
      increase_steps
    end
  end

  alias move_lower_right_stairs move_lower_right
  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if can_move_in_direction?(3)
      @move_initial_x = @x
      @move_initial_y = @y
      @x += 1
      @y += 1
      @move_timer = 0.0
      increase_steps
    end
  end
end

class Game_Player
  alias move_generic_stairs move_generic

  def move_generic(dir, turn_enabled = true)
    old_tag = self.map.terrain_tag(@x, @y).id
    old_x = @x
    old_y = @y
    new_x = @x
    new_y = @y
 
    if dir == 4
      if (old_tag == :StairLeft && passable?(@x - 1, @y + 1, 4) && self.map.terrain_tag(@x - 1, @y + 1) == :StairLeft) ||
         (old_tag == :StairRight && passable?(@x - 1, @y - 1, 6) && self.map.terrain_tag(@x - 1, @y - 1) == :StairRight)
        new_x = @x - 1
        new_y = @y + 1
      end
    elsif dir == 6
      if (old_tag == :StairLeft && passable?(@x + 1, @y - 1, 4) && self.map.terrain_tag(@x + 1, @y - 1) == :StairLeft) ||
         (old_tag == :StairRight && passable?(@x + 1, @y + 1, 6) && self.map.terrain_tag(@x + 1, @y + 1) == :StairRight)
        new_x = @x + 1
        new_y = @y - 1
      end
    end
    if old_x != new_x || old_y != new_y
      moveto(new_x, new_y)
    else
      move_generic_stairs(dir, turn_enabled)
    end
    new_tag = self.map.terrain_tag(@x, @y)
    if old_x != @x
      if old_tag != :StairLeft && new_tag == :StairLeft ||
         old_tag != :StairRight && new_tag == :StairRight
        self.offset_y = -16
        @y += 1 if (new_tag == :StairLeft && dir == 4) || (new_tag == :StairRight && dir == 6)
      elsif old_tag == :StairLeft && new_tag != :StairLeft ||
            old_tag == :StairRight && new_tag != :StairRight
        self.offset_y = 0
      end
    end
  end

  alias center_stairs center

  def center(x, y)
    center_stairs(x, y)
    self.map.display_x = self.map.display_x + (@offset_x || 0)
    self.map.display_y = self.map.display_y + (@offset_y || 0)
  end

  def passable?(x, y, d, strict = false)
      # Get new coordinates
      new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
      new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
      # If coordinates are outside of map
      return false if !$game_map.validLax?(new_x, new_y)
      if !$game_map.valid?(new_x, new_y)
        return false if !$map_factory
        return $map_factory.isPassableFromEdge?(new_x, new_y)
      end
      # If debug mode is ON and Ctrl key was pressed
      return true if $DEBUG && Input.press?(Input::CTRL)
      # insertion from this script
      if (d == 8 && new_y > 0) # prevent player moving up past the top of the stairs
        if $game_map.terrain_tag(new_x, new_y) == :StairLeft &&
           $game_map.terrain_tag(new_x, new_y - 1) != :StairLeft
          return false
        elsif $game_map.terrain_tag(new_x, new_y) == :StairRight &&
              $game_map.terrain_tag(new_x, new_y - 1) != :StairRight
          return false
        end
      end
      #end
      return super
  end
end