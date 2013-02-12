# This is an example of what you need to do to
# Add a new command to Vacuum: Just add a new
# module level method to the Vacuum::Commands
# module and off you go.
module Vacuum
  module Commands
    def self.inc_up(path)
      inc(path).map {|s| s.upcase!}
    end
  end
end
