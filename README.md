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

## Origin
HTML5small is based on [h5-min](https://github.com/runpaint/h5-min),
which is currently [unmaintained](https://github.com/runpaint/h5-min/issues).
