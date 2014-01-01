module Storyboard::Builder
  class PDF
    attr_accessor :parent
    def initialize(parent)
      @parent = parent
    end

    def run(scanfor='*.jpg')
      scanpath = File.join(@parent.workdirectory, scanfor)
      writepath = File.join(@parent.options['_output_director'], "#{File.basename(@parent.video.path)}.pdf")
      @pdf = Prawn::Document.new(:page_size => [parent.width, parent.height], :margin => 0)

      images = Dir[scanpath].sort
      parent.ui.progress("Generating PDF", images.count) do |bar|
        images.each_with_index {|image_path, i|
          @pdf.image image_path
          bar.progress = i
        }
      end

      @pdf.render_file(writepath)
    end
  end
end