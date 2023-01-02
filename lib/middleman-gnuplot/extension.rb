require "middleman-gnuplot/version"
require "middleman-gnuplot/gp_helpers"
require "middleman-core"
require "numo/gnuplot"
require "fileutils"
require "time"

module Middleman
  class GnuplotExtension < Middleman::Extension

    option :gp_outdir, nil,         'Output path for generated plots'
    option :gp_tmpdir, nil,         'Path where gnuplot files are stored before being merged into build'
    option :gp_format, 'png',       'Output file format'
    option :gp_rndfilelength, 8,    'Length of randomly generated filenames'

    @@base_dir = ""
    @@plot_names = []

    # Initializes the middleman-gnuplot extension.
    def initialize app, options_hash={}, &block
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
		#
		# @deprecated Will be deprecated in the next version in favor of {#plot}.
		#
    # The function must be provided as hash using the following fields:
    # @param [Array<Hash>] functions function definition hash
    # @option functions [String] expression expression hat can be processed by gnuplot (e.g. sin(x))
    # @option functions [String] style _lines_ or _points_
    # @option functions [String] color RGB color definition in hex format
    # @option functions [String] title name of trace
    # @param [String] filename base filename for output file
    # @param [String] title plot title
    def plot_functions functions=[], filename=nil, title=nil
        # stub method to enable documentation in yard
    end

    # Generates a plot directly from an existing gnuplot script
    # Params:
    # @param [String] script path to the gnuplot script
    # @param [String] filename for output file (can be overridden in script)
    # @param [String] title plot title (can be overridden in script)
    def plot_script script, filename=nil, title=nil
        # stub method to enable documentation in yard
    end

    # Generates a plot via gnuplot using the given data array
    # The data array should be an array of rows that contains arrays of cols.
    # e.g. [[x1, y1, z1], [x2, y2, z2], [x3, y3, z3]]
    # @param [Array] data see format above
    # @param [Array<Hash>] series function definition hash
    # @option series [Int] x Index of x-column in array (1, 2, ...)
    # @option series [Int] y Index of y-column in array (1, 2, ...)
    # @option series [String] style _lines_ or _points_
    # @option series [String] color RGB color definition in hex format
    # @option series [String] title name of trace
    # @param [String] filename base filename for output file
    # @param [String] title plot title
		def plot_data data, series=nil, filename=nil, title=nil
        # stub method to enable documentation in yard
		end

    # Generates a random filename, if the given paramter is nil or empty
    # Returns filename (given or random)
    # @param [String] filename input filename
		# @param [Int] length length of random filename
    def random_filename_if_nil filename=nil, length=6
        # stub method to enable documentation in yard
    end

    helpers do
      def plot_functions functions=[], filename=nil, title=nil
				warn "plot_functions will be deprecated in the next version in favor of the new function plot"

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

      def plot functions=[], filename=nil, title=nil, options={}
        filename = random_filename_if_nil(filename)

        if title.nil?
            title = ""
        end

        outfile = "#{app.config[:gp_outdir]}/#{filename}.#{app.config[:gp_format]}"

        @@gp.set output:"./#{@@base_dir}/#{outfile}"
        @@gp.set title:"#{title}"

				if options.nil? == false
					process_options options
				end


        gp_command = []

        functions.each_with_index do |function,i|
						if function[:expression].nil? == false
							gp_command << function[:expression]
						else
							if function[:file].nil? == false and
								function[:colx].nil? == false and
								function[:coly].nil? == false
								gp_command << "'#{function[:file]}' using #{function[:colx]}:#{function[:coly]} "
							end
						end

            if function[:style].nil? == false
                gp_command << {w:function[:style]}
            else
                gp_command << {w:'lines'}
            end

						if function[:dashtype].nil? == false
							gp_command << "dt #{function[:dashtype]}"
						end

						if function[:width].nil? == false
							gp_command << "lw #{function[:width]}"
						end

            if function[:color].nil? == false
                gp_command << {lc:"rgb '#{function[:color]}'"}
            end

            if function[:title].nil? == false
                gp_command << {t:"#{function[:title]}"}
            else
                gp_command << {t:''}
            end

						if function[:ymin].nil? == false
							gp_command << "y1=#{function[:ymin]}"
						end

            gp_command << ", "
        end

        gp_command[-1] = ''

        @@gp.plot gp_command

        register_filename(filename)

        return outfile
      end

      def plot_script script, filename=nil, title=nil
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

      def plot_data data, series=nil, filename=nil, title=nil
        unless series.nil?
          filename = random_filename_if_nil(filename)

          if title.nil?
              title = ""
          end

          outfile = "#{app.config[:gp_outdir]}/#{filename}.#{app.config[:gp_format]}"

          @@gp.set output:"./#{@@base_dir}/#{outfile}"
          @@gp.set title:"#{title}"

          gp_command = []

          series.each do |ser|
            gp_command << "\"-\" u #{ser[:x]}:#{ser[:y]}"

            if ser[:style].nil? == false
                gp_command << "w #{ser[:style]}"
            else
                gp_command << "w lines"
            end

            if ser[:color].nil? == false
              gp_command << {lc:"rgb '#{ser[:color]}'"}
            end

            if ser[:title].nil? == false
              gp_command << "t \"#{ser[:title]}\""
            else
              gp_command << "notitle"
            end

						if ser[:width].nil? == false
							gp_command << "lw #{ser[:width]}"
						end

            gp_command << ", "
          end

          gp_command[-1] = ''
          gp_command << "\n"

          (1..series.size).each do
            data.each do |line|
              tmpstring = ""

              line.each do |col|
                tmpstring << "#{col}\t"
              end

              gp_command << "#{tmpstring}\n"
            end

            gp_command << "e\n"
          end

          gp_command = gp_command.join(" ")

          puts "GP cmd: #{gp_command}"

          @@gp.plot gp_command


          register_filename(filename)

          return outfile
        end
      end


      private

      # Generates a random filename, if the given paramter is nil or empty.
      # The length of the random string can be overridden by setting
      # app.config[:gp_rndfilelength] in config.rb of the middleman project.
      #
      # Returns filename (given or random)
      # Params.
      # +filename+:: input filename
      # +length+:: length of random filename
      def random_filename_if_nil filename=nil, length=6
        if filename.nil? or filename == ""
          length = app.config[:gp_rndfilelength] unless app.config[:gp_rndfilelength].nil?

          puts "Length of random filename: #{length}"

          loop do
            filename = ([*('A'..'Z'),*('0'..'9')]).sample(length).join

            break if @@plot_names.include?(filename) == false
          end
        end
        
        return filename
      end

      # Adds a generated or given filename to the log array to ensure
      # unique plot names, if no filename is given.
      # Note: In case a given filename already exists - e.g. because a 
      # user adds the same filename twice - a warning is issued.
      # Params.
      # +filename+:: filename to be added to array
      def register_filename filename
        if @@plot_names.include?(filename)
          message "Warning: Filename #{filename} for plot already in use!", :warning
        end

        @@plot_names.append(filename)
      end

      # Prints a colored text message to terminal.
      # Params.
      # +text+:: the message body to be printed
      # +type+:: :warning (yellow) or :error (red)
      def message text, type=:warning
        colString = ''
        colReset = "\033[0m"
        offset = "\033[14C"

        case type
        when :warning
          colString = "\033[1;33m"
        when :error
          colString = "\033[1;31m"
        end

        message = "#{colString}#{offset}middleman-gnuplot: #{text}#{colReset}"

        puts message
      end

			# Processes a set of options that should be passed to gnuplot.
			# Params.
			# @param [array of hashes] an array of hashes that contain the options
			# @option :datafilesep data file separator (e.g. '\t' or ' ')
			# @option :timefmt a string indicating the time format that should be used
			# @option :xtype only required if it should be set to :date
			# @option :ytype only required if it should be set to :date
			# @option :xrange a string indicating the x-axis range
			# @option :yrange a string indicating the y-axis range
			# @option :xformat a string indicating the x-axis format
			# @option :yformat a string indicating the y-axis format
			# @option :key a string to place or modify the key
			def process_options options={}
				if options[:term].nil? == false
					@@gp.set term:"#{options[:term]}"
				end

				if options[:datafilesep].nil? == false
					@@gp.set "datafile separator '#{options[:datafilesep]}'"
				end

				if ((options[:xtype].nil? == false and options[:xtype] == :date) or
					(options[:ytype].nil? == false and options[:ytype] == :date)) and
					(options[:timefmt].nil? == false)
					if options[:xtype] == :date
						@@gp.set "xdata time"
					end

					if options[:ytype] == :date
						@@gp.set "ydata time"
					end

					@@gp.set "timefmt '#{options[:timefmt]}'"
				end
				
				if options[:xrange].nil? == false
					if options[:xtype].nil? == false and options[:xtype] == :date
						@@gp.set "xrange ['#{Time.at(options[:xrange].begin).strftime("%Y-%m-%d %H:%M:%S")}':'#{Time.at(options[:xrange].end).strftime("%Y-%m-%d %H:%M:%S")}']"
					else
						@@gp.set "xrange [#{options[:xrange].begin}:#{options[:xrange].end}]"
					end
				else
					@@gp.unset "xrange"
				end

				if options[:yrange].nil? == false
					if options[:ytype].nil? == false and options[:ytype] == :date
						@@gp.set "yrange ['#{Time.at(options[:yrange].begin).strftime("%Y-%m-%d %H:%M:%S")}':'#{Time.at(options[:yrange].end).strftime("%Y-%m-%d %H:%M:%S")}']"
					else
						@@gp.set "yrange [#{options[:yrange].begin}:#{options[:yrange].end}]"
					end
				else
					@@gp.unset "yrange"
				end

				if options[:xtics].nil? == false
					@@gp.set "xtics #{options[:xtics]}"
				end

				if options[:ytics].nil? == false
					@@gp.set "ytics #{options[:ytics]}"
				end

				if options[:mxtics].nil? == false
					@@gp.set "mxtics #{options[:mxtics]}"
				end

				if options[:mytics].nil? == false
					@@gp.set "mytics #{options[:mytics]}"
				end

				if options[:logx].nil? == false and options[:logx] == true
					@@gp.set "log x"
				else
					@@gp.unset "log x"
				end

				if options[:logy].nil? == false and options[:logy] == true
					@@gp.set "log y"
				else
					@@gp.unset "log y"
				end

				if options[:xformat].nil? == false
					@@gp.set "format x '#{options[:xformat]}'"
				end

				if options[:yformat].nil? == false
					@@gp.set "format y '#{options[:yformat]}'"
				end

				if options[:xlabel].nil? == false
					@@gp.set "xlabel '#{options[:xlabel]}'"
				else
					@@gp.unset "xlabel"
				end

				if options[:ylabel].nil? == false
					@@gp.set "ylabel '#{options[:ylabel]}'"
				else
					@@gp.unset "ylabel"
				end

				if options[:key].nil? == false
					@@gp.set "key #{options[:key]}"
				end

				if options[:grid].nil? == false
					@@gp.set "grid #{options[:grid]}"
				end
			end
    end
  end
end
