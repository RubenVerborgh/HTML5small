require 'nokogiri'
require 'htmlentities'

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

    # Optional tags as per
    # http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#optional-tags
    REMOVE = [
      # An html element's start tag may be omitted if the first thing inside
      # the html element is not a comment.
      %r{<html>},
      # An html element's end tag may be omitted if the html element is not
      # immediately followed by a comment.
      %r{</html>},
      # A head element's start tag may be omitted if the element is empty, or
      # if the first thing inside the head element is an element.
      %r{<head>},
      # A head element's end tag may be omitted if the head element is not
      # immediately followed by a space character or a comment.
      %r{</head>},
      # A body element's start tag may be omitted if the element is empty, or
      # if the first thing inside the body element is not a space character or
      # a comment, except if the first thing inside the body element is a
      # script or style element.
      %r{<body>\s?(?!<(script|style))},
      # A body element's end tag may be omitted if the body element is not
      # immediately followed by a comment.
      %r{</body>},
      # A li element's end tag may be omitted if the li element is immediately
      # followed by another li element or if there is no more content in the
      # parent element.
      %r{</li>\s?(?=(<li|</[uo]l))},
      # A dt element's end tag may be omitted if the dt element is immediately
      # followed by another dt element or a dd element.
      %r{</dt>\s?(?=<d[td])},
      # A dd element's end tag may be omitted if the dd element is immediately
      # followed by another dd element or a dt element, or if there is no more
      # content in the parent element.
      %r{</dd>\s?(?=(<d[dt]|</dl))},
      # A p element's end tag may be omitted if the p element is immediately
      # followed by an address, article, aside, blockquote, dir, div, dl,
      # fieldset, footer, form, h1, h2, h3, h4, h5, h6, header, hgroup, hr,
      # menu, nav, ol, p, pre, section, table, or ul, element, or if there is
      # no more content in the parent element and the parent element is not an
      # a element.
      %r{</p>\s?(?=(<(address|article|aside|blockquote|dir|div|dl|fieldset|footer|
      form|h\d|header|hgroup|hr|menu|nav|ol|p|pre|section|table|ul)|</))}x,
      %r{</p>\s?\Z},  
      # An rt element's end tag may be omitted if the rt element is
      # immediately followed by an rt or rp element, or if there is no more
      # content in the parent element.
      %r{</rt>\s?(?=(<r[tp]|</))}, 
      # An rp element's end tag may be omitted if the rp element is
      # immediately followed by an rt or rp element, or if there is no more
      # content in the parent element.
      %r{</rp>\s?(?=(<r[tp]|</))},
      # An optgroup element's end tag may be omitted if the optgroup element
      # is immediately followed by another optgroup element, or if there is no
      # more content in the parent element.
      %r{</optgroup>\s?(?=(<optgroup|</))},
      # An option element's end tag may be omitted if the option element is
      # immediately followed by another option element, or if it is
      # immediately followed by an optgroup element, or if there is no more
      # content in the parent element.
      %r{</option>\s?(?=(<(option|optgroup)|</))},
      # A colgroup element's start tag may be omitted if the first thing
      # inside the colgroup element is a col element, and if the element is
      # not immediately preceded by another colgroup element whose end tag has
      # been omitted. (It can't be omitted if the element is empty.)
      %r{<colgroup>\s?(?=<col)}, # FIXME: Incomplete
      # A colgroup element's end tag may be omitted if the colgroup element is
      # not immediately followed by a space character or a comment.
      %r{</colgroup>},
      # A thead element's end tag may be omitted if the thead element is
      # immediately followed by a tbody or tfoot element.
      %r{</thead>\s?(?=<t(body|foot))},
      # A tbody element's start tag may be omitted if the first thing inside
      # the tbody element is a tr element, and if the element is not
      # immediately preceded by a tbody, thead, or tfoot element whose end tag
      # has been omitted. (It can't be omitted if the element is empty.)
      %r{(?<=</t(head|body|foot)>)\s?<tbody>\s?(?=<tr)}x, # TODO: Look again
      # A tbody element's end tag may be omitted if the tbody element is
      # immediately followed by a tbody or tfoot element, or if there is no
      # more content in the parent element.
      %r{</tbody>\s?(?=(<t(body|foot)|</))},
      # A tfoot element's end tag may be omitted if the tfoot element is
      # immediately followed by a tbody element, or if there is no more
      # content in the parent element.
      %r{</tfoot>\s?(?=(<tbody|</))},
      # A tr element's end tag may be omitted if the tr element is immediately
      # followed by another tr element, or if there is no more content in the
      # parent element.
      %r{</tr>\s?(?=(<tr|</))},
      %r{</tr>\s?(?=(<t(body|foot|head)))}, # We may have already removed the
                                            # parent's end tag
      # A td element's end tag may be omitted if the td element is immediately
      # followed by a td or th element, or if there is no more content in the
      # parent element.
      %r{</td>\s?(?=(<t[dhr]|</))},
      # A th element's end tag may be omitted if the th element is immediately
      # followed by a td or th element, or if there is no more content in the
      # parent element.
      %r{</th>\s?(?=(<t[dhr]|</))},
      %r{</th>\s?(?=((<t(body|foot))|</))},

      #However, a start tag must never be omitted if it has any attributes.

      # The following are void elements
      # (http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#void-elements)
      # Therefore, their end tag must always be omitted
      %r{</area}, 
      %r{</base>}, 
      %r{</br>}, 
      %r{</col>}, 
      %r{</command>}, 
      %r{</embed>}, 
      %r{</hr>}, 
      %r{</img>}, 
      %r{</input>}, 
      %r{</keygen>}, 
      %r{</link>}, 
      %r{</meta>}, 
      %r{</param>}, 
      %r{</source>}, 
      %r{</track>}, 
      %r{</wbr>},
    ]
    def self.minify html
      minifier = new
      Nokogiri::HTML::SAX::Parser.new(minifier).parse(html)
      remove_optional_tags minifier.buf.strip
    end

    def self.remove_optional_tags html
      REMOVE.each do |regex|
        html.gsub!(regex, '')
      end
      html
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
      value = value.gsub(/"/, '&quot;')
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

      #return if name == 'meta' && attrs.key?('http-equiv')
    end

    def normalise_tag_name tag
      tag.downcase.to_sym
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
