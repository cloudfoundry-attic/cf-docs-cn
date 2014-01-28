Copyright (c) 2006-2012 VMware, Inc. All Rights Reserved.

# cndocs.cloudfoundry.com

These are the Cloud Foundry docs built with [nanoc][nanoc].

## Setup

Ruby 1.9 is required to build the site. This repo assumes(via .rvmrc) you have
[RVM](https://rvm.beginrescueend.com/) and Ruby 1.9.2 installed and a docs gemset

To create the docs gemset follow these steps:

    $ rvm use 1.9.2
    Using /Users/<your_username>/.rvm/gems/ruby-1.9.2-p290

    $ rvm gemset create docs
    'docs' gemset created (/Users/<your_username>/.rvm/gems/ruby-1.9.2-p290@docs).

    $ rvm gemset use docs

Use this command to get all the necessary gems to build the docs:

    $ bundle install

You can see the available commands with nanoc:

    nanoc -h

Nanoc has [some nice documentation](http://nanoc.stoneship.org/docs/3-getting-started/)
to get you started.  Though if you're mainly concerned with editing or
 adding content, you won't need to know much about nanoc.

[nanoc]: http://nanoc.stoneship.org/


## Writing Docs
* Add a markdown doc `mydoc.md` to the `content` folder. If you need to add screenshots, add
them to `static/images/screenshot/<page-name>/` folder

* Specify title, description and tags.
* Reuse tags instead of making new ones wherever possible.

### Changing the layout
If you need to change the layout you can edit default.haml in the layouts folder.
Many of the values used in this template are set in the confi.yaml including:

* Base urls for all the links
* Test version of docs vs production version of docs
* Social buttons preferences

### Colorized Code Blocks

You can have nanoc pretty print (colorize) your code, by placing the code
inside a fenced block quote (three backquotes) followed by language name.
This style is compatible with GitHub Flavored Markdown code blocks.

Example:

    ``` ruby
    # this is a simple Ruby Sinatra app
    get '/' do
      "Hello from Sinatra!"
    end
    ```

Supported languages include java, javascript, ruby, erb, groovy, scala, bash
html and xml (see `Rules` for full list).

Some things to watch out for:

+ Avoid `TAB` characters in the code, as tabs confuse the nanoc filters.
+ Make sure the three backquotes have no leading spaces
+ You dont have to escape HTML or XML inside the fenced quotes

## Development

Nanoc compiles the site into static files living in `./output/public`.  It's
smart enough not to try to compile unchanged files:

```bash
$ nanoc tags
$ nanoc compile
Loading site data...
Compiling site...
   identical  [0.37s]  output/public/frameworks.html
   identical  [1.54s]  output/public/frameworks/java/spring/grails.html
   identical  [12.77s]  output/public/frameworks/java/spring/spring.html
   identical  [1.01s]  output/public/frameworks/nodejs/nodejs.html
   identical  [0.08s]  output/public/frameworks/ruby/installing-ruby.html
   identical  [0.57s]  output/public/frameworks/ruby/rails-3-0.html
   identical  [2.05s]  output/public/frameworks/ruby/rails-3-1.html
   identical  [0.54s]  output/public/frameworks/ruby/ruby-simple.html
   identical  [0.08s]  output/public/frameworks/ruby/ruby.html
   identical  [3.13s]  output/public/frameworks/ruby/sinatra.html
   identical  [0.90s]  output/public/frameworks/scala/scala.html
   identical  [0.05s]  output/public/getting-started.html
   identical  [0.07s]  output/public/index.html
   identical  [0.09s]  output/public/infrastructure/micro/installing-mcf.html
   identical  [0.14s]  output/public/infrastructure/micro/using-mcf.html
   identical  [0.07s]  output/public/infrastructure/overview.html
   identical  [0.06s]  output/public/quick-start.html
      update  [0.53s]  output/public/services.html

   Site compiled in 42.48s.
```

You can setup whatever you want to view the files.  If you have the adsf
gem, however (I hope so, it was in the Gemfile), you can start Webrick:

    $ nanoc view

You can then open your browser to http://localhost:3000

Compilation times got you down?  Use `autocompile`!

    $ nanoc tags
    $ nanoc autocompile

This starts a web server too, so there's no need to run `nanoc view`.
One thing: remember to add trailing slashes to all nanoc links!

Since Cloud Foundry doesn't support deploying a static app we use Sinatra. The Sinatra app is inside the output doc
You can run this app by doing

    $ cd output
    $ bundle install
    $ ruby sample.rb

You can then open your browser to http://0.0.0.0:4567/ and see the same pages
as with `nanoc view` and opening http://localhost:3000

## Contributing to the documentation

* Signup at [https://reviews.cloudfoundry.org](https://reviews.cloudfoundry.org)
* Install the `gerrit-cli` gem
* `gerrit clone` the repo `ssh://<your-username>@reviews.cloudfoundry.org:29418/cf-docs` and cd into it
* Update the pages (inside of folder `content`)
* Remove the old pages `rm -rf output/public`
* If you changed tags, regenerate them with `nanoc tags`
* Recompile `nanoc compile`
* Test  `nanoc autocompile` or `nanoc view`
* Commit your change `git commit -am "Changes to have a simpler tutorial"`
* Squash commits into one if you want to send your changes upstream.
* Submit changes with `gerrit push`

# License

This work is licensed under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)

