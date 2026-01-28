module SimInfra
  class InstrTree

    include SimInfra

    attr_reader :tree
    def initialize(instructions, bit_width: 32)
      @instructions = instructions
      @bit_width = bit_width
      @tree = MakeTree(@instructions, 0)
    end

    private

    def extract_pattern(instruction)
      pattern = 0
      instruction.fields.each do |field|
        if field.is_a?(SimInfra::Field) && field.value.is_a?(Integer)
          width = field.from - field.to + 1
          mask = (1 << width) - 1
          pattern |= (field.value & mask) << field.to
        end
      end
      pattern
    end

    def MakeTree(instructions, depth = 0)
      return instructions if depth > 5 || instructions.size <= 1
        
      # TD костыли подгоны
      if depth == 0
        range = [6, 0]
        msb, lsb = range[0], range[1]
        width = msb - lsb + 1
        mask = ((1 << width) - 1) << lsb
      
        tree = {
          "range" => range,
          "nodes" => {}
        }
      
        (0...1 << width).each do |value|
          node_value = value << lsb
          sublist = FilterInstructions(instructions, node_value, mask)
        
          next if sublist.empty?
        
          if sublist.size == 1
            tree["nodes"][value] = sublist
          else
            subtree = MakeTree(sublist, depth + 1)
            tree["nodes"][value] = subtree
          end
        end
      
        return tree
      end
    
      lead_bits = GetLeadBits(instructions)
      maj_range = GetMajRange(lead_bits, instructions, 0)
      lsb, msb = maj_range[0], maj_range[1]
    
      return instructions if lsb > msb || msb >= @bit_width
    
      width = msb - lsb + 1
      return instructions if width <= 0 || width > 16
    
      tree = {
        "range" => [msb, lsb],
        "nodes" => {}
      }
    
      mask = ((1 << width) - 1) << lsb
    
      (0...1 << width).each do |value|
        node_value = value << lsb
        sublist = FilterInstructions(instructions, node_value, mask)
      
        next if sublist.empty?
      
        if sublist.size == 1
          tree["nodes"][value] = sublist
        else
          subtree = MakeTree(sublist, depth + 1)
          tree["nodes"][value] = subtree if subtree
        end
      end
    
      tree
    end

    def MakeChild(node, separ_mask, instructions, current_subtree, depth = 0)
      return [false, nil] if depth > 64

      sublist = FilterInstructions(instructions, node, separ_mask)

      return [false, nil] if sublist.empty?
      return [true, sublist] if sublist.length == 1

      return [true, sublist] if sublist.length == instructions.length

      lead_bits = GetLeadBits(sublist, separ_mask)
      maj_range = GetMajRange(lead_bits, sublist, separ_mask)
      msb, lsb = maj_range[1], maj_range[0]

      return [true, sublist] if lsb > msb

      width = msb - lsb + 1

      return [true, sublist] if width <= 0 || width > 16

      current_subtree["range"] = [msb, lsb]
      current_subtree["nodes"] = {}

      new_mask = separ_mask | (((1 << width) - 1) << lsb)

      return [true, sublist] if new_mask == separ_mask

      (0...1 << width).each do |node_value|
        actual_node = node | (node_value << lsb)
        child_subtree = {}

        is_leaf, result = MakeChild(actual_node, new_mask, sublist, child_subtree, depth + 1)

        if is_leaf
          current_subtree["nodes"][node_value] = result
        elsif !child_subtree.empty?
          current_subtree["nodes"][node_value] = child_subtree
        end 
      end

      return [false, nil]
    end

    def GetLeadBits(instructions, separ_mask=0)
      return 0 if instructions.empty?

      patterns = instructions.map { |instr| extract_pattern(instr) }
      filtered = patterns.map { |pat| pat & separ_mask }

      lead_bits = filtered.first
      filtered.each { |pat| lead_bits &= pat }

      return lead_bits
    end 

    def GetMajRange(lead_bits, instructions = [], separ_mask = 0)
      return [0, 0] if instructions.empty?
    
      if lead_bits == 0
        patterns = instructions.map { |instr| extract_pattern(instr) }
        min_val = patterns.min
        max_val = patterns.max
        xor = min_val ^ max_val
        return [0, 0] if xor == 0
      
        msb = xor.bit_length - 1
        lsb = (xor & -xor).bit_length - 1
        return [lsb, msb]
      end
    
      msb = lead_bits.bit_length - 1
      lsb = (lead_bits & -lead_bits).bit_length - 1
      [lsb, msb]
    end

    def FilterInstructions(instructions, node, separ_mask)
      instructions.select do |instr|
        pattern = extract_pattern(instr)
        (pattern & separ_mask) == (node & separ_mask)
      end
    end
    
  end
end