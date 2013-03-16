# This is an example of what you need to do to
# Add a new command to MdInc: Just add a new
# module level method to the MdInc::Commands
# module and off you go.
module MdInc
  module Commands
    def inc_up(path)
      inc(path).map {|s| s.upcase!}
    end

    def multi_up
      content.map {|l| l.upcase}
    end
  end
end
