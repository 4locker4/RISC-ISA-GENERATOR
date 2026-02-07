module SimInfra
    class XReg
        attr_reader :name
        def initialize(name)
            @name = name
        end

        # String representation for asm output
        def to_s
            @name.to_s
        end
    end

    def XReg(name); XReg.new(name); end

    class Immediate
        attr_reader :name

        def initialize(name)
          @name = name
        end

        # String representation for asm output
        def to_s
          @name.to_s
        end
    end

    def Imm(name)
        Immediate.new(name)
    end
end
