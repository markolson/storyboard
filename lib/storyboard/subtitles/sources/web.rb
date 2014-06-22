module Storyboard::Subtitles::Source
  class Web
  	def self.run(subtitles, runner)
  		runner.ui.log("Adding subtitles from Source::Web")

  		osdb = OSDb::MovieFile.new(runner.video.path)
			server = OSDb::Server.new(
	      :timeout => 90, 
	      :useragent => "SubDownloader 2.0.10"
	    ) 

			search_engines = [OSDb::Search::MovieHash, OSDb::Search::IMDB, OSDb::Search::Name, OSDb::Search::Path].map{|se|
			#search_engines = [OSDb::Search::MovieHash].map{|se|
				se.new(server)
			}
			finders = [OSDb::Finder::Score.new]
			selectors = [OSDb::Selector::Movie.new(OSDb::Finder::First.new)]
			subtitle_finder = OSDb::SubtitleFinder.new(search_engines, finders, selectors)
			
			found = subtitle_finder.find_sub_for(osdb, 'eng')
  		return false unless found
			really_temporary_temp = ::Tempfile.new(['storyboard.web', ".#{found.format}"])

			really_temporary_temp.write(found.body)

			subtitles.load_from_file(really_temporary_temp)
			return true
  	end
  end
end