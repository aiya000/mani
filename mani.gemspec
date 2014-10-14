$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'mani/version'

Gem::Specification.new do |gem|
  gem.name          = 'Mani'
  gem.homepage      = 'https://github.com/NSinopoli/mani'
  gem.license       = 'BSD (3-Clause)'
  gem.summary       = 'A window automation tool'
  gem.description   = 'A window automation tool'
  gem.email         = 'NSinopoli@gmail.com'
  gem.authors       = ['Nick Sinopoli']

  gem.version       = Mani::Version::VERSION

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib']
end
