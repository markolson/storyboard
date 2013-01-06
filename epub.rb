require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'shellwords'

image_path = Shellwords.escape(ARGV[0])
book_path = ARGV[1]

`rm -rf #{book_path}`
`mkdir -p #{book_path}/book/`
`cp -r epub/* #{book_path}/`
`cp #{image_path}/*.jpg #{book_path}/book/`

images = Dir["#{book_path}/book/*.jpg"]

feed = Nokogiri::XML::Builder.new do |xml|
  xml.package(:version => '2.0',  'unique-identifier' => 'id',
                                  "xmlns:opf"=>"http://www.idpf.org/2007/opf",
                                  "xmlns:dcterms"=>"http://purl.org/dc/terms/",
                                  "xmlns:dc"=>"http://purl.org/dc/elements/1.1/",
                                  "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
                                  "xmlns"=>"http://www.idpf.org/2007/opf") {
    xml.metadata {
      xml.method_missing('dc:rights', "None")
      xml.method_missing('dc:title', 'Law & Order 1x01')
    }
    xml.manifest {
      xml.item(:href => "toc.ncx", "id" => "ncx", "media-type"=>"application/x-dtbncx+xml")
      xml.item(:href => "index.html", "id"=>"the-book", "title"=>"Cover")

      0.upto((images.count / 20.0).ceil) {|i|
        xml.item(:href => "page-#{i}.html", "id"=>"book-page#{i}", "title"=>"Page #{i}")
      }

      images.each {|f|
        r = File.basename(f)
        xml.item(:href => r, :id => "img#{r.split('.').first}", 'media-type' => 'image/jpeg')
      }
    }
    xml.guide {
      xml.reference(:href => 'index.html', :type => 'cover', :title => "The Episode")
    }
    xml.spine(:toc => 'ncx') {
      xml.itemref('idref' => 'the-book', :linear => :no)
      0.upto((images.count / 20.0).ceil) {|i|
        xml.itemref('idref' => "book-page#{i}", :linear => :yes)
      }
    }
  }
end

File.open("#{book_path}/book/content.ofp", 'w+'){|f| f.write(feed.to_xml) }

toc =  Nokogiri::XML::Builder.new do |html|
  html.html {
    html.head { html.title('Prescription for Death') }
    html.body {
      0.upto((images.count / 20.0).ceil) {|i|
        html.a(:href => "page-#{i}.html") {html.text  "Page #{i}"}
      }
    }
  }
end
#p toc

File.open("#{book_path}/book/index.html", 'w+'){|f| f.write(toc.to_xml) }

on_image = 0
on_page = 0

while(on_image < images.count) do
  book =  Nokogiri::XML::Builder.new do |html|
    html.html {
      html.head { html.title('Prescription for Death') }
      html.body {
        0.upto(19) {
          next if on_image >= images.count
          #p on_image
          f = images[on_image]
          r = File.basename(f)
          html.img(:src => r)
          on_image += 1
        }
      }
    }
  end
  File.open("#{book_path}/book/page-#{on_page}.html", 'w+'){|f| f.write(book.to_xml) }
  on_page += 1
end


`cd #{book_path} && zip -9 -r #{book_path} .`
`mv #{book_path}/#{book_path}.zip #{image_path}.epub`

#Dir[image_path+"/*.jpg"].each {|i| print i }
