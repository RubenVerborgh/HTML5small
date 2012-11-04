require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def minify(source)
  source = 'fixtures/' + source
  [HTML5.minify(File.read source), File.read(source + '.min').chomp]
end

 SPECS = {
   skeleton: "can minify a skeleton HTML document",
   pre: "doesn't collpase whitespace inside <pre> tags",
   whitespace_p: "collpases whitespace inside <p> tags",
   whitespace_complex: "collpases complex whitespace inside <p> tags",
   lists: "collpases whitespace inside lists",
   ie: "doesn't remove I.E conditional comments",
   table: "removes optional elements in tables",
   dl: "removes optional elements in definition lists",
   normalise_tag_name: "normalises case of element names",
   normalise_attribute_name: "normalises case of attribute names",
   entities_no_expand: "doesn't decode unsafe HTML entities",
   pre_entities: "doesn't decode unsafe HTML entities in preformatted elements",
   attribute_value_ampersand: "doesn't decode ampersand entity in attribute values",
   attribute_value_quot: "encodes quotation marks in attribute values",
   entities_expand: "decodes safe HTML entities",
   sort_attributes: "sorts attribute names alphabetically",
   quot_entity: "expands &quot; entity in text nodes",
   newlines: "should treat newlines in text as a space",
   tabs: "should treat tabs in text as a space",
 }

describe HTML5, '.minify' do
  SPECS.each do |fix, desc|
    it desc do
      source, target = minify("#{fix.to_s.tr(?_, ?-)}.html")
      source.to_s.should == target
    end
  end
end
