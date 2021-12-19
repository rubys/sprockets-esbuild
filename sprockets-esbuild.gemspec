require_relative "lib/sprockets-esbuild/version"

Gem::Specification.new do |spec|
  spec.name        = "sprockets-esbuild"
  spec.version     = SprocketsEsbuild::VERSION
  spec.authors     = [ "Sam Ruby" ]
  spec.email       = "rubys@intertwingly.net"
  spec.homepage    = "https://github.com/rubys/sprockets-esbuild"
  spec.summary     = "Transpile JSX, TS, and TSX files with esbuild."
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
  }

  spec.files = Dir["{app,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.bindir = "exe"

  spec.add_dependency "sprockets"
end
