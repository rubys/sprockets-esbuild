# esbuild support for Sprockets

esbuild is an extremely fast transpiler.

This gem uses esbuild to implement Sprockets transformers that will convert
TypeScript, JSX, and TSX formats to JavaScript.  Sourcemaps are produced.

This gem wraps [the standalone executable version](https://esbuild.github.io/getting-started/#download-a-build) of the esbuild executables. These executables are platform specific, so there are actually separate underlying gems per platform, but the correct gem will automatically be picked for your platform. Supported platforms are Linux x64, macOS arm64, macOS x64, and Windows x64. (Note that due to this setup, you must install the actual gems – you can't pin your gem to the github repo.)

## Installation

Inside a Rails application, run:

1. Run `./bin/bundle add sprockets-esbuild`

## License

sprockets-esbuild is released under the [MIT License](https://opensource.org/licenses/MIT).
esbuild is released under the [MIT License](https://opensource.org/licenses/MIT).
