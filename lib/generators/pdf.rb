require 'prawn'

class Storyboard
  class PDFRenderer
    def self.render(storyboard, outfile)
      storyboard.capture_points.each_with_index {|x,i|
        p x.value
        storyboard.subtitles.pages.each {|page|
          if x.value >=  page.start_time.value and x.value <= page.end_time.value
            p page.lines.join(" | ")

          end
        }
      }
    end
  end
end
=begin
image_path = ARGV[0]


p image_path

pdf = Prawn::Document.new(:page_size => [640, 480], :margin => 0)
  Dir["#{image_path}/*.jpg"].each {|i|
    p i
    pdf.image i, :height => 480, :width => 640
  }

 pdf.render_file "#{image_path}.pdf"
=end
