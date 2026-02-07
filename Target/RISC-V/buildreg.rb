require_relative '../../GenericIR/regfile_spec.rb'
module RegFile
  extend SimInfra

  add_register(:x0, size: 32, type: int, const_val: 0)

  make_registers(:x) {
    1.upto(31) do |i|
      add_register :"x#{i}", size: 32, type: int
    end
  }

end