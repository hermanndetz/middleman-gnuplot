<Copyright (C) 2018 Hermann Detz>

<This software may be modified and distributed under the terms>
<of the MIT license.  See the LICENSE file for details.>

# middleman-gnuplot

This extension to the [Middleman](http://middlemanapp.com/) framework
provides helper functions to generate plots using gnuplot.

## Setup

Add the gem to your Gemfile:

    gem 'middleman-gnuplot', :path => "path-to/middleman-gnuplot"

Update your gem list:

    $ bundle install


Modify the `config.rb` of your project as follows:

    activate :gnuplot do |opts|
      opts.gp_tmpdir = 'tmp' # path, where plots are stored before copied to build dir
      opts.gp_outdir = 'img' # directory holding plot files with build dir
      opts.gp_format = 'png' # determines output format (currently supports png and pdf)
    end
## Usage

All functions return the output filename of the plot, which can be used
as argument for the `image_tag` helper function.

The middleman-gnuplot extension provides the following helper methods:

* `plot_functions ([{:expression, :style, :color}], filename, plot title)`:
   Plot simple expressions, which can be defined as single hash or array thereof.
   The function returns a filename, which can be used as argument for the
   `image_tag` helper. `expression` can hold terms that can be interpreted by
   gnuplot, e.g. sin(x) or similar. `style`: lines, points, etc. `color` takes
   an RGB color definition in hex format. `filename`defines the output filename.
   If nil, a random filename is generated and returned by the function.

    ```ruby
   image_tag plot_functions([{:expression => "sin(x)",
                              :style => "lines",
                              :color => "#4575B4"},
                             {:expression => "tan(x)",
                              :color => "#D73027"}],
                              "filename",
                              "Plot Title")
   ```

* `plot_script(script, filename, title)`: This helper can be used to
   generate a plot with a gnuplot script. `script` should contain the
   path to the gnuplot script. `filename` defines the output filename. If nil,
   a random filename is generated and returned by the function. The `title`
   parameter can be used to define a plot title.
   ```ruby
   image_tag plot_script("path_to_gnuplot_script", "filename", "Plot Title")
   ```

## Note

The build summary of middleman lists plot files  that were generated in 
previous runs as being _removed_ from the build directory. Nevertheless,
the plots generated in the current run are moved to the build directory
_after_ the middleman sitemap is evaluated and therefore do not show up
in this list.

Feel free to contact me, if you have a better solution for this issue!

## Feedback & Contributions

1. Fork it ( http://github.com/hermanndetz/middleman-gnuplot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
