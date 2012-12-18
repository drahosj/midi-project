require 'bundler'
require 'serialport'
require 'unimidi'

class MidiAdaptor
  def initialize
    @output = UniMIDI::Output.gets
  end
  def shutdown
    24.times do |n|
      shepard_off n
    end

    @output.close
  end
  def note_on note, velocity
    @output.puts(0x90, note, velocity)
  end
  def note_off note, velocity
    @output.puts(0x80, note, velocity)
  end
  def shepard_on note
    tones = shepard_tone note
    note_on tones[0], tones[1]
    note_on tones[2], tones[3]
  end
  def shepard_off note
    tones = shepard_tone note
    note_off tones[0], tones[1]
    note_off tones[2], tones[3]
  end

  CONST_C = 8.0
  def gauss_func x
    return (95 * Math::exp(-((x/CONST_C)**2))).to_i - 8
  end

  def shepard_tone note 
    if note < 0 or note > 23
      raise "Invalid tone range - #{note}"
    end

    retval = []
    retval << 48 + note;
    retval << gauss_func(note - 12)

    if note < 12
      retval << 60 + note;
      retval << gauss_func(note)
    else
      retval << 36 + note;
      retval << gauss_func(note - 24)
    end
    return retval
  end

  def test
    4.times do
      24.times do |n|
        shepard_on n
        sleep 0.35
        shepard_off n
        sleep 0.055
      end
    end
  end
end

class SerialAdaptor
  def initialize port
    @port = SerialPort.new port, 115200, 8, 1, SerialPort::NONE
  end

  def read_line
    line = String.new
    loop do
      char = @port.getc
      if char == "\n"
        break
      end
      if char != nil
        line << char
      end
    end
    puts "Read line: #{line}"
    line.chomp!
    return line.reverse!
  end

  def test
    loop do
      puts read_line
    end
  end

  def shutdown
    @port.close
  end
end

if __FILE__ == $0
# adaptor = SerialAdaptor.new "/dev/ttyACM0"
#  at_exit do
#    puts "Shutting down adaptor..."
#    adaptor.shutdown
#  end
#  adaptor.test
  
  @midi = MidiAdaptor.new
  @serial = SerialAdaptor.new "/dev/ttyACM0"

  @old_state = "111111111111111111111111"
  @state = @old_state

  loop do
    @state =  @serial.read_line
    puts @state.length
    if @state.length == 23
      @state << "0" #Fix the "leading zero" bug
    end
    puts "S #{@state}"
    puts "O #{@old_state}"
    unless @state == @old_state
      @state.length.times do |i|
        unless @state[i] == @old_state[i]
          if @state[i] == "0"
            @midi.shepard_on i
            puts "Sending NOTE_ON"
          else
            @midi.shepard_off i
            puts "Sending NOTE_OFF"
          end
        end
      end
    end
    @old_state = @state
  end
  at_exit do
    puts "Shutting down..."
    @midi.shutdown
    @serial.shutdown
  end
end
