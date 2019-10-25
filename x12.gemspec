lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'x12'

Gem::Specification.new do |gem|
  gem.name          = 'pd_x12'
  gem.version       = X12::VERSION
  gem.authors       = ['Marty Petersen']
  gem.email         = ['themooseman@comcast.net']
  gem.description   = 'A gem to handle parsing and generation of ANSI X12 documents. Currently tested with Ruby >= 1.9.2. Gem supports X12 EDI transactions 270, 997, 837p and 835.  Anyone wanting to create additional XML files for other transactions welcomed.'
  gem.summary       = 'A gem to handle parsing and generation of ANSI X12 documents'
  gem.homepage      = 'https://github.com/mjpete3/x12'
  gem.licenses      = 'GPL-2'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gem.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  gem.require_paths = ['lib']

  gem.add_dependency 'libxml-ruby', '~> 3.1'
  gem.add_development_dependency 'minitest', '~> 5.0'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'simplecov'
end
