# Define JSX, TS (TypeScript) and TSX tranformers, based on shelling
# out to a platform specific esbuild executable.

require 'open3'
require 'sprockets'
require 'sprockets/source_map_utils'
require 'json'
require 'base64'
require 'pathname'

module SprocketsEsbuild

  class TransformerBase
    include Sprockets

    ESBUILD = [File.expand_path('../../exe/esbuild', __dir__)]

    # As windows doesn't support she-bang syntax in scripts, prepend Ruby to
    # the command
    ESBUILD.unshift RbConfig.ruby if Gem.win_platform?

    def cache_key
      @cache_key ||= "#{self.class.name}::#{VERSION}".freeze
    end

    def call(input)
      data = input[:data]

      input[:cache].fetch([cache_key, data]) do

        out, err, status = Open3.capture3(*ESBUILD, '--sourcemap',
          "--sourcefile=#{input[:filename]}", "--loader=#{loader}",
          stdin_data: input[:data])

        match = out.match %r{^//# sourceMappingURL=data:application/json;base64,(.*)\s*}

        if match
          # extract sourcemap from output and then format and combine it
          out[match.begin(0)..match.end(0)] = ''
          map = JSON.parse(Base64.decode64(match[1]))
          map = SourceMapUtils.format_source_map(map, input)
          map = SourceMapUtils.combine_source_maps(input[:metadata][:map], map)
        else
          map = nil
        end

        if status.success? and err.empty?
          if map
            { data: out, map: map }
          else
            out
          end
        else
          raise Error, "esbuild exit status=#{status.exitstatus}\n#{err}"
        end
      end
    end
  end

  # https://esbuild.github.io/content-types/#jsx
  class JsxTransformer < TransformerBase
    def loader
      'jsx'
    end
  end

  # https://esbuild.github.io/content-types/#typescript
  class TsTransformer < TransformerBase
    def loader
      'ts'
    end
  end

  # https://esbuild.github.io/content-types/#typescript
  class TsxTransformer < TransformerBase
    def loader
      'tsx'
    end
  end
end

Sprockets.register_mime_type 'application/typescript', extensions: ['.ts']
Sprockets.register_mime_type 'text/jsx', extensions: ['.jsx']
Sprockets.register_mime_type 'text/tsx', extensions: ['.tsx']

Sprockets.register_transformer 'application/typescript',
   'application/javascript', SprocketsEsbuild::TsTransformer.new

Sprockets.register_transformer 'text/jsx',
   'application/javascript', SprocketsEsbuild::JsxTransformer.new

Sprockets.register_transformer 'text/tsx',
   'application/javascript', SprocketsEsbuild::TsxTransformer.new
