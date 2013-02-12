module MdInc
  module Commands
    public :instance_eval

    class << self
      def root(path)
        @root = path
      end

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

      def code_inc(path, language=nil, re1=nil, re2=nil)
        if re1
          code(language, normalize_indent(between(re1, re2, inc(path))))
        else
          code(language, normalize_indent(inc(path)))
        end
      end

      def code(language, lines)
        unless language.nil?
          ["```#{language}"] + lines + ["```"]
        else
          lines.map {|l| l.rstrip.prepend('    ')}
        end
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

      def normalize_indent(lines)
        min_indent = min_indent(lines)
        lines.map {|l| l[min_indent..-1]}
      end

      private

      def min_indent(lines)
        indents = lines.map {|l| indent_depth(l)}
        indents.min
      end

      def indent_depth(s)
        /^ */.match(s).end(0)
      end
    end
  end
end
