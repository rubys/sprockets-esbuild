# Define JSX, TS (TypeScript) and TSX tranformers, based on shelling
# out to a platform specific esbuild executable.

require 'open3'
require 'sprockets'

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

        if status.success? and err.empty?
          out
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
