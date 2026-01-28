require_relative "encoding"
require_relative "regfile"
require_relative "../../GenericIR/base"

module RV32I
    extend SimInfra
    Instruction(:ADD, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:add, rd, rs1, rs2)
        asm { "ADD #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 + rs2 }
    }

    Instruction(:SUB, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sub, rd, rs1, rs2)
        asm { "SUB #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 - rs2 }
    }

    Instruction(:LUI, XReg(:rd), Imm(:imm)) {
        encoding *format_u_funct(:lui, rd, imm)
        asm { "LUI #{rd}, #{imm}" }
        code { rd[]= sext(imm, 20) << 12 }
    }

    Instruction(:AUIPC, XReg(:rd), Imm(:imm)) {
        encoding *format_u_funct(:auipc, rd, imm)
        asm { "AUIPC #{rd}, #{imm}" }
        code { rd[]= pc + (sext(imm, 20) << 12) }
    }

    Instruction(:ADDI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_funct(:addi, rd, rs1, imm)
        asm { "ADDI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 + sext(imm, 12)}
    }

    Instruction(:SLTI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_funct(:slti, rd, rs1, imm)
        asm { "SLTI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= lt_s(rs1, sext(imm, 12)) }
    }

    Instruction(:SLTIU, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_funct(:sltiu, rd, rs1, imm)
        asm { "SLTI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= lt_u(rs1, sext(imm, 12)) }
    }

    Instruction(:XORI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_funct(:xori, rd, rs1, imm)
        asm { "XORI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 ^ sext(imm, 12) }
    }

    Instruction(:ORI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
      encoding *format_i_funct(:ori, rd, rs1, imm)
      asm { "ORI #{rd}, #{rs1}, #{imm}" }
      code { rd[]= rs1 | (sext(imm, 12)) }
    }

    Instruction(:ANDI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
      encoding *format_i_funct(:andi, rd, rs1, imm)
      asm { "ANDI #{rd}, #{rs1}, #{imm}" }
      code { rd[]= rs1 & (sext(imm, 12)) }
    }

    Instruction(:SLLI, XReg(:rd), XReg(:rs1), Imm(:shamt)) {
        encoding *format_i_funct(:slli, rd, rs1, shamt)
        asm { "SLLI #{rd}, #{rs1}, #{shamt}" }
        code { rd[]= rs1 << (shamt & 0x1F) }
    }

    Instruction(:SRLI, XReg(:rd), XReg(:rs1), Imm(:shamt)) {
        encoding *format_i_funct(:srli, rd, rs1, shamt)
        asm { "SRLI #{rd}, #{rs1}, #{shamt}" }
        code { rd[]= shr_u(rs1, (shamt & 0x1F)) }
    }

    # Instruction(:SRAI, XReg(:rd), XReg(:rs1), Imm(:shamt)) {
    #     encoding *format_i_funct(:srai, rd, rs1, shamt)
    #     asm { "SRAI #{rd}, #{rs1}, #{shamt}" }
    #     code { rd[]= shr_s(rs1, (shamt & 0x1F)) }
    # }

    Instruction(:SLL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sll, rd, rs1, rs2)
        asm { "SLL #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 << rs2 }
    }

    Instruction(:SLT, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:slt, rd, rs1, rs2)
        asm { "SLT #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= lt_s(rs1, rs2) }
    }

    Instruction(:SLTU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sltu, rd, rs1, rs2)
        asm { "SLTU #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= lt_u(rs1, rs2) }
    }    

    Instruction(:XOR, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:xor, rd, rs1, rs2)
        asm { "XOR #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 ^ rs2 }
    }

    Instruction(:SRL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:srl, rd, rs1, rs2)
        asm { "SRL #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= shr_u(rs1, rs2) }
    }

    Instruction(:SRA, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sra, rd, rs1, rs2)
        asm { "SRA #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= shr_s(rs1, rs2) }
    }

    Instruction(:OR, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:or, rd, rs1, rs2)
        asm { "OR #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 | rs2}
    }

    Instruction(:AND, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:and, rd, rs1, rs2)
        asm { "AND #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 & rs2}
    }

    Instruction(:FENCE, Imm(:pred), Imm(:succ)) {
        encoding *format_fences(:fence, pred, succ)
        asm { "FENCE #{pred}, #{succ}" }
        code { }
    }

    Instruction(:FENCEI) {
        encoding *format_fences(:fencei, 0, 0)
        asm { "FENCE.I" }
        code { }
    }

    Instruction(:CSRRW, XReg(:rd), XReg(:rs1), Imm(:csr)) {
        encoding *format_i_funct(:csrrw, rd, rs1, csr)
        asm { "CSRRW #{rd}, #{csr}, #{rs1}" }
        code { rd[]= read_csr(csr); write_csr(csr, rs1) }
    }

    Instruction(:CSRRC, XReg(:rd), XReg(:rs1), Imm(:csr)) {
        encoding *format_i_funct(:csrrc, rd, rs1, csr)
        asm { "CSRRC #{rd}, #{csr}, #{rs1}" }
        code { rd[]= read_csr(csr); write_csr(csr, rd & ~rs1) }
    }

    Instruction(:CSRRS, XReg(:rd), Imm(:csr), XReg(:rs1)) {
        encoding *format_i_funct(:csrrs, rd, rs1, csr)
        asm { "CSRRS #{rd}, #{csr}, #{rs1}" }
        code { rd[]= read_csr(csr); write_csr(csr, rd | rs1) }
    }

    Instruction(:CSRRWI, XReg(:rd), Imm(:csr), Imm(:uimm)) {
        encoding *format_csrrwcsi(:csrrwi, rd, uimm, csr)
        asm { "CSRRWI #{rd}, #{csr}, #{uimm}" }
        code { rd[]= read_csr(csr); write_csr(csr, uimm) }
    }

    Instruction(:CSRRCI, XReg(:rd), Imm(:csr), Imm(:uimm)) {
        encoding *format_csrrwcsi(:csrrci, rd, uimm, csr)
        asm { "CSRRCI #{rd}, #{csr}, #{uimm}" }
        code {  rd[]= read_csr(csr); write_csr(csr, rd & ~uimm) }
    }

    Instruction(:CSRRSI, XReg(:rd), Imm(:csr), Imm(:uimm)) {
        encoding *format_csrrwcsi(:csrrsi, rd, uimm, csr)
        asm { "CSRRSI #{rd}, #{csr}, #{uimm}" }
        code { rd[]= read_csr(csr); write_csr(csr, rd | uimm) }
    }

    Instruction(:ECALL) {
        encoding *format_sys(:ecall)
        asm { "ECALL" }
        code { }
    }

    Instruction(:EBREAK) {
        encoding *format_sys(:ebreak)
        asm { "EBREAK" }
        code { }
    }

    Instruction(:SRET) {
        encoding *format_sys(:sret)
        asm { "SRET" }
        code { }
    }

    Instruction(:MRET) {
        encoding *format_sys(:mret)
        asm { "MRET" }
        code { }
    }

    Instruction(:WFI) {
        encoding *format_sys(:wfi)
        asm { "WFI" }
        code { }
    }

    Instruction(:SFENCE_VMA, XReg(:rs1), XReg(:rs2)) {
        encoding *format_sfence_vma()
        asm { "SFENCE.VMA #{rs1}, #{rs2}" }
        code {}
    }

    Instruction(:LB, XReg(:rd), Imm(:offset), XReg(:rs1)) {
        encoding *format_i_funct(:lb, rd, rs1, offset)
        asm { "LB #{rd}, #{offset}(#{rs1})" }
        code { rd[] = sext(load_byte(rs1 + sext(offset, 12)), 8) }
    }

    Instruction(:LH, XReg(:rd), Imm(:offset), XReg(:rs1)) {
        encoding *format_i_funct(:lh, rd, rs1, offset)
        asm { "LH #{rd}, #{offset}(#{rs1})" }
        code { rd[] = sext(load_halfword(rs1 + sext(offset, 12)), 16) }
    }

    Instruction(:LBU, XReg(:rd), Imm(:offset), XReg(:rs1)) {
        encoding *format_i_funct(:lbu, rd, rs1, offset)
        asm { "LBU #{rd}, #{offset}(#{rs1})" }
        code { rd[] = load_byte(rs1 + sext(offset, 12)) }
    }

    Instruction(:LHU, XReg(:rd), Imm(:offset), XReg(:rs1)) {
        encoding *format_i_funct(:lhu, rd, rs1, offset)
        asm { "LHU #{rd}, #{offset}(#{rs1})" }
        code { rd[] = load_halfword(rs1 + sext(offset, 12)) }
    }

    Instruction(:SB, XReg(:rs2), Imm(:offset), XReg(:rs1)) {
        encoding *format_s_funct(:sb, rs2, rs1, offset)
        asm { "SB #{rs2}, #{offset}(#{rs1})" }
        code { store_byte(rs1 + sext(offset, 12), rs2 & 0xFF) }
    }

    Instruction(:SH, XReg(:rs2), Imm(:offset), XReg(:rs1)) {
        encoding *format_s_funct(:sh, rs2, rs1, offset)
        asm { "SH #{rs2}, #{offset}(#{rs1})" }
        code { store_halfword(rs1 + sext(offset, 12), rs2 & 0xFFFF) }
    }

    Instruction(:SW, XReg(:rs2), Imm(:offset), XReg(:rs1)) {
        encoding *format_s_funct(:sw, rs2, rs1, offset)
        asm { "SW #{rs2}, #{offset}(#{rs1})" }
        code { store_word(rs1 + sext(offset, 12), rs2) }
    }

    Instruction(:JAL, XReg(:rd), Imm(:offset)) {
        encoding *format_jal(rd, offset)
        asm { "JAL #{rd}, #{offset}" }
        code {
            rd[] = get_pc + 4
            set_pc(get_pc + sext(offset, 21))
        }
    }
    
    Instruction(:JALR, XReg(:rd), XReg(:rs1), Imm(:offset)) {
        encoding *format_i_funct(:jalr, rd, rs1, offset)
        asm { "JALR #{rd}, #{offset}(#{rs1})" }
        code {
            rd[] = get_pc + 4
            set_pc((rs1 + sext(offset, 12)) & ~1)
        }
    }
    
    Instruction(:BEQ, XReg(:rs1), XReg(:rs2), Imm(:offset)) {
        encoding *format_b_funct(:beq, rs1, rs2, offset)
        asm { "BEQ #{rs1}, #{rs2}, #{offset}" }
        code { branch_eq(rs1, rs2, sext(offset, 13)) }
    }
    
    Instruction(:BNE, XReg(:rs1), XReg(:rs2), Imm(:offset)) {
        encoding *format_b_funct(:bne, rs1, rs2, offset)
        asm { "BNE #{rs1}, #{rs2}, #{offset}" }
        code { branch_ne(rs1, rs2, sext(offset, 13)) }
    }
    
    Instruction(:BLT, XReg(:rs1), XReg(:rs2), Imm(:offset)) {
        encoding *format_b_funct(:blt, rs1, rs2, offset)
        asm { "BLT #{rs1}, #{rs2}, #{offset}" }
        code { branch_lt(rs1, rs2, sext(offset, 13)) }
    }
    
    Instruction(:BGE, XReg(:rs1), XReg(:rs2), Imm(:offset)) {
        encoding *format_b_funct(:bge, rs1, rs2, offset)
        asm { "BGE #{rs1}, #{rs2}, #{offset}" }
        code { branch_ge(rs1, rs2, sext(offset, 13)) }
    }
    
    Instruction(:BLTU, XReg(:rs1), XReg(:rs2), Imm(:offset)) {
        encoding *format_b_funct(:bltu, rs1, rs2, offset)
        asm { "BLTU #{rs1}, #{rs2}, #{offset}" }
        code { branch_ltu(rs1, rs2, sext(offset, 13)) }
    }
    
    Instruction(:BGEU, XReg(:rs1), XReg(:rs2), Imm(:offset)) {
        encoding *format_b_funct(:bgeu, rs1, rs2, offset)
        asm { "BGEU #{rs1}, #{rs2}, #{offset}" }
        code { branch_geu(rs1, rs2, sext(offset, 13)) }
    }
end
