require_relative 'util/math'

require 'gosu'

class Bullet
  attr_reader :x, :y, :width, :height
  attr_accessor :dead

  def initialize(image, x, y, index, vel_x, vel_y)
    @image = Gosu::Image.new(image)
    @x = x
    @y = y
    @width = @image.width
    @height = @image.height
    @vel_x = vel_x
    @vel_y = vel_y
    @height = 0.0
    @width = 0.0
    @dead = false
  end

  def update()
    @x += @vel_x
    @y += @vel_y
  end

  def draw()
    @image.draw(@x, @y, 0, 1, 1)
  end
end

class Player
  KEY_MAP = {
    Gosu::KB_A => ->(p) { p.move_left  },
    Gosu::KB_D => ->(p) { p.move_right },
    Gosu::KB_W => ->(p) { p.move_up    },
    Gosu::KB_S => ->(p) { p.move_down  },
    Gosu::KB_LEFT => ->(p) { p.rotate_left },
    Gosu::KB_RIGHT => ->(p) { p.rotate_right }
  }

  attr_reader :x, :y, :width, :height, :bullets
  attr_accessor :dead
  
  def initialize(window, image)
    @window = window
    @image = Gosu::Image.new(image)
    @x = window.width / 2
    @y = window.height / 2
    @width = @image.width
    @height = @image.height
    @vel_x = 0.0
    @vel_y = 0.0
    @angle = 0.0
    @scale = 1
    @max_speed = 5.0
    @accel = 0.1
    @friction = 0.1
    @rot_speed = 3.0
    @is_rotating = false
    @bullets = []
    @dead = false
  end

  def update_pos
    @x += @vel_x
    @y += @vel_y

    half_width = @image.width * 0.5 * @scale
    half_height = @image.height * 0.5 * @scale
    
    if @x > (@window.width - half_width)
      @x = @window.width - half_width
      @vel_x = 0
    elsif @x < half_width
      @x = half_width
      @vel_x = 0
    end

    if @y > (@window.height - half_height)
      @y = @window.height - half_height
      @vel_y = 0
    elsif @y < half_height
      @y = half_height
      @vel_y = 0
    end

    speed = Math.sqrt(@vel_x**2 + @vel_y**2)
    if (speed > 0.1 && !@is_rotating)
      target_angle = Math.atan2(@vel_y, @vel_x) * 180 / Math::PI + 90

      @angle = lerp_angle(@angle, target_angle, 0.05)
    end

    @bullets.each(&:update)
  end

  def draw
    @image.draw_rot(@x, @y, 0, @angle, 0.5, 0.5, @scale, @scale)
    @bullets.each do |bullet|
      bullet.draw
    end
  end

  def move_left
    @vel_x = [@vel_x - @accel, -@max_speed].max
  end

  def move_right
    @vel_x = [@vel_x + @accel,  @max_speed].min
  end

  def move_up
    @vel_y = [@vel_y - @accel, -@max_speed].max
  end

  def move_down
    @vel_y = [@vel_y + @accel,  @max_speed].min
  end

  def rotate_right
    @angle = @angle += @rot_speed
  end

  def rotate_left
    @angle = @angle -= @rot_speed
  end

  def idle()
    @vel_x = (@vel_x > 0 ? [@vel_x - @friction, 0].max : [@vel_x + @friction, 0].min)
    @vel_y = (@vel_y > 0 ? [@vel_y - @friction, 0].max : [@vel_y + @friction, 0].min)
    
  end

  def shoot()
    speed = 6.0
    angle_rad = (@angle - 90) * Math::PI / 180.0
    vel_x = Math.cos(angle_rad) * speed
    vel_y = Math.sin(angle_rad) * speed

    @bullets << Bullet.new(File.join(__dir__, "../../resource/image/bulletsprite.png"), @x, @y, @bullets.length, vel_x, vel_y)
  end

  def get_input()
    movement_keys = [Gosu::KB_A, Gosu::KB_D, Gosu::KB_W, Gosu::KB_S]
    rotation_keys = [Gosu::KB_LEFT, Gosu::KB_RIGHT]

    any_movement = false
    any_rotation = false

    any_key_pressed = false
    rotating = false

    KEY_MAP.each do |gosu_key, action|
      if Gosu.button_down?(gosu_key)
        if movement_keys.include?(gosu_key)
          any_movement = true
        elsif rotation_keys.include?(gosu_key)
          any_rotation = true
        end
      end
    end

    @is_rotating = any_rotation

    KEY_MAP.each do |gosu_key, action|
      if Gosu.button_down?(gosu_key)
        if @is_rotating
          if rotation_keys.include?(gosu_key)
            action.call(self)
          end
        else
          action.call(self)
        end
      end
    end

    unless any_movement && !@is_rotating
      self.idle
    end
  end
end