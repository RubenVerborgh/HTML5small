require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def minify(source)
  source = 'fixtures/' + source
  [HTML5::Minifier.minify(File.read source), File.read(source + '.min').chomp]
end

describe HTML5::Minifier do
  it "can minify a skeleton HTML document" do
    source, target = minify('skeleton.html')
    source.to_s.should == target
  end

  it "doesn't collpase whitespace inside <pre> tags" do
    source, target = minify('pre.html')
    source.to_s.should == target
  end

  it "doesn't remove I.E conditional comments" do
    source, target = minify('ie.html')
    source.to_s.should == target
  end
end
