class STRTime
  REGEX = /(\d{2}):(\d{2}):(\d{2}),(\d{3})/

  attr_reader :value

  class <<self
    def parse(str)
      hh,mm,ss,ms = str.scan(REGEX).flatten.map{|i| Float(i)}
      value = ((((hh*60)+mm)*60)+ss) + ms/1000
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

    "%02i:%02i:%02i,%03i" % [hh, mm, ss, ms]
  end
end
