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
      raise "Invalid tone range"
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

class serial_adaptor
  def initialize port
    @port = SerialPort.new port, 115200, 8, 1, SerialPort::NONE
end

if __FILE__ == $0
  adaptor = MidiAdaptor.new
  at_exit do
    puts "Shutting down midi adaptor..."
    adaptor.shutdown
  end
  adaptor.test
end
