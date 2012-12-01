require 'unimidi'

=begin
SHEPARD_CONSTANTS = [
  [60, 100, 48, 14],
  [61, 99, 49, 18],
  [62, 95, 50, 25],
  [63, 88, 51, 33],
  [64, 80, 52, 41],
  [65, 71, 53, 51],
  [66, 61, 54, 61],
  [67, 51, 55, 71],
  [68, 41, 56, 80],
  [69, 33, 57, 88],
  [70, 32,
=end

class MidiAdaptor
  def initialize
    @output = UniMIDI::Output.gets
  end
  def shutdown
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
  def shepard_tone note 
    retval = []
    retval << 48 + note;
    retval << (100 * Math::exp(-(((note - 12)**2)/72.0))).to_i

    if note < 12
      retval << 60 + note;
      retval << (100 * Math::exp(-((note**2)/72.0))).to_i
    else
      retval << 36 + note;
      retval << (100 * Math::exp(-(((note - 24)**2)/72.0))).to_i
    end
    return retval
  end
end
