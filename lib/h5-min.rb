require 'nokogiri'
require 'htmlentities'
require_relative 'h5-min/optional'

module HTML5
  class Minifier < Nokogiri::XML::SAX::Document

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
      OptionalTags.remove minifier.buf.strip
    end

    attr_accessor :in_pre, :buf, :text_node

    def initialize
      @in_pre = false
      @buf, @text_node = '', ''
      @stack = []
    end

    # HTML5 documents begin with the doctype
    def start_document
      buf << "<!DOCTYPE html>"
    end

    def start_element name, attrs = []
      name = normalise_tag_name name
      dump_text_node
      @stack.push name
      self.in_pre = true if PRE_TAGS.include?(name)
      buf << "<#{name}" + format_attributes(attrs) + ">"
    end

    def end_element name
      name = normalise_tag_name name
      dump_text_node
      @stack.pop
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
      text_node << chars
    end

    private
    def format_attribute_value(value)
      value = format_entities value
      value_needs_quoting?(value) ? %Q{"#{value}"} : value
    end

    def normalise_attribute_name name
      name.downcase.to_sym
    end

    def format_attributes attrs
      return '' if attrs.empty?
      Hash[*attrs].map do |name, value|
        [normalise_attribute_name(name), format_attribute_value(value)]
      end.sort_by do |name, value|
        name
      end.map do |name, value|
        "#{name}=#{value}"
      end.join(' ').insert(0, ' ')
    end

    def normalise_tag_name tag
      tag.downcase.to_sym
    end
    
    # Can the given value be legally unquoted as per
    # http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#attributes-0
    # ?
    def value_needs_quoting? value
      # must not contain any literal space characters
      return true if value =~ /[[:space:]]/
      # must not contain any """, "'", ">", "=", characters
      return true if value =~ /["'><=`]/
      # must not be the empty string
      return true if value == ''
      false
    end

    def format_entities html
      he = HTMLEntities.new(:expanded)
      he.encode(he.decode(html), :basic)
    end

    def format_text_node
      return text_node if in_pre
      text = format_entities text_node.gsub(/[\n\t]/,'')
      # Don't strip inter-element white space for flow elements
      unless buf =~ %r{</\w+>\s*\Z} and FLOW.any?{|e| @stack.include?(e)}
        text.lstrip!
      end
      text.squeeze(' ')
    end

    def dump_text_node
      buf << format_text_node
      text_node.clear
    end
  end
end
