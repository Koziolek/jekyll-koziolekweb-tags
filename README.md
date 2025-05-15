# Jekyll::Koziolekweb::Tags

This is set of jekyll tags that I use on my blog. It helps generate some specific content like listings of code or aside notes.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add jekyll-koziolekweb-tags

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install jekyll-koziolekweb-tags

## Usage

There are few block tags that you can use.

### offtopic

If you put

```
{% offtopic DIRECTION %}
Your text goes here
{% endofftopic %}
```

in md file, then it will generate:

```html

<aside class="offtopic f-DIRECTION">
    Your text goes here
</aside>
```

I don't want to suggest anything abut css, but:

* `offtopic` class should define most of layout
* `f-DIRECTION` class should define `float` behaviour

### listing

If you put

```
{% listing LANG 'TITLE' %}
Your code goes here
{% endlisting %}
```

in md file, then it will generate:

```html
<p class="listing">Listing X. TITLE</p>
\```LANG
Your code goes here
\```
```

and finally it will be processed by markdown engine to final form. `X` is an number of listing, starts from 1 and work in post context.

### yt_video

This tag helps to embed youtube video:

```
{% yt_video VIDEO_ID %}
```

will generate

```html
<div class="video">
    <iframe src="https://www.youtube-nocookie.com/embed/VIDEO_ID" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and
then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Koziolek/jekyll-koziolekweb-tags.
