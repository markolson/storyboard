module Storyboard::Subtitles
  class File < Storyboard::Subtitles::Base

    def load_subs(path)
      job = Titlekit::Job.new
      input = job.have
      # re-save the file with a hopefully sane encoding..

      really_temporary_temp = ::Tempfile.new(['storyboard.file', ::File.extname(path)])
      cleaned_body = clean(::File.read(path).lines)

      really_temporary_temp.write(cleaned_body)
      really_temporary_temp.rewind.size
      really_temporary_temp.flush

      Storyboard::Binaries.ffmpeg(["-v", "quiet", "-y", "-i", really_temporary_temp.path, really_temporary_temp.path])

      # and then go
      input.file(really_temporary_temp)
      input.encoding 'UTF-8'
      begin
        job.send(:import, input)
      rescue
        p job.report
        exit
      end

      output = job.want
      output.file(@tmpfile)
      output.subtitles =  input.subtitles.clone

      Titlekit::ASS.master(output.subtitles)
      job.send(:polish, output)
      @subs = output.subtitles
    end

    private 


  end
end