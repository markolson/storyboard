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

load 't.rb'

p ARGV.first

output_dir = File.basename(ARGV[0].split('.').first)

`mkdir #{Shellwords.escape(output_dir)}`

SRT = ARGV.first + '.srt'

`ffprobe -show_frames -of compact=p=0 -f lavfi "movie=#{ARGV.first},select=gt(scene\\,.3)" -pretty | grep -oE "pkt_pts_time\\=[^\\|]+" > subtimes.out`


subtitles = File.open(SRT)


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
File.open('subtimes.out').each_line {|l|
  times << to_msec(l.split('=').last)
}

times.sort!

SS = 1500

real_frame_count = 0

def render_frame(time, s, image_name)
  offset = (time < 1000)  ? 0 : 1000
    `ffmpeg -ss #{to_ts(time, -offset)} -i #{Shellwords.escape(ARGV.first)} -vframes 1 -ss #{to_ts(0, offset)} #{Shellwords.escape(image_name)} >/dev/null 2>&1`

    text = []
    italic, bold, underline = false, false, false
    img = ImageList.new(image_name)
    img = img.resize_to_fit(640, 480)

    if s && !s.empty?
      s.each {|line|
        if line.match(/<i>(.*)<\/i>/)
         text << $1; italic = true
        elsif line.match(/<b>(.*)<\/b>/)
          text << $1; bold = true
        else
          text << line
        end
      }
      txt = Draw.new
      img.annotate(txt, 0,0,0,0, s.join("\n")){
        txt.gravity = Magick::SouthGravity
        txt.pointsize = 40
        txt.stroke_width = 2
        txt.stroke = "#000000"
        txt.fill = "#ffffff"
        txt.font_weight = Magick::BoldWeight
        #txt.font_style = Magick::ItalicStyle
      }
    end
    img.format = 'jpeg'
    img.write(image_name) { self.quality = 50 }
end

pool = Thread::Pool.new(8)
times.each_with_index { |time, i|
    last_frame = time

    lines = nil
    subtimes.each_with_index{|t,j|
      lines = subs[j] if (time >= t.first && time <= t.last)
    }

    image_name = "#{output_dir}/%04d.jpg" % [i]

    pool.process {
      render_frame(time, lines, image_name)
    }

    pool.shutdown && exit if i > SS
}

t = Thread.new {
  while(pool.backlog > 0)
    sleep(1)
    p pool.backlog
  end
}
pool.shutdown

t.join

`ruby pdf.rb #{Shellwords.escape(output_dir)}`
`ruby epub.rb #{Shellwords.escape(output_dir)} out`
