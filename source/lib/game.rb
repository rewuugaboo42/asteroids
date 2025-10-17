require_relative 'player'
require_relative 'enemy'

require 'gosu'
require 'debug'

class Game < Gosu::Window
  def initialize
    super 1920, 1080, true
    self.caption = "Asteroids"

    @background = Gosu::Image.new(File.join(__dir__, "../../resource/image/background.png"))
    @player = GamePlayer.new(self, File.join(__dir__, "../../resource/image/playersprite.png"))
    @asteroids = []
    @no_input_this_frame = false

    @score = 0
    @text = Gosu::Image.from_text("Score: #{@score}", 80, font: File.join(__dir__, "../../resource/font/Geo-Regular.ttf"))
    @text_x = 10
    @text_y = 10
    @text_w = @text.width
    @text_h = @text.height

    5.times { spawn_asteroid_near_edge }

    @spawn_timer = 0
    @spawn_interval = 200
    @total_frames = 0

    Player.create_table

    @player_record = Player.create(name: "Player", score: 0)

    @highscore = Player.all.map(&:score).max || 0

    @highscore_text = Gosu::Image.from_text("High Score: #{@highscore}", 80, font: File.join(__dir__, "../../resource/font/Geo-Regular.ttf"))

    @highscore_x = width - @highscore_text.width - 10
    @highscore_y = 10

    @highscore_player = Player.all.find { |p| p.score == @highscore }&.name || "No Player"
    @highscore_player_text = Gosu::Image.from_text("Player: #{@highscore_player}", 60, font: File.join(__dir__, "../../resource/font/Geo-Regular.ttf"))
    @highscore_player_x = width - @highscore_player_text.width - 10
    @highscore_player_y = @highscore_y + @highscore_text.height + 5

    @player_record.save
  end

  def update
    @player.update_pos
    @player.get_input
    @asteroids.each do |asteroid|
      asteroid.update_pos(@player)
      if collides?(asteroid, @player)
        p "detected player collision!"
        @player.dead = true
        @player_record.score = @score
        @player_record.save
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

      if @score > @highscore
        @highscore = @score
        @highscore_text = Gosu::Image.from_text("High Score: #{@highscore}", 80, font: File.join(__dir__, "../../resource/font/Geo-Regular.ttf"))
        @highscore_player = @player_record.name
        @highscore_player_text = Gosu::Image.from_text("Scored by: #{@highscore_player}", 60, font: File.join(__dir__, "../../resource/font/Geo-Regular.ttf"))
        @highscore_player_x = width - @highscore_player_text.width - 10
        @highscore_player_y = @highscore_y + @highscore_text.height + 5
      end
    end

    @spawn_timer += 1

    if (@total_frames % 900).zero? && @spawn_interval > 40
      @spawn_interval -= 20
    end

    if @spawn_timer >= @spawn_interval
      spawn_asteroid_near_edge
      @spawn_timer = 0
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
    @highscore_text.draw(@highscore_x, @highscore_y, 0)
    @highscore_player_text.draw(@highscore_player_x, @highscore_player_y, 0)
  end

  def spawn_asteroid_near_edge
    edge = rand(4)
    case edge
    when 0
      x = rand(0..width)
      y = 0
    when 1
      x = rand(0..width)
      y = height
    when 2
      x = 0
      y = rand(0..height)
    when 3
      x = width
      y = rand(0..height)
    end

    @asteroids << Enemy.new(self, File.join(__dir__, "../../resource/image/asteroidsprite.png"), x, y, @asteroids.length)
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      @player_record.score = @score
      @player_record.save
      close
    elsif id == Gosu::KB_SPACE
      @player.shoot
    end
  end
end