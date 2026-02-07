module SimInfra
  class Memory

    def initialize(scope)
      @scope = scope
    end

    def ->(addr, width)
      @scope.load(addr, width)
    end

    def <-(addr, value)
      @scope.store(addr, value)
    end

  end
end
