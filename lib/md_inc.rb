require 'md_inc/version'
require 'md_inc/md_inc_commands'

module MdInc
  class TextProcessor
    def process_stream(s)
      process(s.read)
    end

    def process_file(path)
      process(File.read(path))
    end

    def process(content)
      output = []
      content.split("\n").each do |line|
        if /^\./ =~ line
          output << process_command(line)
        else
          output << line
        end
      end
      out = output.flatten.join("\n")
      out
    end

    def process_command(command_line)
      cmd = command_line[1..-1]
      Commands.instance_eval(cmd)
    end
  end
end
