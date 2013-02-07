require 'digest/sha1'

class Storyboard
	class Cache
		attr_accessor :file, :hash
		def initialize(file_hash)
			@hash = file_hash
			@file = File.join(Dir.tmpdir, "#{file_hash}.storyboard")
			if File.exists?(@file)
				@data = JSON.parse(File.read(@file))
			end
			@data = {'downloads' => {}} if @data.nil? || old?
			@data['lastran'] = Time.now.to_s
		end

		def old?
			DateTime.parse(@data['lastran']) < (DateTime.now - ((60 * 15)/86400.0))
		end

		def save
			File.open(@file, 'w') { |f| f.write(@data.to_json)}
		end


		def download_file(url, &block)
			if @data['downloads'][url]
				LOG.debug("Cached file #{@data['downloads'][url]}")
				return File.read(@data['downloads'][url])
			else
				LOG.debug("Loading file from #{url}")
				results = yield
				subpath = File.join(Dir.tmpdir, "#{@hash}-#{Digest::SHA1.hexdigest(url)}.storyboard")
				File.open(subpath, 'w') { |f| f.write(results) }
				@data['downloads'][url] = subpath
				self.save
				return results
			end
		end

		def subtitles
			@data['subtitles']
		end

		def subtitles=(val)
			@data['subtitles'] = val
		end

		def last_used_subtitle
			@data['last_used_subtitle']
		end

		def last_used_subtitle=(val)
			@data['last_used_subtitle'] = val
		end
	end
end
