# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-gnuplot/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-gnuplot"
  spec.version       = Middleman::Gnuplot::VERSION
  spec.authors       = ["Hermann Detz"]
  spec.email         = ["hermann.detz@gmail.com"]
  spec.description   = <<-EOF 
                       This middleman extension provides helper functions,
                       which allow to create plots using gnuplot and
                       integrate them easily with middleman pages.
                       EOF
  spec.summary       = %q{Middleman extension for gnuplot}
  spec.homepage      = "https://github.com/hermanndetz/middleman-gnuplot"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "numo-gnuplot", ["~> 0.2.4"]
  spec.add_runtime_dependency "middleman-core", ["~> 4.0"]
end
