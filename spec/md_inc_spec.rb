require 'md_inc'
require 'fileutils'

describe MdInc::Commands do
  context '#code' do
    it 'uses git style tagging if a language is supplied' do
      output = MdInc::Commands.code("java", %w{foo})
      output.should == [ "```java", "foo", "```"]
    end

    it 'uses traditional code indenting if a language is not supplied' do
      output = MdInc::Commands.code(nil, %w{foo})
      output.should == [ "    foo"]
    end
  end

  context '#skip' do
    let(:lines) { %w{foo skip1 skip2 bar skip3 baz skip4 skip5} }

    it 'skips the lines that match the regular expression' do
      output = MdInc::Commands.skip(/skip/, lines)
      output.should == %w{foo bar baz}
    end

    it 'doesnt skip the lines that down match the regular expression' do
      output = MdInc::Commands.skip(/no match/, lines)
      output.should == lines
    end
  end

  context '#between' do
    let(:lines) { %w{aaa bbb ccc ddd eee} }

    it 'returns the lines between the patterns, exclusive' do
      output = MdInc::Commands.between(/aaa/, /ddd/, lines)
      output.should == %w{bbb ccc}
    end

    it 'will skip the whole output if first re doesnt match' do
      output = MdInc::Commands.between(/no match/, /ccc/, lines)
      output.should == []
    end
  end

  context '#normalize_indent' do
    it 'does nothing to non-indented lines' do
      lines = %w{aaa, bbb, ccc}
      output = MdInc::Commands.normalize_indent(lines)
      output.should == lines
    end

    it 'does nothing to lines with at least one non-indented line' do
      lines = ['  aaa', 'bbb', '         ccc']
      output = MdInc::Commands.normalize_indent(lines)
      output.should == lines
    end

    it 'unindents so that the least indented line has no indent' do
      lines = [' aaa', '  bbb', '   ccc']
      output = MdInc::Commands.normalize_indent(lines)
      output.should == ['aaa', ' bbb', '  ccc']
    end

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
  end
end
