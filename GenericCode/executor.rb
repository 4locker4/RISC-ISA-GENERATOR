#!/usr/bin/env ruby

require_relative '../GenericIR/base'
require_relative '../GenericIR/builder'
require_relative '../Target/RISC-V/32I'

instructions = SimInfra.instructions

def emit_ir_stmt(stmt, var_map, args_map, indent = 0)
  spaces = "  " * indent
  case stmt.name
  when :new_var
    # Игнорируем
    ""
    
  when :new_const
    dst = stmt.oprnds[0].name
    value = stmt.oprnds[1]
    var_map[dst] = value.to_s
    ""
    
  when :let
    dst = stmt.oprnds[0].name
    src = stmt.oprnds[1]
    if src.is_a?(SimInfra::Var)
      var_map[dst] = var_map.fetch(src.name, "0")
    elsif src.is_a?(SimInfra::XReg) || src.is_a?(SimInfra::Immediate)
      var_map[dst] = args_map[src.name]
    else
      var_map[dst] = src.to_s
    end
    ""
    
  when :getreg
    dst = stmt.oprnds[0].name
    src_arg = stmt.oprnds[1]
    var_map[dst] = args_map[src_arg.name]
    ""
    
  when :getpc
    var_map[stmt.oprnds[0].name] = "pc"
    ""
    
  when :sext
    dst = stmt.oprnds[0].name
    src = stmt.oprnds[1]
    width = stmt.oprnds[2]
    if src.is_a?(SimInfra::Var)
      val = var_map.fetch(src.name, "0")
    elsif src.is_a?(SimInfra::XReg) || src.is_a?(SimInfra::Immediate)
      val = args_map[src.name]
    else
      val = src.to_s
    end
    var_map[dst] = "sext(#{val}, #{width})"
    ""
    
  when :add
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} + #{b})"
    ""
    
  when :sub
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} - #{b})"
    ""
    
  when :and
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} & #{b})"
    ""
    
  when :or
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} | #{b})"
    ""
    
  when :xor
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} ^ #{b})"
    ""
    
  when :shl
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} << (#{b} & 31))"
    ""
    
  when :shr_u
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} >> (#{b} & 31))"
    ""
    
  when :shr_s
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(static_cast<int32_t>(#{a}) >> (#{b} & 31))"
    ""
    
  when :lt_s
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(static_cast<int32_t>(#{a}) < static_cast<int32_t>(#{b}) ? 1 : 0)"
    ""
    
  when :lt_u
    a = get_value(stmt.oprnds[1], var_map, args_map)
    b = get_value(stmt.oprnds[2], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "(#{a} < #{b} ? 1 : 0)"
    ""
    
  when :load_byte
    addr = get_value(stmt.oprnds[1], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "static_cast<int8_t>(mem[#{addr}])"
    ""
    
  when :load_halfword
    addr = get_value(stmt.oprnds[1], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "static_cast<int16_t>(*reinterpret_cast<uint16_t*>(mem + #{addr}))"
    ""
    
  when :load_word
    addr = get_value(stmt.oprnds[1], var_map, args_map)
    var_map[stmt.oprnds[0].name] = "*reinterpret_cast<uint32_t*>(mem + #{addr})"
    ""
    
  when :store_byte
    addr = get_value(stmt.oprnds[1], var_map, args_map)
    val = get_value(stmt.oprnds[2], var_map, args_map)
    "mem[#{addr}] = #{val};"
    
  when :store_halfword
    addr = get_value(stmt.oprnds[1], var_map, args_map)
    val = get_value(stmt.oprnds[2], var_map, args_map)
    "*reinterpret_cast<uint16_t*>(mem + #{addr}) = #{val};"
    
  when :store_word
    addr = get_value(stmt.oprnds[1], var_map, args_map)
    val = get_value(stmt.oprnds[2], var_map, args_map)
    "*reinterpret_cast<uint32_t*>(mem + #{addr}) = #{val};"
    
  when :branch_eq
    rs1 = get_value(stmt.oprnds[0], var_map, args_map)
    rs2 = get_value(stmt.oprnds[1], var_map, args_map)
    offset = get_value(stmt.oprnds[2], var_map, args_map)
    "if (#{rs1} == #{rs2}) { pc += #{offset} - 4; return; }"
    
  when :branch_ne
    rs1 = get_value(stmt.oprnds[0], var_map, args_map)
    rs2 = get_value(stmt.oprnds[1], var_map, args_map)
    offset = get_value(stmt.oprnds[2], var_map, args_map)
    "if (#{rs1} != #{rs2}) { pc += #{offset} - 4; return; }"
    
  when :branch_lt
    rs1 = get_value(stmt.oprnds[0], var_map, args_map)
    rs2 = get_value(stmt.oprnds[1], var_map, args_map)
    offset = get_value(stmt.oprnds[2], var_map, args_map)
    "if (static_cast<int32_t>(#{rs1}) < static_cast<int32_t>(#{rs2})) { pc += #{offset} - 4; return; }"
    
  when :branch_ge
    rs1 = get_value(stmt.oprnds[0], var_map, args_map)
    rs2 = get_value(stmt.oprnds[1], var_map, args_map)
    offset = get_value(stmt.oprnds[2], var_map, args_map)
    "if (static_cast<int32_t>(#{rs1}) >= static_cast<int32_t>(#{rs2})) { pc += #{offset} - 4; return; }"
    
  when :branch_ltu
    rs1 = get_value(stmt.oprnds[0], var_map, args_map)
    rs2 = get_value(stmt.oprnds[1], var_map, args_map)
    offset = get_value(stmt.oprnds[2], var_map, args_map)
    "if (#{rs1} < #{rs2}) { pc += #{offset} - 4; return; }"
    
  when :branch_geu
    rs1 = get_value(stmt.oprnds[0], var_map, args_map)
    rs2 = get_value(stmt.oprnds[1], var_map, args_map)
    offset = get_value(stmt.oprnds[2], var_map, args_map)
    "if (#{rs1} >= #{rs2}) { pc += #{offset} - 4; return; }"
    
  when :set_pc
    target = get_value(stmt.oprnds[0], var_map, args_map)
    "pc = #{target};"
    
  when :setreg
    dst_arg = stmt.oprnds[0]
    val = get_value(stmt.oprnds[1], var_map, args_map)
    "reg[#{dst_arg.name}] = #{val};"
    
  when :read_csr
    dst = stmt.oprnds[0].name
    csr = get_value(stmt.oprnds[1], var_map, args_map)
    var_map[dst] = "read_csr(#{csr})"
    ""
    
  when :write_csr
    csr = get_value(stmt.oprnds[0], var_map, args_map)
    val = get_value(stmt.oprnds[1], var_map, args_map)
    "write_csr(#{csr}, #{val});"
    
  else
    "#error \"Unknown IR stmt: #{stmt.name}\""
  end
end

def get_value(oprnd, var_map, args_map)
  if oprnd.is_a?(SimInfra::Var)
    var_map.fetch(oprnd.name, "0")
  elsif oprnd.is_a?(SimInfra::XReg) || oprnd.is_a?(SimInfra::Immediate)
    args_map[oprnd.name]
  else
    oprnd.to_s
  end
end

# === Генерация ===
puts '#include "executor.hpp"'
puts ""

instructions.each do |instr|
  # Создаем карту аргументов
  args_map = {}
  instr.args.each do |arg|
    if arg.is_a?(SimInfra::XReg)
      args_map[arg.name] = "reg[#{arg.name}]"
    elsif arg.is_a?(SimInfra::Immediate)
      args_map[arg.name] = arg.name.to_s
    end
  end
  
  params = instr.args.map do |arg|
    if arg.is_a?(SimInfra::XReg) || arg.is_a?(SimInfra::Immediate)
      "uint32_t #{arg.name}"
    end
  end
  puts "void execute_#{instr.name}(#{params.join(', ')}) {"
  
  var_map = {}
  code_lines = []
  
  instr.code.tree.each do |stmt|
    line = emit_ir_stmt(stmt, var_map, args_map, 1)
    code_lines << "  #{line}" unless line.empty?
  end
  
  # Оборачиваем setreg в проверку x0
  has_rd = instr.args.any? { |arg| arg.is_a?(SimInfra::XReg) && arg.name == :rd }
  if has_rd
    new_lines = []
    code_lines.each do |line|
      if line.include?("reg[rd] =")
        new_lines << "  if (rd != 0) {"
        new_lines << "    #{line.strip}"
        new_lines << "  }"
      else
        new_lines << line
      end
    end
    code_lines = new_lines
  end
  
  puts code_lines.join("\n")
  puts "}"
  puts ""
end