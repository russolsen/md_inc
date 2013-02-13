require 'md_inc/version'
require 'md_inc/md_inc_commands'

module MdInc
  class TextProcessor
    def process(string)
      Commands.process(string)
    end

    def process_stream(stream)
      Commands.process(stream.read)
    end

    def process_file(path)
      Commands.process(File.read(path))
    end
  end
end
