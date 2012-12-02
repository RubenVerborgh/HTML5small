# HTML5small

HTML5small is a general-purpose minifier for HTML5 documents.
<br>
It is faster than [html_compressor](https://github.com/completelynovel/html_compressor)
and at the same time compresses much better,
while still generating valid HTML5.

## Usage
```sh
$ gem install html5small
```

```ruby
require 'html5small'
::HTML5.minify '<html>...</html>'
```

### As a nanoc filter
HTML5small can also be used as a [nanoc](http://nanoc.stoneship.org/) [filter](http://nanoc.stoneship.org/docs/4-basic-concepts/#filters).
This will lead to even faster loading if your compiled sites.

To use the HTML5small filter, add this line to your `lib/helpers.rb`:
```ruby
require 'html5small/nanoc'
```
Then adapt your `Rules` to apply the filter where necessary. For example:
```ruby
compile '/blog/*/' do
  filter :erb
  filter :html5small
end
```

## Origin
HTML5small is based on [h5-min](https://github.com/runpaint/h5-min),
which is currently [unmaintained](https://github.com/runpaint/h5-min/issues).
