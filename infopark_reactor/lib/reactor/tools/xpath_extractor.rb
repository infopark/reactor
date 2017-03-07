module Reactor
  class XPathExtractor
    def initialize(node)
      @node = node
    end

    def match(expr)
      arr = REXML::XPath.match(@node, expr)

      return arr.first if arr.length == 1
      return arr
    end
  end
end
