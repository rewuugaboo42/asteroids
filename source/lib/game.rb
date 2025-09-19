require_relative 'player'
require_relative 'enemy'

require 'gosu'
require 'debug'

class Game < Gosu::Window
  def initialize
    super 640, 360, false
    self.caption = "Asteroids"

    @background = Gosu::Image.new(File.join(__dir__, "../../resource/image/background.png"))
    @player = Player.new(File.join(__dir__, "../../resource/image/playersprite.png"))
    @asteroids = []
    @no_input_this_frame = false

    10.times do
      @asteroids << Enemy.new(File.join(__dir__, "../../resource/image/asteroidsprite.png"), rand(0..640), rand(0..320))
    end
  end

  def update
    @player.update_pos
    @player.get_input
    @asteroids.each do |asteroid|
      asteroid.update_pos
    end
  end

  def draw
    @background.draw(0, 0, 0, 1, 1)
    @player.draw
    @asteroids.each do |asteroid|
      asteroid.draw
    end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    elsif id == Gosu::KB_SPACE
      @player.shoot
    end
  end
end