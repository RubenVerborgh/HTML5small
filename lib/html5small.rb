require_relative 'html5small/minifier'
require_relative 'html5small/optional_tags'

module HTML5small
  def self.minify html
    minifier = Minifier.new
    Nokogiri::HTML::SAX::Parser.new(minifier).parse(html)
    (OptionalTags.remove minifier.buf).strip
  end
end
