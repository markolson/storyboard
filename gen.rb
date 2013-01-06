#open srt
#open xml

#ffmpeg -ss 00:01:28.655 -i superman_1941_512kb.mp4 -vframes 1 frame5.jpg

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'rmagick'
include Magick
require 'shellwords'
require 'prawn'
p ARGV.first

output_dir = File.basename(ARGV[0].split('.').first)

`mkdir #{Shellwords.escape(output_dir)}`

FPS = 29.97

SRT = ARGV.first + '.srt'

#{}`shotdetect-cmd -f -l -i #{Shellwords.escape(ARGV.first)} -o . -s 90`

subtitles = File.open(SRT)


def parse_time(time)
  #00:01:02,516 --> 00:01:05,326
  r = time.scan(/(.*) --> (.*)/).first
  [to_msec(r[0]), to_msec(r[1])]
  #[r[0].sub(',','.'), r[1].sub(',','.')]
end

def to_msec(s)
  chunks = s.split(/:|,/).map(&:to_i)
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

subs = []
times = []
subtimes = []
newsub = true

#parse subtitle file
while(!subtitles.eof? && line = subtitles.readline) do
  if newsub && (line.to_i - 1 == subs.count)
    newsub = false
    subs << []
  elsif times.count < subs.count && subs.last.empty?
    subtimes << parse_time(line.strip)
    times << parse_time(line.strip).first
  elsif line.strip.length > 0
    subs.last << line.strip
    #p line.strip
  else
    newsub = true
  end
end

p times.count
#parse scene file
f = File.open("result.xml")
p f
doc = Nokogiri::XML(f)
doc.css('shot').each {|s| times << s['msbegin'].to_i }
f.close

times.sort!
p times.count
p times

SS = 7000

subtimes.reverse!
subtitle_frame = 0
last_frame = 0
real_frame_count = 0

times.each_with_index { |time, i|
  last_frame = time
  real_frame_count += 1
  sub = false
  while (!subtimes.empty? && time >= subtimes.last[1].to_i) do
    #p "moving to the next frame."
    subtitle_frame += 1
    subtimes.pop
  end
  p subtimes.last
  if(!subtimes.empty? && time < subtimes.last[0].to_i)
    #p "this frame is before our next subtitle."
  elsif(!subtimes.empty? && time >= subtimes.last[0].to_i && time <= subtimes.last[1].to_i)
    p "valid subtitle/subtime found"
    sub = true
    #p "#{time}: #{subs[subtitle_frame].join(' | ')}"
  else
    p "What happened? #{time} #{subtimes.last}"
  end
  exit if real_frame_count > SS
  offset = (time < 1000)  ? 0 : 1000
  image_name = "#{output_dir}/%04d.jpg" % [real_frame_count]

  `ffmpeg -ss #{to_ts(time, -offset)} -i #{Shellwords.escape(ARGV.first)} -vframes 1 -ss #{to_ts(0, offset)} #{Shellwords.escape(image_name)} >/dev/null 2>&1`

  text = []
  italic, bold, underline = false, false, false
  p subtitle_frame
  p subs[subtitle_frame]
  if !subtimes.empty?
    subs[subtitle_frame].each {|line|

      if line.match(/<i>(.*)<\/i>/)
       text << $1; italic = true
      elsif line.match(/<b>(.*)<\/b>/)
        text << $1; bold = true
      else
        text << line
      end
    }
  end

    img = ImageList.new(image_name)
    img = img.resize_to_fit(640, 480)
  if sub

    txt = Draw.new
    img.annotate(txt, 0,0,0,0, text.join("\n")){
      txt.gravity = Magick::SouthGravity
      txt.pointsize = 37
      txt.stroke_width = 2
      txt.stroke = "#000000"
      txt.fill = "#ffffff"
      txt.font_weight = Magick::BoldWeight
      #txt.font_style = Magick::ItalicStyle
    }
  end
    img.format = 'jpeg'
    img.write(image_name) { self.quality = 50 }
}

`ruby pdf.rb #{Shellwords.escape(output_dir)}`

print "ruby epub.rb #{Shellwords.escape(output_dir)} out"
`ruby epub.rb #{Shellwords.escape(output_dir)} out`
