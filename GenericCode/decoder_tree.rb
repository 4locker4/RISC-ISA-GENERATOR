module SimGen
  class DecoderTree
    # Возвращает хэш вида:
    # {
    #   "range" => [msb, lsb],
    #   "nodes" => {
    #     node_value => result_or_subtree_hash
    #   }
    # }
    def make_tree(instructions)
      return nil if instructions.empty?

      lead_bits = get_lead_bits(instructions)
      maj_range = get_maj_range(lead_bits)
      msb, lsb = maj_range[0], maj_range[1]
      width = msb - lsb + 1

      tree = {
        "range" => [msb, lsb],
        "nodes" => {}
      }

      (0...(1 << width)).each do |node_value|
        actual_node = node_value << lsb
        subtree = {}

        is_leaf, result = make_child(
          actual_node,
          ((1 << width) - 1) << lsb,
          instructions,
          subtree
        )

        if is_leaf
          tree["nodes"][node_value] = result
        elsif subtree.any?
          tree["nodes"][node_value] = subtree
        end
      end

      tree
    end

    private

    # Вычисляет общий битовый префикс всех инструкций
    def get_lead_bits(instructions)
      return 0 if instructions.empty?

      patterns = instructions.map { |insn| fixed_pattern(insn)[:value] }
      patterns.reduce(:&)
    end

    # Возвращает [lsb, msb] - диапазон старших установленных битов в lead_bits
    def get_maj_range(lead_bits)
      return [0, 0] if lead_bits.zero?

      msb = lead_bits.bit_length - 1
      lsb = lead_bits.trailing_zero_count
      [lsb, msb]
    end

    # Возвращает { mask: Integer, value: Integer } для инструкции
    def fixed_pattern(insn)
      mask = 0
      value = 0

      insn[:fields].each do |field|
        next if field.value == :reg || field.is_a?(SimInfra::ImmFieldPart)

        width = field.from - field.to + 1
        field_mask = ((1 << width) - 1) << field.to

        mask |= field_mask
        value |= (field.value << field.to)
      end

      { mask: mask, value: value }
    end

    def make_child(actual_node, separ_mask, instructions, current_subtree)
      sublist = instructions.select do |insn|
        pattern = fixed_pattern(insn)
        (pattern[:value] & separ_mask) == actual_node
      end

      return [true, sublist.first] if sublist.length == 1
      return [false, nil] if sublist.empty?

      lead_bits = get_lead_bits(sublist)
      maj_range = get_maj_range(lead_bits)
      msb, lsb = maj_range[0], maj_range[1]
      width = msb - lsb + 1

      current_subtree["range"] = [msb, lsb]
      current_subtree["nodes"] = {}

      new_mask = separ_mask | (((1 << width) - 1) << lsb)

      (0...(1 << width)).each do |node_value|
        actual_node_next = node_value << lsb
        child_subtree = {}

        is_leaf, result = make_child(
          actual_node_next,
          new_mask,
          sublist,
          child_subtree
        )

        if is_leaf
          current_subtree["nodes"][node_value] = result
        elsif child_subtree.any?
          current_subtree["nodes"][node_value] = child_subtree
        end
      end

      [false, nil]
    end
  end
end