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


load 'lib/time.rb'
load 'lib/thread-util.rb'

p ARGV.first

output_dir = File.basename(ARGV[0].split('.').first)

`mkdir #{Shellwords.escape(output_dir)}`

FPS = 29.97
`suby #{Shellwords.escape(ARGV.first)}`

SRT = File.basename(ARGV.first, '.*') + '.srt'

`ffprobe -show_frames -of compact=p=0 -f lavfi "movie=#{ARGV.first},select=gt(scene\\,.35)" -pretty | grep -oE "pkt_pts_time\\=[^\\|]+" > subtimes.out`


subtitles = File.open(SRT)


subs = []
times = []
subtimes = []
newsub = true

#parse subtitle file

while(!subtitles.eof? && line = subtitles.readline) do
  line = line.strip
  line.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')

  p "On #{line}"
  p "linnee #{line} #{line.to_s.to_i} / #{subs.count}"
  if newsub && (line.to_i - 1 == subs.count)
    p "newsub"
    newsub = false
    subs << []
  elsif times.count < subs.count && subs.last.empty?
    p "timer"
    subtimes << parse_time(line)
    times << parse_time(line).first
  elsif line.length > 0
    subs.last << line
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
      maxsize = 37
      txt = Draw.new
      txt.pointsize = maxsize

      img.annotate(txt, 0,0,0,0, s.join("\n")){
        txt.gravity = Magick::SouthGravity
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
    #puts "ffmpegthumbnailer -t #{to_ts(time, 0)} -i #{Shellwords.escape(ARGV.first)} -o #{Shellwords.escape(image_name)} >/dev/null 2>&1"
    #`ffmpegthumbnailer -t #{to_ts(time, 0)} -i #{Shellwords.escape(ARGV.first)} -o #{Shellwords.escape(image_name)} >/dev/null 2>&1`


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
