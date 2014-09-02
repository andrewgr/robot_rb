require './robot'

describe Robot do
  let(:map){ EmptyRectMap.new(5, 5) }
  subject(:robot){ Robot.new(map) }

  describe 'is not placed' do
    specify { expect(robot.report).to eq([nil, nil, nil]) }
    specify { expect(->{ robot.turn(45) }).to raise_error(Robot::NotPlacedError) }
    specify { expect(->{ robot.move(0) }).to raise_error(Robot::NotPlacedError) }
  end

  describe 'is placed to a valid position' do
    before { robot.place(2, 2, 0) }
    specify { expect(robot.report).to eq([2, 2, 0]) }

    specify 'correctly turns right' do
      robot.turn(45)
      expect(robot.report).to eq([2, 2, 45])
    end

    specify 'correctly circles' do
      robot.turn(90)
      robot.move(0)
      expect(robot.report()).to eq([3, 2, 90])

      robot.turn(90)
      robot.move(0)
      expect(robot.report()).to eq([3, 1, 180])

      robot.turn(90)
      robot.move(0)
      expect(robot.report()).to eq([2, 1, 270])

      robot.turn(90)
      robot.move(0)
      expect(robot.report()).to eq([2, 2, 0])
    end

    specify 'cannot fall from table to north and east' do
      robot.place(4, 4, 0)
      expect(->{ robot.move(0) }).to raise_error(Robot::NotPlacedError)
      expect(->{ robot.move(0) }).to raise_error(Robot::NotPlacedError)
    end

    specify 'cannot fall from table to south and west' do
      robot.place(0, 0, 270)
      expect(->{ robot.move(0) }).to raise_error(Robot::NotPlacedError)
      expect(->{ robot.move(0) }).to raise_error(Robot::NotPlacedError)
    end
  end

  context do
    specify do
      robot.place(2, 2, 0)
      robot.move(180)
      expect(robot.report()).to eq([2, 1, 0])
    end
  end

  context do
    specify do
      robot.place(2, 2, 0)
      robot.turn(45)
      expect(->{ robot.move(0) }).to raise_error(Robot::CannotMoveError)
      robot.turn(45)
      expect(robot.report()).to eq([2, 2, 90])
      robot.move(0)
      expect(robot.report()).to eq([3, 2, 90])
      robot.turn(-45)
      expect(->{ robot.move(0) }).to raise_error(Robot::CannotMoveError)
      robot.turn(-45)
      expect(robot.report()).to eq([3, 2, 0])
      robot.move(0)
      expect(robot.report()).to eq([3, 3, 0])
      robot.turn(-45)
      expect(robot.report()).to eq([3, 3, 315])
      expect(->{ robot.move(0) }).to raise_error(Robot::CannotMoveError)
      robot.turn(-45)
      expect(robot.report()).to eq([3, 3, 270])
      robot.move(180)
      expect(robot.report()).to eq([4, 3, 270])
    end
  end

  context 'is placed to an invalid position' do
    specify 'with a non-numeric coordinate' do
      expect(->{ robot.place('A', 2, :north) }).to raise_error(ArgumentError)
    end

    specify 'too far north' do
      expect(->{ robot.place(0, 5, 0) }).to raise_error(Robot::NotPlacedError)
    end

    specify 'too far east' do
      expect(->{ robot.place(5, 2, 0) }).to raise_error(Robot::NotPlacedError)
    end

    specify 'too far south' do
      expect(->{ robot.place(2, -1, 0) }).to raise_error(Robot::NotPlacedError)
    end

    specify 'too far west' do
      expect(->{ robot.place(-1, 2, 0) }).to raise_error(Robot::NotPlacedError)
    end
  end
end

describe RobotController do
  let(:map){ EmptyRectMap.new(5, 5) }
  let(:robot) { Robot.new(map) }
  before { RobotController.run(robot, series) }

  describe do
    let(:series) do
      <<-COMMANDS
        PLACE 0,0,0
        FORWARD
        REPORT
      COMMANDS
    end
    specify { expect(robot.report).to eq([0, 1, 0]) }
  end

  describe do
    let(:series) do
      <<-COMMANDS
        PLACE 0,0,0
        LEFT
        REPORT
      COMMANDS
    end
    specify { expect(robot.report).to eq([0, 0, 315]) }
  end

  describe do
    let(:series) do
      <<-COMMANDS
        PLACE 1,2,90
        FORWARD
        FORWARD
        LEFT
        LEFT
        FORWARD
        REPORT
      COMMANDS
    end
    specify { expect(robot.report).to eq([3, 3, 0]) }
  end

  describe do
    let(:series) do
      <<-COMMANDS

        FORWARD
        I am NOT a c0mmand
        REPORT
      COMMANDS
    end
    specify { expect(robot.report).to eq([nil, nil, nil]) }
  end

  describe do
    let(:series) do
      <<-COMMANDS

        FORWARD
        I am NOT a c0mmand

        PLACE 1,2,90
        I am not a c0mmand
        FORWARD
        LEFT
      COMMANDS
    end
    specify { expect(robot.report).to eq([2, 2, 45]) }
  end
end
