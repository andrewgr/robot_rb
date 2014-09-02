class EmptyRectMap
  def initialize(width, height)
    @width, @height = width, height
  end

  def accessible?(x, y)
    (0 <= x && x < @width) && (0 <= y && y < @height)
  end
end

class Robot
  class NotPlacedError < StandardError; end
  class CannotMoveError < StandardError; end

  def initialize(map)
    @map = map
    @x, @y, @direction = nil, nil, nil
  end

  def place(x, y, direction)
    raise NotPlacedError unless @map.accessible?(x, y)
    @x, @y, @direction = x, y, normalize(direction)
  end

  def move(degree)
    raise NotPlacedError unless placed?
    dx, dy = MOVEMENTS[normalize(@direction + degree)] || raise(CannotMoveError)
    place(@x + dx, @y + dy, @direction)
  end

  def turn(degree)
    raise NotPlacedError unless placed?
    place(@x, @y, @direction + degree)
  end

  def report
    [@x, @y, @direction]
  end

  private

  MOVEMENTS = { 0 => [0, 1], 90 => [1, 0], 180 => [0, -1], 270 => [-1, 0] }

  def placed?
    [@x, @y, @direction].all?
  end

  def normalize(degree)
    d = degree % 360
    d < 0 ? 360 + d : d
  end
end

class RobotController
  def self.run(robot, commands)
    commands.each_line do |line|
      command, a1, a2, a3 = line.strip.split(/[,\s]+/)
      next unless command

      begin
        case command.downcase
        when 'place'
          robot.place(a1.to_i, a2.to_i, a3.to_i)
        when 'report'
          puts robot.report().join(',')
        when 'forward'
          robot.move(0)
        when 'backward'
          robot.move(180)
        when 'left'
          robot.turn(-45)
        when 'right'
          robot.turn(45)
        end
      rescue StandardError => ex
      end
    end
  end
end

if __FILE__ == $0
  map = EmptyRectMap.new(5, 5)
  robot = Robot.new(map)
  commands = File.read(ARGV[0])
  RobotController.run(robot, commands)
end
