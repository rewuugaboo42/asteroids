require 'gosu'

class Enemy
  attr_reader :x, :y, :width, :height
  attr_accessor :dead

  def initialize(image, x, y, index)
    @image = Gosu::Image.new(image)
    @x = x
    @y = y
    @width = @image.width
    @height = @image.height
    @vel_x = 1
    @vel_y = 1
    @dead = false
  end

  def update_pos()
    @x += @vel_x
    @y += @vel_y

    if @x > (1920 - @image.width) || @x < 0
        @vel_x *= -1
      end

    if @y > (1080 - @image.height) || @y < 0
      @vel_y *= -1
    end
  end

  def draw
    if @vel_x >= 0
      @image.draw(@x, @y, 0, 1, 1)
    else
      @image.draw(@x + @image.width, @y, 0, -1, 1)
    end
  end
end