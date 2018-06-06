Gem::Specification.new do |spec|
  spec.name          = "cipherpipe"
  spec.version       = "0.1.0"
  spec.authors       = ["Pat Allan"]
  spec.email         = ["pat@freelancing-gods.com"]

  spec.summary       = %q{Interact with secret stores and transfer data between them}
  spec.homepage      = "https://github.com/limbrapp/cipherpipe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |file| File.basename(file) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake",    "~> 12.0"
  spec.add_development_dependency "rspec",   "~> 3.7"
  spec.add_development_dependency "webmock", "~> 3.4"
end
