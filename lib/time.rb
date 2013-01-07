def parse_time(time)
  #00:01:02,516 --> 00:01:05,326
  r = time.scan(/(.*) --> (.*)/).first
  [to_msec(r[0]), to_msec(r[1])]
  #[r[0].sub(',','.'), r[1].sub(',','.')]
end

def to_msec(s)
  chunks = s.split(/:|,|\./).map(&:to_i)
  chunks << (chunks.pop / 1000).round
  msecs = chunks.pop
  chunks.reverse!
  chunks.each_with_index { |x,i| msecs += x.to_i * 60**i * 1000 }
  msecs
end

def to_ts(ms, offset = 0)
  ms = ms.to_i
  _ms = ms + offset
  h = (_ms / (60 * 60 * 1000)).to_i
  m = (_ms / (60 * 1000)).to_i - (h * 60)
  s = (_ms / (1000)).to_i - (m * 60)
  _ms = (_ms / 1000.0).to_s.split('.').last.to_i
  s = "%02d:%02d:%02d.%03d" % [h,m,s,_ms]
  s
end
