# Copyright (C) 2018 Hermann Detz
#
# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.

module Middleman
    module Gnuplot

    module_function
        def get_gnuplot_term (extension)
            term = ''

            case extension
            when 'png'
                term = 'pngcairo'
            when 'pdf'
                term = 'pdfcairo'
            else
                term = 'pngcairo'
            end

            return term
        end
    end
end
