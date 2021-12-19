# coding: utf-8
#
#  Rake tasks to manage native gem packages with binary executables from registry.npmjs.org
#
#  TL;DR: run "rake package"
#
#  The native platform gems (defined by ESBUILD_NATIVE_PLATFORMS below) will each contain two
#  files in addition to what the vanilla ruby gem contains:
#
#     exe/
#     ├── esbuild                                 #  generic ruby script to find and run the binary
#     └── <Gem::Platform architecture name>/
#         └── esbuild                             #  the esbuild binary executable
#
#  The ruby script `exe/esbuild` is installed into the user's path, and it simply locates the
#  binary and executes it. Note that this script is required because rubygems requires that
#  executables declared in a gemspec must be Ruby scripts.
#
#  As a concrete example, an x86_64-linux system will see these files on disk after installing
#  sprockets-esbuild-1.x.x-x86_64-linux.gem:
#
#     exe/
#     ├── esbuild     
#     └── x86_64-linux/
#         └── esbuild     
#
#  So the full set of gem files created will be:
#
#  - pkg/sprockets-esbuild-1.0.0.gem
#  - pkg/sprockets-esbuild-1.0.0-arm64-darwin.gem
#  - pkg/sprockets-esbuild-1.0.0-x64-mingw32.gem
#  - pkg/sprockets-esbuild-1.0.0-x86_64-darwin.gem
#  - pkg/sprockets-esbuild-1.0.0-x86_64-linux.gem
# 
#  Note that in addition to the native gems, a vanilla "ruby" gem will also be created without
#  either the `exe/esbuild` script or a binary executable present.
#
#
#  New rake tasks created:
#
#  - rake gem:ruby           # Build the ruby gem
#  - rake gem:arm64-darwin   # Build the arm64-darwin gem
#  - rake gem:x64-mingw32    # Build the x64-mingw32 gem
#  - rake gem:x86_64-darwin  # Build the x86_64-darwin gem
#  - rake gem:x86_64-linux   # Build the x86_64-linux gem
#  - rake download           # Download all esbuild binaries
#
#  Modified rake tasks:
#
#  - rake gem                # Build all the gem files
#  - rake package            # Build all the gem files (same as `gem`)
#  - rake repackage          # Force a rebuild of all the gem files
#
#  Note also that the binary executables will be lazily downloaded when needed, but you can
#  explicitly download them with the `rake download` command.
#
require "rubygems/package_task"
require "open-uri"

ESBUILD_VERSION = "0.14.5" # string used to generate the download URL

# rubygems platform name => upstream release filename
ESBUILD_NATIVE_PLATFORMS = {
  "arm64-darwin" => "esbuild-darwin-arm64",
  "x64-mingw32" => "esbuild-windows-64",
  "x86_64-darwin" => "esbuild-darwin-64",
  "x86_64-linux" => "esbuild-linux-64",
}

def esbuild_download_url(filename)
  "https://registry.npmjs.org/#{filename}/-/#{filename}-#{ESBUILD_VERSION}.tgz"
end

ESBUILD_RAILS_GEMSPEC = Bundler.load_gemspec("sprockets-esbuild.gemspec")

gem_path = Gem::PackageTask.new(ESBUILD_RAILS_GEMSPEC).define
desc "Build the ruby gem"
task "gem:ruby" => [gem_path]

exepaths = []
ESBUILD_NATIVE_PLATFORMS.each do |platform, filename|
  ESBUILD_RAILS_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir, platform) # "exe/x86_64-linux"
    exepath = File.join(exedir, "esbuild") # "exe/x86_64-linux/esbuild"
    exepaths << exepath

    # modify a copy of the gemspec to include the native executable
    gemspec.platform = platform
    gemspec.executables << "esbuild"
    gemspec.files += [exepath, "LICENSE-DEPENDENCIES"]

    # create a package task
    gem_path = Gem::PackageTask.new(gemspec).define
    desc "Build the #{platform} gem"
    task "gem:#{platform}" => [gem_path]

    directory exedir
    file exepath => [exedir] do
      release_url = esbuild_download_url(filename)
      warn "Downloading #{exepath} from #{release_url} ..."

      # lazy, but fine for now.
      URI.open(release_url) do |remote|
        File.open(exepath+'.tgz', "wb") do |local|
          local.write(remote.read)
        end
      end

      sh "tar xzf #{exepath}.tgz package/bin/esbuild"
      mv 'package/bin/esbuild', exepath
      rm_rf "#{exepath}.tgz"
      rm_rf 'package'
      FileUtils.chmod(0755, exepath, verbose: true)
    end
  end
end

desc "Download all esbuild binaries"
task "download" => exepaths

CLOBBER.add(exepaths.map { |p| File.dirname(p) })
