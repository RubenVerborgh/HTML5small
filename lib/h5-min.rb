require 'nokogiri'
require 'htmlentities'
require 'tempfile'
require_relative 'h5-min/optional'

module HTML5
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

  BOOL_ATTR = {
    _: [:itemscope, :hidden],
    audio: [:loop, :autoplay, :controls],
    button: [:formnovalidate, :disabled, :autofocus],
    command: [:disabled, :checked],
    details: [:open],
    fieldset: [:disabled],
    form: [:novalidate],
    iframe: [:seamless],
    img: [:ismap],
    input: [:autocomplete, :autofocus, :defaultchecked, 
            :checked, :disabled, :formnovalidate, :indeterminate,
            :multiple, :readonly, :required],
    keygen: [:disabled, :autofocus],
    optgroup: [:disabled],
    option: [:disabled, :defaultselected, :selected],
    ol: [:reversed],
    select: [:autofocus, :disabled, :multiple],
    script: [:async, :defer],
    style: [:scoped],
    textarea: [:autofocus, :disabled, :readonly, :required],
    time: [:pubdate],
    video: [:loop, :autoplay, :controls],
  }

  @minifier ||= Class.new(Nokogiri::XML::SAX::Document) do

    attr_accessor :buf, :text_node, :entities

    def initialize
      @buf, @text_node = '', ''
      @stack = []
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
      buf << "<#{name}" + format_attributes(attrs, name) + ">"
    end

    def end_element name
      name = normalise_name name
      dump_text_node
      buf.rstrip! unless in_pre_element?
      @stack.pop
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
      Hash[*attrs].map do |name, value|
        [normalise_name(name), format_attribute_value(value)]
      end.sort_by do |name, value|
        name
      end.map do |name, value|
        if boolean_attribute?(element, name)
          name.to_s
        else
          "#{name}=#{value}"
        end
      end.join(' ').insert(0, ' ')
    end
    
    # Can the given value be legally unquoted as per
    # http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#attributes-0
    # ?
    def value_needs_quoting? value
      # must not contain any " ", """, "'", ">", or "=", characters
      value =~ /[[:space:]"'><=`]/ or value.empty?
    end

    def boolean_attribute? element, attribute
      e, a = [element, attribute].map(&:to_sym)
      BOOL_ATTR[:_].include?(a) or  
        (BOOL_ATTR.key?(e) and BOOL_ATTR[e].include?(a))
    end
    
    def format_entities html, except={}
      html = entities.encode(entities.decode(html), :basic)
      except.each{|name, replace| html.gsub!(/&#{name};/, replace)}
      html
    end

    def format_text_node
      return HTML5.minify_css(text_node) if @stack.last == :style
      text = format_entities text_node, {quot: ?", apos: ?'}
      return text if in_pre_element?
      text.gsub!(/[\n\t]/,'')
      # Don't strip inter-element white space for flow elements
      unless buf =~ %r{</\w+>\s*\Z} and in_flow_element?
        text.lstrip!
      end
      text.squeeze(' ')
    end

    def in_flow_element?
      not (FLOW_ELEMENTS & @stack).empty?
    end

    def in_pre_element?
      not (PRE_TAGS & @stack).empty?
    end

    def dump_text_node
      buf << format_text_node
      text_node.clear
    end
  end

  def self.minify_css text
    Tempfile.open('css') do |input|
      input << text
      input.close
      return begin
               `yui-compressor --type css --charset utf-8 #{input.to_path}`
             rescue Errno::ENOENT
               warn "yuicompressor not found; won't minify CSS"
               text
             end
    end  
  end

  def self.minify html
    minifier = @minifier.new
    Nokogiri::HTML::SAX::Parser.new(minifier).parse(html)
    OptionalTags.remove minifier.buf.strip
  end
end
