module Vacuum
  module Commands
    def self.inc_up(path)
      inc(path).map {|s| s.upcase!}
    end
  end
end
