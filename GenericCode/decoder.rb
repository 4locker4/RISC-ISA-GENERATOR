require_relative '../GenericIR/base'
require_relative '../GenericIR/builder'
require_relative '../GenericIR/decoder'
require_relative '../Target/RISC-V/32I'
require_relative './decoder_tree.rb'

module SimGen
  class DecoderGenerator
    @@instructions = []

    def initialize
      @@instructions = YAML.load_file("IR.yaml")
    end

    private 

    def pars_ir
      parsed_ir = make_tree(@@instructions)
    end

    def get_op(op)
      case op
      when SimInfra::Var
        "tmp_#{op}"
      when SimInfra::Immediate
        op.name.to_s
      when SimInfra::XReg
        op.name.to_s
      when SimInfra::Constant
        op.value.to_s
      else
        raise "Unknown operand #{op.inspect}"
      end
    end

    