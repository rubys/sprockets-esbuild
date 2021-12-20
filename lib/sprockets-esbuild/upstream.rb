module SprocketsEsbuild
  # constants describing the upstream esbuild project
  module Upstream
    VERSION = "0.14.5"

    # rubygems platform name => upstream release filename
    NATIVE_PLATFORMS = {
      "arm64-darwin" => "esbuild-darwin-arm64",
      "x64-mingw32" => "esbuild-windows-64",
      "x86_64-darwin" => "esbuild-darwin-64",
      "x86_64-linux" => "esbuild-linux-64",
    }
  end
end
