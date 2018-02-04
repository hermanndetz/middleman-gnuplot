# Copyright (C) 2018 Hermann Detz
#
# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.

require "middleman-gnuplot/version"
require "middleman-gnuplot/gp_helpers"
require "middleman-core"
require "numo/gnuplot"
require "fileutils"


module Middleman

include Gnuplot
  class GnuplotExtension < Middleman::Extension

    option :gp_outdir, nil,         'Output path for generated plots'
    option :gp_tmpdir, nil,         'Path where gnuplot files are stored before being merged into build'
    option :gp_format, 'png',       'Output file format'

    @@base_dir = ""
    @@plot_names = []

    # Initializes the middleman-gnuplot extension.
    def initialize(app, options_hash={}, &block)
      super
      app.config[:gp_outdir] = options.gp_outdir
      app.config[:gp_tmpdir] = options.gp_tmpdir
      app.config[:gp_format] = options.gp_format

      @@base_dir = "./#{app.config[:gp_tmpdir]}/#{app.config[:images_dir]}/"

      FileUtils.mkdir_p "#{@@base_dir}/#{app.config[:gp_outdir]}/"
      
      term = Middleman::Gnuplot::get_gnuplot_term(options.gp_format)

      @@gp = Numo::Gnuplot.new
      @@gp.debug_on
      @@gp.set term:"#{term}"

      app.after_build do |builder|
        # Move generated plots to build dir
        FileUtils.cp_r @@base_dir, app.config[:build_dir]
      end
    end

    # Generates a plot via gnuplot using a given expression.
    # The function must be provided as hash using the following fields:
    # @param [Array<Hash>] functions function definition hash
    # @option functions [String] expression expression hat can be processed by gnuplot (e.g. sin(x))
    # @option functions [String] style _lines_ or _points_
    # @option functions [String] color RGB colro definition in hex format
    # @option functions [String] title name of trace
    # @param [String] filename base filename for output file
    # @param [String] title plot title
    def plot_functions (functions=[], filename=nil, title=nil)
        # stub method to enable documentation in yard
    end

    # Generates a plot directly from an existing gnuplot script
    # Params:
    # @param [String] script path to the gnuplot script
    # @param [String] filename for output file (can be overridden in script)
    # @param [String] title plot title (can be overridden in script)
    def plot_script (script, filename=nil, title=nil)
        # stub method to enable documentation in yard
    end

    # Generates a random filename, if the given paramter is nil or empty
    # Returns filename (given or random)
    # Params.
    # +filename+:: input filename
    def random_filename_if_nil (filename=nil)
        # stub method to enable documentation in yard
    end

    helpers do
      def plot_functions (functions=[], filename=nil, title=nil)
        filename = random_filename_if_nil(filename)

        if title.nil?
            title = ""
        end

        outfile = "#{app.config[:gp_outdir]}/#{filename}.#{app.config[:gp_format]}"

        @@gp.set output:"./#{@@base_dir}/#{outfile}"
        @@gp.set title:"#{title}"

        gp_command = []

        functions.each_with_index do |function,i|
            gp_command << function[:expression]

            if function[:style].nil? == false
                gp_command << {w:function[:style]}
            else
                gp_command << {w:'lines'}
            end

            if function[:color].nil? == false
                gp_command << {lc:"rgb '#{function[:color]}'"}
            end

            if function[:title].nil? == false
                gp_command << {t:"#{function[:title]}"}
            else
                gp_command << {t:''}
            end

            gp_command << ", "
        end

        gp_command[-1] = ''

        @@gp.plot gp_command

        register_filename(filename)

        return outfile
      end

      def plot_script (script, filename=nil, title=nil)
        filename = random_filename_if_nil(filename)
        
        outfile = "#{app.config[:gp_outdir]}/#{filename}.#{app.config[:gp_format]}"

        Numo.gnuplot do
            set output: "./#{@@base_dir}/#{outfile}"

            unless title.nil? 
                set title: title
            end

            load script
        end

        register_filename(filename)
        
        return outfile
      end


      private

      # Generates a random filename, if the given paramter is nil or empty
      # Returns filename (given or random)
      # Params.
      # +filename+:: input filename
      def random_filename_if_nil (filename=nil)
        if filename.nil? or filename == ""
            loop do
                filename = ([*('A'..'Z'),*('0'..'9')]).sample(8).join

                break if @@plot_names.include?(filename) == false
            end
        end
        
        return filename
      end

      # Adds a generated or given filename to the log array to ensure
      # unique plot names, if no filename is given.
      # Note: This function does not check the existance of a given
      # filename in the array.
      # Params.
      # +filename+:: filename to be added to array
      def register_filename (filename)
        @@plot_names.append(filename)
      end
    end
  end
end

::Middleman::Extensions.register(:gnuplot, Middleman::GnuplotExtension)

