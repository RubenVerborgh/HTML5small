require 'html5small'
require 'nanoc'

module HTML5small
  class NanocFilter < ::Nanoc::Filter
    identifier :html5small

    def run(content, params = {})
      HTML5small::minify content
    end
  end
end
