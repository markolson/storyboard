module Storyboard::Subtitles::Filter
  class Text
    def self.run(subtitles, runner)
      return subtitles.subtitles unless runner.options[:find_text_given]

      found = subtitles.subtitles.select{|s| 
        s[:lines].include?(runner.options[:find_text])
      }

      chosen = nil
      if found.count == 1
        # set the start/end time
        chosen = found
      elsif found.count > 1
        answer = 1 || runner.ui.pick("Multiple matches were found. Please choose one.")
        # return the best match (levenshein?) if the use_closest_text_match
        chosen = [found[answer]]
      end
      p chosen
      runner.start_time = chosen[0][:start]
      runner.end_time = chosen[0][:end]
      chosen
    end
  end
end