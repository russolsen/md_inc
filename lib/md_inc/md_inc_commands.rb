module MdInc
  module Commands
      def full_path(path)
        if options[:base_dir]
          File.join(options[:base_dir], path)
        else
          path
        end
      end

      def content
        @content
      end

      def process_file(file_name)
        process(File.read(file_name))
      end

      def process(content)
        output = process_lines(content.split("\n"))
        output.flatten.join("\n")
      end

      def process_lines(lines)
        result = []
        until lines.empty?
          line = lines.shift
          ltype = line_type(line)

          if ltype == :multi_line_cmd
            result +=process_multiline_cmd(line, lines)
          elsif ltype == :single_line_cmd
            result << process_single_line_cmd(line)
          else
            result << process_text(line)
          end
        end
        result
      end

      def line_type(line)
        if %{. ..}.include?(line)
          :text
        elsif line[0,2] == '..'
          :multi_line_cmd
        elsif line[0,1] == '.'
          :single_line_cmd
        else
          :text
        end
      end

      def evaluate(string)
        begin
          instance_eval(string)
        rescue
          puts "Error evaluating #{string}"
          puts $!
          puts caller
        end
      end

      def process_text(text)
        # Do nothing, allows plugins to override to provide custom processing.
        text
      end

      def process_single_line_cmd(line)
        evaluate(line[1..-1])
      end

      def process_multiline_cmd(line, lines)
        content_lines = []
        until lines.empty? || (lines.first =~ /^..end/)
          content_lines << lines.shift
        end
        lines.shift unless lines.empty?
        save_content = @content
        @content = content_lines
        result = evaluate(line[2..-1])
        @content = @save_content
        result
      end

      def x(*args)
        []
      end

      def inc(path, recursive=true)
        lines = File.readlines(full_path(path))
        lines.map! &:rstrip
        recursive ? process_lines(lines) : lines
      end

      def code_inc(path, language=nil, re1=nil, re2=nil)
        if re1
          code(language, normalize_indent(between(re1, re2, inc(path))))
        else
          code(language, normalize_indent(inc(path)))
        end
      end

      def code(language, lines)
        if language.nil?
          lines.map {|l| l.rstrip.prepend('    ')}
        else
          ["```#{language}"] + lines + ["```"]
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

      def upcase_content
        content.map {|l| l.upcase}
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
