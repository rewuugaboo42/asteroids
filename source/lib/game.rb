require_relative 'player'
require_relative 'enemy'

require 'gosu'
require 'debug'

class Game < Gosu::Window
  def initialize
    super 1920, 1080, true
    self.caption = "Asteroids"

    @background = Gosu::Image.new(File.join(__dir__, "../../resource/image/background.png"))
    @player = Player.new(self, File.join(__dir__, "../../resource/image/playersprite.png"))
    @asteroids = []
    @no_input_this_frame = false

    @score = 0
    @text = Gosu::Image.from_text("Score: #{@score}", 80, font: File.join(__dir__, "../../resource/font/Geo-Regular.ttf"))
    @text_x = 10
    @text_y = 10
    @text_w = @text.width
    @text_h = @text.height

    10.times do
      @asteroids << Enemy.new(self, File.join(__dir__, "../../resource/image/asteroidsprite.png"), rand(0..self.width), rand(0..self.height), @asteroids.length)
    end
  end

  def update
    @player.update_pos
    @player.get_input
    @asteroids.each do |asteroid|
      asteroid.update_pos(@player)
      if collides?(asteroid, @player)
        p "detected player collision!"
        @player.dead = true
        close
      end
      @player.bullets.each do |bullet|
        if collides?(asteroid, bullet)
          p "detected bullet collision!"
          @score += 10
          @text = Gosu::Image.from_text("Score: #{@score}", 80, font: File.join(__dir__, "../../resource/font/Geo-Regular.ttf"))
          bullet.dead = true
          asteroid.dead = true
        end
      end
      @asteroids.reject! { |asteroid| asteroid.dead }
      @player.bullets.reject! { |bullet| bullet.dead }
    end
  end

  def collides?(asteroid, object)
    x_separated = asteroid.x + asteroid.width < object.x ||
                object.x + object.width < asteroid.x

    y_separated = asteroid.y + asteroid.height < object.y ||
                object.y + object.height < asteroid.y

    !x_separated && !y_separated
  end

  def draw
    @background.draw(0, 0, 0, 1, 1)
    @player.draw
    @asteroids.each do |asteroid|
      asteroid.draw
    end
    @text.draw(@text_x, @text_y)
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    elsif id == Gosu::KB_SPACE
      @player.shoot
    end
  end
end