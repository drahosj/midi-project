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
  def shepard_note note #Pass 0-23, ret [note, velocity, note', velocity']
    retval = []
    retval << 48 + note;
    
    velocity = (100 * Math::exp(-(((note - 12)**2)/72 - 12.00)))).to_i
end
