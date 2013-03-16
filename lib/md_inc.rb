require 'md_inc/version'
require 'md_inc/md_inc_commands'
require 'ostruct'

module MdInc
  class TextProcessor
    attr_accessor :root

    def initialize(options={})
      @options = options
    end

    def process(string)
      context = OpenStruct.new(@options)
      context.root = root
      context.options = @options
      context.extend Commands
      if @options[:modules]
        @options[:modules].each {|m| context.extend m}
      end
      context.process(string)
    end

    def process_stream(stream)
      process(stream.read)
    end

    def process_file(path)
      process(File.read(path))
    end
  end
end
