module Storyboard::Subtitles::Filter
  class Time
    def self.run(subtitles, runner)
      subtitles.subtitles.select{|s| 
        (s[:start] <= runner.end_time) &&  (s[:end] >= runner.start_time)
      }
    end
  end
end