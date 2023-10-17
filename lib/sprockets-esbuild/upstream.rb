module SprocketsEsbuild
  # constants describing the upstream esbuild project
  module Upstream
    VERSION = "0.19.5"

    # rubygems platform name => [upstream release tarball name, tarball path]
    NATIVE_PLATFORMS = {
      "arm64-darwin" => ["esbuild-darwin-arm64", "package/bin/esbuild"],
      "x64-mingw32" => ["esbuild-windows-64", "package/esbuild.exe"],
      "x86_64-darwin" => ["esbuild-darwin-64", "package/bin/esbuild"],
      "x86_64-linux" => ["esbuild-linux-64", "package/bin/esbuild"],
    }
  end
end
