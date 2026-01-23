require_relative "../../Generic/base"

module SimInfra
    def format_r(opcode, funct3, funct7, rd, rs1, rs2)
        return :R, [
            field(:funct7, 31, 25, funct7),
            field(rs2.name, 24, 20, :reg),
            field(rs1.name, 19, 15, :reg),
            field(:funct3, 14, 12, funct3),
            field(rd.name, 11, 7, :reg),
            field(:opcode, 6, 0, opcode),
        ]
    end

    def format_r_alu(name, rd, rs1, rs2)
        funct3, funct7 =
        {
            add: [0, 0],
            sub: [0, 0b110],
            sll: [0b100, 0],
            slt: [0b010, 0],
            sltu: [0b110, 0],
            xor: [0b001, 0],
            srl: [0b101, 0],
            sra: [0b101, 0b10],
            or: [0b011, 0],
            and: [0b111, 0],
        }[name]
        format_r(0b1100110, funct3, funct7, rd, rs1, rs2)
    end

    def format_i(opcode, funct3, rd, rs1, imm)
        return :I, [
            immpart(:imm, 31, 20, 31, 20),
            field(rs1.name, 19, 15, :reg),
            field(:funct3, 14, 12, funct3),
            field(rd.name, 11, 7, :reg),
            field(:opcode, 6, 0, opcode),
        ]
    end

    def format_i_funct(name, rd, rs1, imm)
        opcode, funct3 =
        {
            addi: [0b1100100, 0b000],
            slti: [0b1100100, 0b010],
            sltiu: [0b1100100, 0b110],
            xori: [0b1100100, 0b001],
            ori: [0b1100100, 0b011],
            andi: [0b1100100, 0b111],
            slli: [0b1100100, 0b100],
            srli: [0b1100100, 0b101],
            # srai: [0b1100100, 0b101],
            csrrw: [0b1100111, 0b100],
            csrrs: [0b1100111, 0b010],
            csrrc: [0b1100111, 0b110],
            lb: [0b1100000, 0b000],
            lh: [0b1100000, 0b100],
            lw: [0b1100000, 0b010],
            lbu: [0b1100000, 0b001],
            lhu: [0b1100000, 0b101],
            jalr: [0b1110011, 0b000],


        }[name]
        format_i(opcode, funct3, rd, rs1, imm)
    end

    def format_b_funct(name, rs1, rs2, imm)
        opcode, funct3 =
        {
            beq:  [0b1100011, 0b000],
            bne:  [0b1100011, 0b100],
            blt:  [0b1100011, 0b001],
            bge:  [0b1100011, 0b101],
            bltu: [0b1100011, 0b011],
            bgeu: [0b1100011, 0b111]
        }[name]
        format_b(opcode, funct3, rs1, rs2, imm)
    end
    
    def format_b(opcode, funct3, rs1, rs2, imm)
        return :B, [
            immpart(:imm, 31, 25, 31, 25),
            field(rs2.name, 24, 20, :reg),
            field(rs1.name, 19, 15, :reg),
            field(:funct3, 14, 12, funct3),
            immpart(:imm, 11, 7, 11, 7),
            field(:opcode, 6, 0, opcode)
        ]
    end
    
    def format_jal(rd, imm)
        return :J, [
            immpart(:imm, 31, 12, 31, 12),
            field(:rd, 11, 7, :reg),
            field(:opcode, 6, 0, 0b1110011)
        ]
    end

    def format_u(opcode, rd, imm)
        return :U, [
            immpart(:imm, 31, 12, 31, 12),
            field(rd.name, 11, 7, :reg),
            field(:opcode, 6, 0, opcode),
        ]
    end

    def format_u_funct(name, rd, imm)
        opcode = 
        {
            lui: 0b0110111,
            auipc: 0b1110100
        }[name]
        format_u(opcode, rd, imm)
    end

    def format_s(opcode, funct3, rs2, rs1, imm)
        return :S, [
            immpart(:imm, 31, 25, 31, 25),
            field(rs2.name, 24, 20, :reg),
            field(rs1.name, 19, 15, :reg),
            field(:funct3, 14, 12, funct3),
            immpart(:imm, 11, 7, 11, 7),
            field(:opcode, 6, 0, opcode),
        ]
    end
    
    def format_s_funct(name, rs2, rs1, imm)
        opcode, funct3 =
        {
            sb: [0b0100011, 0b000],
            sh: [0b0100011, 0b001],
            sw: [0b0100011, 0b010]
        }[name]

        format_s(opcode, funct3, rs2, rs1, imm)
    end

    # Посмотреть, как можно закинуть в I формат
    def format_fences(name, pred, succ)
        funct3 = 
        {
            fence: 0b000,
            fencei: 0b100
        }[name]

        return :I, [
            immpart(:fm, 31, 28, 31, 28),
            immpart(:pred, 27, 24, 27, 24),
            immpart(:succ, 23, 20, 23, 20),
            field(:rs1, 19, 15, 0),
            field(:funct3, 14, 12, funct3),
            field(:rd, 11, 7, 0),
            field(:opcode, 6, 0, 0b1111000),
        ]   
    end

    # Это тоже можно, вероятно, как-то обобщить
    def format_csrrwcsi(name, rd, uimm, csr)
        funct3 = 
        {
            csrrwi: 0b101,
            csrrci: 0b111,
            csrrsi: 0b011
        }[name]
        
        return :I, [
            immpart(:csr, 31, 20, 31, 20),
            immpart(:uimm, 19, 15, 19, 15),
            field(:funct3, 14, 12, funct3),
            field(rd.name, 11, 7,  :reg),
            field(:opcode, 6, 0,  0b1100111),
        ]
    end

    # Тоже возможно можно засунуть куда-то в другое место
    def format_sys(name)
        funct7, funct5 = {
            ecall: [0, 0],
            ebreak: [0, 1],
            sret: [0b0001000, 0b01000],
            mret: [0b0001100, 0b01000],
            wfi: [0b0001000, 0b10100],
        }[name]

        return :I, [
            field(:funct7, 31, 25, funct7),
            field(:funct5, 24, 20, funct5),
            field(:padding, 19, 7, 0),
            field(:opcode, 6, 0, 0b1100111),
        ]
    end

    def format_sfence_vma()
        return :R, [
            field(:funct7, 31, 25, 9),     # 0b0001001 = 9
            field(:rs2, 24, 20, 0),
            field(:rs1, 19, 15, 0),
            field(:funct3, 14, 12, 0),
            field(:rd, 11, 7, 0),
            field(:opcode, 6, 0, 0b1100111)    # 0b1110011 = 103
        ]
    end
end
