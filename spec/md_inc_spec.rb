require 'md_inc'
require 'fileutils'

describe MdInc::Commands do
  let(:context) do
    o = Object.new
    o.extend MdInc::Commands
    o
  end

  context '#code' do
    it 'uses git style tagging if a language is supplied' do
      output = context.code("java", %w{foo})
      output.should == [ "```java", "foo", "```"]
    end

    it 'uses traditional code indenting if a language is not supplied' do
      output = context.code(nil, %w{foo})
      output.should == [ "    foo"]
    end
  end

  context '#skip' do
    let(:lines) { %w{foo skip1 skip2 bar skip3 baz skip4 skip5} }

    it 'skips the lines that match the regular expression' do
      output = context.skip(/skip/, lines)
      output.should == %w{foo bar baz}
    end

    it 'doesnt skip the lines that down match the regular expression' do
      output = context.skip(/no match/, lines)
      output.should == lines
    end
  end

  context '#between' do
    let(:lines) { %w{aaa bbb ccc ddd eee} }

    it 'returns the lines between the patterns, exclusive' do
      output = context.between(/aaa/, /ddd/, lines)
      output.should == %w{bbb ccc}
    end

    it 'will skip the whole output if first re doesnt match' do
      output = context.between(/no match/, /ccc/, lines)
      output.should == []
    end
  end

  context '#normalize_indent' do
    it 'does nothing to non-indented lines' do
      lines = %w{aaa, bbb, ccc}
      output = context.normalize_indent(lines)
      output.should == lines
    end

    it 'does nothing to lines with at least one non-indented line' do
      lines = ['  aaa', 'bbb', '         ccc']
      output = context.normalize_indent(lines)
      output.should == lines
    end

    it 'unindents so that the least indented line has no indent' do
      lines = [' aaa', '  bbb', '   ccc']
      output = context.normalize_indent(lines)
      output.should == ['aaa', ' bbb', '  ccc']
    end

  end
end

module TestModule
  def test_cmd
    ['line 1 from module', 'line 2 from module']
  end

  def return_option(name)
    [options[name]]
  end
end

describe MdInc::TextProcessor do
  let(:mdi) { MdInc::TextProcessor.new }

  context 'basic processing' do
    it 'copies input to output by default' do
      text = "aaa\nbbb\nccc"
      mdi.process(text).should == text
    end

    it 'handles empty input' do
      text = ''
      mdi.process(text).should == text
    end

    it 'handles empty command' do
      text = '.'
      mdi.process(text).should == text
    end

    it 'can require in plain old ruby files' do
      text = '.x require "set"'
      mdi.process(text).should == ''
    end
  end

  context 'commands' do
    before :each do
      File.open("temp1",'w') {|f| f.puts("aaa\nbbb\n")}

      File.open("temp2",'w') do |f|
        1.upto(10) {|n| f.puts "line #{n}" }
      end

      File.open("temp3",'w') do |f|
        f.puts "temp3 line1"
        f.puts ".inc 'temp1'"
        f.puts "temp3 line3"
      end
    end

    after :each do
      FileUtils.rm_f("temp1")
      FileUtils.rm_f("temp2")
      FileUtils.rm_f("temp3")
    end

    it 'can pull in the contents of another file with inc' do
      text = "first\n.inc 'temp1'\nlast"
      output = mdi.process(text)
      output.should == "first\naaa\nbbb\nlast"
    end

    it 'can do include just the lines between two matching lines' do
      text = "first\n.between(/line 4/, /line 7/, inc('temp2') )\nlast"
      output = mdi.process(text)
      output.should == "first\nline 5\nline 6\nlast"
    end

    it 'can skip lines matching a regular expression' do
      text = "first\n.skip(/1|2/, inc('temp2'))\nlast"
      output = mdi.process(text)
      output.should_not match("line 1")
      output.should_not match("line 2")
      output.should match("line 3")
      output.should match("line 4")
    end

    it 'can allows for new commands to be added' do
      text = ".x require 'new_commands'\nfirst\n.inc_up 'temp1'\nlast"
      output = mdi.process(text)
      output.should == "first\nAAA\nBBB\nlast"
    end

    it 'can do recursive inclusion' do
      text = "first\n.inc 'temp3'\nlast"
      output = mdi.process(text)
      output.should == "first\ntemp3 line1\naaa\nbbb\ntemp3 line3\nlast"
    end

    it 'can optionally include other modules for commands' do
      processor = MdInc::TextProcessor.new :modules => [TestModule]
      text = "first\n.test_cmd\nlast"
      output = processor.process(text)
      output.should == "first\nline 1 from module\nline 2 from module\nlast"
    end

    it 'can asscess the options hash from inside of a command' do
      processor = MdInc::TextProcessor.new :modules => [TestModule], :color => "GREEN"
      text = "first\n.return_option :color\nlast"
      output = processor.process(text)
      output.should == "first\nGREEN\nlast"
    end

    it 'has a working multiline example command in upcase_content' do
      text = "first\n..upcase_content\naaa\nbbb\nccc\n..end\nlast"
      output = mdi.process(text)
      output.should == "first\nAAA\nBBB\nCCC\nlast"
    end

    it 'handles multiline commands correctly' do
      text = ".x require 'new_commands'\nfirst\n..multi_up\naaa\nbbb\n..end\nccc"
      output = mdi.process(text)
      output.should == "first\nAAA\nBBB\nccc"
    end

    it 'handles .. as text, not as a multiline command' do
      text = "\nfirst\n..\nlast"
      output = mdi.process(text)
      output.should == text
    end
  end
end
