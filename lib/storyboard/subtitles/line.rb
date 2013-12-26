module Storyboard::Subtitles
  class Line < Storyboard::Subtitles::Base
    def add_line(start_time, end_time, lines)
      @subs << {:start => start_time, :end => end_time, :lines => lines.join("\\N"), :max_font => max_font_for(lines)}
    end
  end
end