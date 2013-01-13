require File.expand_path('../lib/storyboard/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Olson"]
  gem.email         = ["\"theothermarkolson@gmail.com\""]
  gem.description   = %q{Generate PDFs and eBooks from video files}
  gem.summary       = %q{Video to PDF/ePub generator}
  gem.homepage      = "http://github.com/markolson/storyboard"

  gem.required_ruby_version = '>= 1.9.2'

  gem.files         = `git ls-files`.split($\) if File.exist?('.git')
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "storyboard"
  gem.require_paths = ["lib","vendor/suby"]
  gem.version       = Storyboard::VERSION

  gem.add_dependency 'nokogiri'
  gem.add_dependency 'rmagick'
  gem.add_dependency 'prawn'
  gem.add_dependency 'ruby-progressbar'

  # suby stuff.
  gem.add_dependency 'path', '>= 1.3.0'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'rubyzip'
  gem.add_dependency 'term-ansicolor'
  gem.add_dependency 'mime-types', '>= 1.19'

  if File.exist?('.git')
    p "RUNNING"
    `git submodule --quiet foreach 'echo $path'`.split($\).each do |submodule_path|
      # for each submodule, change working directory to that submodule
      Dir.chdir(submodule_path) do
        # issue git ls-files in submodule's directory
        submodule_files = `git ls-files`.split($\)


        # prepend the submodule path to create absolute file paths
        submodule_files_fullpaths = submodule_files.map do |filename|
          "#{submodule_path}/#{filename}"
        end

        # remove leading path parts to get paths relative to the gem's root dir
        # (this assumes, that the gemspec resides in the gem's root dir)
        submodule_files_paths = submodule_files_fullpaths.map do |filename|
          filename.gsub "#{File.dirname(__FILE__)}/", ""
        end

        # add relative paths to gem.files
        gem.files += submodule_files_paths
      end
    end
  end
end
