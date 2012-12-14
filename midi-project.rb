require 'bundler'
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

  CONST_C = 55.5
  def shepard_tone note 
    if note < 0 or note > 23
      raise "Invalid tone range"
    end

    retval = []
    retval << 48 + note;
    retval << (100 * Math::exp(-(((note - 12)**2)/CONST_C))).to_i

    if note < 12
      retval << 60 + note;
      retval << (100 * Math::exp(-((note**2)/CONST_C))).to_i
    else
      retval << 36 + note;
      retval << (100 * Math::exp(-(((note - 24)**2)/CONST_C))).to_i
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

if __FILE__ == $0
  adaptor = MidiAdaptor.new
  at_exit do
    puts "Shutting down midi adaptor..."
    adaptor.shutdown
  end
  adaptor.test
end
