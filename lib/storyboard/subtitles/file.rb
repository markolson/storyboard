module Storyboard::Subtitles
  class File < Storyboard::Subtitles::Base

    def open(path)
      job = Titlekit::Job.new
      input = job.have
      input.file(path)
      job.send(:import, input)


      output = job.want
      output.file(@tmpfile)
      output.subtitles =  input.subtitles.clone

      Titlekit::ASS.master(output.subtitles)
      job.send(:polish, output)

      # trim out the fat so that we can set the correct max font size.
      @subs = output.subtitles.select{|s| 
        (s[:start] <= parent.end_time) &&  (s[:end] >= parent.start_time)
      }
      @subs.each{|l| max_font_for(l[:lines]) }
    end
  end
end