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

  def forward
    raise NotPlacedError unless placed?
    dx, dy = DIRECTIONS[@direction] || raise(CannotMoveError)
    place(@x + dx, @y + dy, @direction)
  end

  def backward
    raise NotPlacedError unless placed?
    dx, dy = DIRECTIONS[@direction] || raise(CannotMoveError)
    place(@x - dx, @y - dy, @direction)
  end

  def right
    raise NotPlacedError unless placed?
    place(@x, @y, @direction + 45)
  end

  def left
    raise NotPlacedError unless placed?
    place(@x, @y, @direction - 45)
  end

  def report
    [@x, @y, @direction]
  end

  private

  DIRECTIONS = { 0 => [0, 1], 90 => [1, 0], 180 => [0, -1], 270 => [-1, 0] }

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
        when 'forward', 'backward', 'left', 'right'
          robot.__send__(command.downcase)
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
