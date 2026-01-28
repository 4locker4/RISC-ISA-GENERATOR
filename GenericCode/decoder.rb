require_relative '../GenericIR/base'
require_relative '../GenericIR/builder'
require_relative '../GenericIR/decoder'
require_relative '../Target/RISC-V/32I'

instructions = SimInfra.instructions

decoder_tree = SimInfra::InstrTree.new(instructions).tree

def generate_extract_function(instr)
  param_decls = []
  
  instr.args.each do |arg|
    if arg.is_a?(SimInfra::XReg)
      param_decls << "uint32_t& #{arg.name}"
    elsif arg.is_a?(SimInfra::Immediate)
      param_decls << "uint32_t& #{arg.name}"
    end
  end

  body_lines = []
  instr.fields.each do |field|
    if field.is_a?(SimInfra::Field) && field.value == :reg
      width = field.from - field.to + 1
      mask = (1 << width) - 1
      body_lines << "  #{field.name} = (insn >> #{field.to}) & #{mask};"
    end
  end

  imm_parts = instr.fields.select { |f| f.is_a?(SimInfra::ImmFieldPart) }
  if !imm_parts.empty?
    imm_arg = instr.args.find { |a| a.is_a?(SimInfra::Immediate) }
    if imm_arg
      total_width = 0
      expr_parts = []
      
      imm_parts.sort_by! { |p| p.lo }
      imm_parts.each do |part|
        width = part.hi - part.lo + 1
        mask = (1 << width) - 1
        expr_parts << "((insn >> #{part.to}) & #{mask}) << #{total_width}"
        total_width += width
      end
      
      value_expr = expr_parts.join(" | ")
      body_lines << "  #{imm_arg.name} = #{value_expr};"
    end
  end

  params_str = param_decls.empty? ? "" : ", #{param_decls.join(', ')}"
  
  puts "
static inline void extract_args_#{instr.name}(uint32_t insn#{params_str}) {
#{body_lines.join("\n")}
}"
end

def emit_decoder(node, indent = 0)
  spaces = "  " * indent
  if node.is_a?(Array)
    if node.size == 1
      instr = node[0]
      
      if instr.args.empty?
        puts "#{spaces}execute_#{instr.name}();"
      else
        var_names = instr.args.map(&:name).join(", ")
        puts "#{spaces}uint32_t #{var_names};"
        
        param_names = instr.args.map(&:name).join(", ")
        puts "#{spaces}extract_args_#{instr.name}(insn, #{param_names});"
        
        puts "#{spaces}execute_#{instr.name}(#{param_names});"
      end
      
      puts "#{spaces}return;"
    else
      names = node.map(&:name).join(", ")
      puts "#{spaces}throw std::runtime_error(\"ambiguous instructions: #{names}\");"
    end
  elsif node.is_a?(Hash)
    range = node["range"]
    msb, lsb = range[0], range[1]
    width = msb - lsb + 1
    mask = ((1 << width) - 1) << lsb
    puts "#{spaces}switch ((insn & 0x#{'%08X' % mask}) >> #{lsb}) {"
    node["nodes"].sort.each do |value, child|
      puts "#{spaces}case #{value}:"
      emit_decoder(child, indent + 1)
      puts "#{spaces}  break;"
    end
    puts "#{spaces}default:"
    puts "#{spaces}  throw std::runtime_error(\"illegal instruction\");"
    puts "#{spaces}}"
  else
    raise "Unknown node type"
  end
end

instructions = SimInfra.instructions
tree = SimInfra::InstrTree.new(instructions).tree

puts '#include <cstdint>'
puts '#include <stdexcept>'
puts '#include "executor.hpp"'
puts ""

instructions.each do |instr|
  puts generate_extract_function(instr)
  puts ""
end

instructions.each do |instr|
  params = instr.args.map do |arg|
    if arg.is_a?(SimInfra::XReg)
      "uint32_t #{arg.name}"
    elsif arg.is_a?(SimInfra::Immediate)
      "int32_t #{arg.name}"
    end
  end
  puts "void execute_#{instr.name}(#{params.join(', ')});"
end

puts ""
puts "void decode_and_execute(uint32_t insn) {"
emit_decoder(tree, 1)
puts "  throw std::runtime_error(\"unreachable\");"
puts "}"