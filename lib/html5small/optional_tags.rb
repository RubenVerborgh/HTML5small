# coding: utf-8
module HTML5small
  module OptionalTags
    # Optional tags as per
    # http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#optional-tags
    OPTIONAL = [
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
      # Unfortunately, this can confuse older IE browsers.
      # %r{<body>\s?(?!<(script|style))},
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
      # followed by certain opening tags.
      %r{</p>\s?(?=(<(address|article|aside|blockquote|dir|div|dl|fieldset|footer|
      form|h\d|header|hgroup|hr|menu|nav|ol|p|pre|section|table|ul))\W)}x,
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

    def self.remove html
      OPTIONAL.each do |regex|
        html.gsub!(/#{regex}/i, '')
      end
      html
    end
  end
end
