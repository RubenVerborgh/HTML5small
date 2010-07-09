require 'nokogiri'
require 'cgi'

module HTML5
  class Minifier < Nokogiri::XML::SAX::Document
    attr_accessor :in_pre, :buf

    # Elements which are implied: both their start and end tags can be omitted
    OMIT_TAGS = [:html, :body, :head]

    # Elements whose end tags are implied, thus can be omitted
    OMIT_END_TAGS = [:link, :meta, :img, :br]

    # Elements in which whitespace is significant, so can't be normalised
    PRE_TAGS = [:pre]
    
    # Elements representing flow content
    FLOW = %w{a abbr address area article aside audio b bdo blockquote br 
              button canvas cite code command datalist del details dfn div 
              dl em embed fieldset figure footer form h1 h2 h3 h4 h5 h6 header 
              hgroup hr i iframe img input ins kbd keygen label link
              map mark math menu meta meter nav noscript object ol output 
              p pre progress q ruby samp script section select small span 
              strong style sub sup svg table textarea time ul var video wbr
             }.map(&:to_sym)

    def self.minify html
      minifier = new
      Nokogiri::HTML::SAX::Parser.new(minifier).parse(html)
      minifier.buf.strip
    end

    def initialize
      @in_pre = false
      @buf = ''
      @stack = []
    end

    # HTML5 documents begin with the doctype
    def start_document
      buf << "<!DOCTYPE html>"
    end

    def start_element name, attrs = []
      name = name.to_sym
      @stack.push name
      return if OMIT_TAGS.include?(name)
      attrs = Hash[*attrs]
      return if name == 'meta' && attrs.key?('http-equiv')
      # Will fail for empty attributes
      attrs = attrs.map do |name, value|
        name + '=' + format_attribute_value(value)
      end
      self.in_pre = true if PRE_TAGS.include?(name)
      buf << "<#{name}" + (attrs.empty? ? '' : ' ' + attrs.join(' ')) + ">"
    end

    def end_element name
      name = name.to_sym
      @stack.pop
      return if [OMIT_TAGS, OMIT_END_TAGS].any?{|tags| tags.include?(name)}
      buf.rstrip! unless in_pre
      self.in_pre = false if PRE_TAGS.include?(name)
      buf << "</#{name}>"
    end

    def comment(string)
      # I.E "conditional comments" should be retained as-is
      if string =~ /\[if\s+lt\s+IE\s+\d+\]/i
        buf << "<!--#{string}-->"
      end
    end

    def cdata_block(string)
      buf << string
    end

    def characters(chars)
      chars = CGI.escape_html chars
      if in_pre
        buf << chars
      else
        chars.gsub!(/[\n\t]/, ' ')
        if buf =~ %r{</\w+>\s*\Z} and FLOW.any?{|e| @stack.include?(e)}
          # text node: don't strip
        else 
          chars.lstrip!
          buf.rstrip!
        end
        buf << chars.squeeze(' ')
      end
    end

    private
    def format_attribute_value(value)
      value = value.gsub(/"/, '&quot;')
      value_needs_quoting?(value) ? %Q{"#{value}"} : value
    end

    def value_needs_quoting?(value)
      # must not contain any literal space characters
      return true if value =~ /[[:space:]]/
      # must not contain any """, "'", ">", "=", characters
      return true if value =~ /["'><=`]/
      # must not be the empty string
      return true if value == ''
      false
    end
  end
end
