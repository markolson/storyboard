require_relative '../spec_helper'

describe Suby::Downloader do
  show = 'How I Met Your Mother'
  season, episode = 3, 9
  title = 'Slapsgiving'
  ext = 'mkv'
  dot_show = show.tr(' ', '.')
  und_show = show.tr(' ', '_')
  movie_name = "Somemovie.2002.720p.BluRay"
  unknown_name = "crf-hp4"

  context "cleans correctly the show name" do
    {
      dot_show => show,
      und_show => show,
      "an.example.1.0.test" => "an example 1.0 test",
      "an_example_1.0_test" => "an example 1.0 test",
      "an_3.0.1.example_1.0_test" => "an 3.0.1 example 1.0 test",
    }.each_pair { |raw_show, true_show|
      it raw_show do
        # dup because a literal String is frozen and no point to keep the raw show
        Suby::FilenameParser.clean_show_name(raw_show.dup).should == true_show
      end
    }
  end

  context "parse correctly the file name" do
    [
      {
        examples:
        [
            "#{show} #{season}x#{episode}",
            "#{show} #{season}x#{"%.2d" % episode}",
            "#{show} #{season}x#{episode} - #{title}",
            "#{show} #{season}x#{"%.2d" % episode} - #{title}",
            "#{dot_show}.s0309",
            "#{dot_show}.3x09",
            "#{dot_show}.s03.e09",
            "#{und_show}.s03_e09",
            "#{show} - [03.09]",
            "#{show} - S3 E 09",
            "#{show} - Episode 9999 [S 3 - Ep 9]",
            "#{show} - Episode 9999 [S 3 - Ep 9] - ",
            "#{dot_show}.309",
        ],
        expected: { type: :tvshow, show: show, season: season, episode: episode }
      },
      {
        examples: [movie_name],
        expected: { type: :movie, name: "Somemovie", year: 2002 }
      },
      {
        examples: [unknown_name],
        expected: { type: :unknown, name: "#{unknown_name}.#{ext}"}
      }
    ].each do |type|
      type[:examples].each do |filename|
        it filename do
          file = Path(filename).add_ext(ext)
          Suby::FilenameParser.parse(file).should == type[:expected]
        end
      end
    end
  end
end
