require 'vacuum/version'
require 'vacuum/vacuum_commands'

module Vacuum
  class TextProcessor
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
