module Vacuum
  module Commands
    public :instance_eval

    class << self
      attr_accessor :root

      def full_path(path)
        @root ? File.join(@root, path) : path
      end

      def x(*args)
        []
      end

      def inc(path)
        lines = File.readlines(full_path(path))
        lines.map &:rstrip!
      end

      def code_inc(path, re1=nil, re2=nil)
        if re1
          code(between(re1, re2, inc(path)))
        else
          code(inc(path))
        end
      end

      def code(lines)
        lines.map {|l| l.rstrip.prepend('    ')}
      end

      def between(re1, re2, lines)
        state = :outside
        output = []
        lines.each do |l|
          if state == :outside && re1 =~ l
            state = :inside
          elsif state == :inside && re2 =~ l
            state = :outside
          else
            output << l if state==:inside
          end
        end
        STDERR.puts "Warning: no output from included file" if output.empty?
        output
      end

      def skip(re, lines)
        output = []
        lines.each do |l|
          output << l unless l =~ re
        end
        output
      end
    end
  end
end
