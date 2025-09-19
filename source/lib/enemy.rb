require 'gosu'

class Enemy
  def initialize(image, x, y)
    @image = Gosu::Image.new(image)
    @x = x
    @y = y
    @vel_x = 1
    @vel_y = 1
  end

  def update_pos()
    @x += @vel_x
    @y += @vel_y

    if @x > (640 - @image.width) || @x < 0
        @vel_x *= -1
      end

    if @y > (320 - @image.height) || @y < 0
      @vel_y *= -1
    end
  end

  def draw
    if @vel_x >= 0
      @image.draw(@x, @y, 0, 1.5, 1.5)
    else
      @image.draw(@x + @image.width, @y, 0, -1.5, 1.5)
    end
  end
end