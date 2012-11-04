require_relative 'html5small/Minifier'
require_relative 'html5small/OptionalTags'

module HTML5
  def self.minify html
    minifier = HTML5::Minifier.new
    Nokogiri::HTML::SAX::Parser.new(minifier).parse(html)
    OptionalTags.remove minifier.buf.strip
  end
end
