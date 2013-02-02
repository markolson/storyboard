class STRTime
  REGEX = '([[:digit:]]+):([[:digit:]]+):([[:digit:]]+)[,\.]([[:digit:]]+)'
  attr_reader :value

  class <<self
    def parse(str)
      hh,mm,ss,ms = str.scan(Storyboard.encode_regexp(REGEX)).flatten.map{|i|
        Float(i.force_encoding("ASCII-8bit").delete("\000"))
      }
      value = ((((hh*60)+mm)*60)+ss) + ms/1000
      p value
      self.new(value)
    end
  end

  def initialize(value)
    @value = value
  end

  def +(bump)
    STRTime.new(@value + bump)
  end

  def to_srt
    ss = @value.floor
    ms = ((@value - ss)*1000).to_i

    mm = ss / 60
    ss = ss - mm * 60

    hh = mm / 60
    mm = mm - hh * 60

    "%02i:%02i:%02i.%03i" % [hh, mm, ss, ms]
  end
end
