require 'nokogiri'
require 'htmlentities'

module HTML5small
  class Minifier < Nokogiri::XML::SAX::Document
    # Elements in which whitespace is significant, so can't be normalised
    PRE_TAGS = [:pre, :style, :script, :textarea]

    # Elements representing flow content
    FLOW_ELEMENTS = %w{a abbr address area article aside audio b bdo blockquote br
                       button canvas cite code command datalist del details dfn div
                       dl em embed fieldset figure footer form h1 h2 h3 h4 h5 h6 header
                       hgroup hr i iframe img input ins kbd keygen label link
                       map mark math menu meta meter nav noscript object ol output
                       p pre progress q ruby samp script section select small span
                       strong style sub sup svg table textarea time ul var video wbr
                      }.map(&:to_sym)

    # BLock-level elements
    BLOCK_ELEMENTS = %w{address article aside audio blockquote canvas dd div dl fieldset
                        figcaption figure footer form h1 h2 h3 h4 h5 h6 header hgroup hr
                        li noscript ol output p pre section table thead tfoot tr ul video
                       }.map(&:to_sym)

    attr_accessor :buf, :text_node, :entities

    def initialize
      @buf, @text_node = '', ''
      @stack = [], @prev_tag
      @entities = HTMLEntities.new :expanded
    end

    # HTML5 documents begin with the doctype
    def start_document
      buf << "<!doctype html>"
    end

    def start_element name, attrs = []
      name = normalise_name name
      dump_text_node
      @stack.push name
      @prev_tag = name
      buf.rstrip! if is_block_element?(name) and not in_pre_element?
      buf << "<#{name}" + format_attributes(attrs, name) + ">"
    end

    def end_element name
      name = normalise_name name
      dump_text_node
      buf.rstrip! if is_block_element?(name) and not in_pre_element?
      @stack.pop
      @prev_tag = name
      buf << "</#{name}>"
    end

    def comment string
      # I.E "conditional comments" should be retained as-is
      if string =~ /\[if\s+lt\s+IE\s+\d+\]/i
        buf << "<!--#{string}-->"
      end
    end

    def cdata_block string
      text_node << string
    end

    def characters chars
      text_node << chars
    end

    private
    def format_attribute_value value
      value = format_entities value
      value_needs_quoting?(value) ? %Q{"#{value}"} : value
    end

    def normalise_name name
      name.downcase.to_sym
    end

    def format_attributes attrs, element
      return '' if attrs.empty?
      Hash[attrs].map do |name, value|
        [normalise_name(name), format_attribute_value(value)]
      end.sort_by do |name, value|
        name
      end.map do |name, value|
        # Empty values can use the empty attribute syntax
        value.empty? ? name.to_s : "#{name}=#{value}"
      end.join(' ').insert(0, ' ')
    end

    # Can the given value be legally unquoted as per
    # http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#attributes-0
    # ?
    def value_needs_quoting? value
      # must not contain any " ", """, "'", ">", or "=", characters
      value =~ /[[:space:]"'><=`]/
    end

    def format_entities html, except={}
      html = entities.encode(entities.decode(html), :basic)
      except.each{|name, replace| html.gsub!(/&#{name};/, replace)}
      html
    end

    def format_text_node
      # Don't escape script contents
      return text_node if in_script_element?
      # Escape entities inside the text node
      text = format_entities text_node, {quot: ?", apos: ?'}
      # Don't remove white space in elements with non-HTML content
      return text if in_pre_element?
      # Treat all whitespace as spaces
      text.gsub!(/[\n\t]/, ' ')
      # Strip leading whitespace at the beginning of block elements
      text.lstrip! if @prev_tag == @stack.last and is_block_element?(@prev_tag)
      # Normalize spaces
      text.squeeze(' ')
    end

    def in_flow_element?
      not (FLOW_ELEMENTS & @stack).empty?
    end

    def in_pre_element?
      not (PRE_TAGS & @stack).empty?
    end

    def in_script_element?
      @stack.include? :script
    end

    def is_block_element? name
      BLOCK_ELEMENTS.include? name
    end

    def dump_text_node
      buf << format_text_node
      text_node.clear
    end
  end
end
