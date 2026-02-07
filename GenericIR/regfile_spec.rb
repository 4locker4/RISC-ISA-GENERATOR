module SimInfra
  @@register_specification = []
  registers = Struct.new(:name, :size, :type, :is_const, :props)

  def add_register(name, size:, type:, const_val: nil, **props, &block)
    new_reg = registers.new(
      name: name, 
      size: size, 
      type: type, 
      const_val: const_val,
      props: props)
    
    if block
      BuildRegs.new(new_reg).instance_eval(&block)
    end

    @@register_specification << new_reg
  end

  def make_registers(common_name, &block)
    common_name.instance_eval(&block)
  end

  class BuildRegs
    def initialize(reg_spec)
      @spec = reg_spec
    end
  end
end