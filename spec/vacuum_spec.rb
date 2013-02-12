require 'vacuum'
require 'fileutils'

describe Vacuum::TextProcessor do
  let(:v) { Vacuum::TextProcessor.new }

  context 'basic processing' do
    it 'copies input to output by default' do
      text = "aaa\nbbb\nccc"
      v.process(text).should == text
    end

    it 'handles empty input' do
      text = ''
      v.process(text).should == text
    end

    it 'can require in plain old ruby files' do
      text = '.x require "set"'
      v.process(text).should == ''
    end
  end

  context 'commands' do
    before :each do
      File.open("temp1",'w') {|f| f.puts("aaa\nbbb\n")}

      File.open("temp2",'w') do |f|
        1.upto(10) {|n| f.puts "line #{n}" }
      end
    end

    after :each do
      FileUtils.rm_f("temp1")
      FileUtils.rm_f("temp2")
    end

    it 'can pull in the contents of another file with inc' do
      text = "first\n.inc 'temp1'\nlast"
      output = v.process(text)
      output.should == "first\naaa\nbbb\nlast"
    end

    it 'can do include just the lines between two matching lines' do
      text = "first\n.between(/line 4/, /line 7/, inc('temp2') )\nlast"
      output = v.process(text)
      output.should == "first\nline 5\nline 6\nlast"
    end

    it 'can skip lines matching a regular expression' do
      text = "first\n.skip(/1|2/, inc('temp2'))\nlast"
      output = v.process(text)
      output.should_not match("line 1")
      output.should_not match("line 2")
      output.should match("line 3")
      output.should match("line 4")
    end

    it 'can allows for new commands to be added' do
      text = ".x require 'new_commands'\nfirst\n.inc_up 'temp1'\nlast"
      output = v.process(text)
      output.should == "first\nAAA\nBBB\nlast"
    end
  end
end
