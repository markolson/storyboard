module Storyboard::Subtitles::Source
  class Local
  	def self.run(subtitles, runner)

  		path = runner.video.path
  		subtitle_extension = %w(srt sub ssa ass).detect{ |ext| ext = ".#{ext}"; File.exist?(path.gsub(File.extname(path), ext)) }
  		return false unless subtitle_extension

  		subtitle_path = path.gsub(File.extname(path), ".#{subtitle_extension}")
  		runner.ui.log("Adding subtitles from Source::Local: #{subtitle_path}")
  		subtitles.load_from_file(subtitle_path)
  		return true
  	end
  end
end