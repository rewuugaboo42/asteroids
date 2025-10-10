require 'gosu'

class Enemy
  attr_reader :x, :y, :width, :height
  attr_accessor :dead, :angle

  def initialize(window, image, x, y, index)
    @window = window
    @image = Gosu::Image.new(image)
    @x = x
    @y = y
    @width = @image.width
    @height = @image.height
    @vel_x = 1
    @vel_y = 1
    @dead = false
    @angle = 0
    @speed = 1.5
  end

  def update_pos(player)
    move_toward_player(player)
  end

  def draw
    if @vel_x >= 0
      @image.draw(@x, @y, 0, 1, 1)
    else
      @image.draw(@x + @image.width, @y, 0, -1, 1)
    end
  end

  def move_toward_player(player)
    delta_x = player.x - @x;
    delta_y = player.y - @y;

    #@angle = Math.atan2(delta_y, delta_x) * (180 / Math::PI)

    distance = Math.sqrt(delta_x * delta_x + delta_y * delta_y)

    if distance != 0
      dir_x = delta_x / distance
      dir_y = delta_y / distance
    else
      dir_x = 0
      dir_y = 0
    end

    @vel_x = dir_x * @speed
    @vel_y = dir_y * @speed

    @x += @vel_x
    @y += @vel_y
  end
end