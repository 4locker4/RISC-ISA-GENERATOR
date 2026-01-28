#include <cstdint>
#include <stdexcept>
#include "executor.hpp"


static inline void extract_args_ADD(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_SUB(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_LUI(uint32_t insn, uint32_t& rd, uint32_t& imm) {
  rd = (insn >> 7) & 31;
  imm = ((insn >> 12) & 1048575) << 0;
}



static inline void extract_args_AUIPC(uint32_t insn, uint32_t& rd, uint32_t& imm) {
  rd = (insn >> 7) & 31;
  imm = ((insn >> 12) & 1048575) << 0;
}



static inline void extract_args_ADDI(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& imm) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  imm = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_SLTI(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& imm) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  imm = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_SLTIU(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& imm) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  imm = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_XORI(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& imm) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  imm = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_ORI(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& imm) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  imm = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_ANDI(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& imm) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  imm = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_SLLI(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& shamt) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  shamt = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_SRLI(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& shamt) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  shamt = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_SLL(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_SLT(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_SLTU(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_XOR(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_SRL(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_SRA(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_OR(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_AND(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& rs2) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
}



static inline void extract_args_FENCE(uint32_t insn, uint32_t& pred, uint32_t& succ) {
  pred = ((insn >> 20) & 15) << 0 | ((insn >> 24) & 15) << 4 | ((insn >> 28) & 15) << 8;
}



static inline void extract_args_FENCEI(uint32_t insn) {

}



static inline void extract_args_CSRRW(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& csr) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  csr = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_CSRRC(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& csr) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  csr = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_CSRRS(uint32_t insn, uint32_t& rd, uint32_t& csr, uint32_t& rs1) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  csr = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_CSRRWI(uint32_t insn, uint32_t& rd, uint32_t& csr, uint32_t& uimm) {
  rd = (insn >> 7) & 31;
  csr = ((insn >> 15) & 31) << 0 | ((insn >> 20) & 4095) << 5;
}



static inline void extract_args_CSRRCI(uint32_t insn, uint32_t& rd, uint32_t& csr, uint32_t& uimm) {
  rd = (insn >> 7) & 31;
  csr = ((insn >> 15) & 31) << 0 | ((insn >> 20) & 4095) << 5;
}



static inline void extract_args_CSRRSI(uint32_t insn, uint32_t& rd, uint32_t& csr, uint32_t& uimm) {
  rd = (insn >> 7) & 31;
  csr = ((insn >> 15) & 31) << 0 | ((insn >> 20) & 4095) << 5;
}



static inline void extract_args_ECALL(uint32_t insn) {

}



static inline void extract_args_EBREAK(uint32_t insn) {

}



static inline void extract_args_SRET(uint32_t insn) {

}



static inline void extract_args_MRET(uint32_t insn) {

}



static inline void extract_args_WFI(uint32_t insn) {

}



static inline void extract_args_SFENCE_VMA(uint32_t insn, uint32_t& rs1, uint32_t& rs2) {

}



static inline void extract_args_LB(uint32_t insn, uint32_t& rd, uint32_t& offset, uint32_t& rs1) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  offset = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_LH(uint32_t insn, uint32_t& rd, uint32_t& offset, uint32_t& rs1) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  offset = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_LBU(uint32_t insn, uint32_t& rd, uint32_t& offset, uint32_t& rs1) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  offset = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_LHU(uint32_t insn, uint32_t& rd, uint32_t& offset, uint32_t& rs1) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  offset = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_SB(uint32_t insn, uint32_t& rs2, uint32_t& offset, uint32_t& rs1) {
  rs1 = (insn >> 20) & 31;
  rs2 = (insn >> 15) & 31;
  offset = ((insn >> 7) & 31) << 0 | ((insn >> 25) & 127) << 5;
}



static inline void extract_args_SH(uint32_t insn, uint32_t& rs2, uint32_t& offset, uint32_t& rs1) {
  rs1 = (insn >> 20) & 31;
  rs2 = (insn >> 15) & 31;
  offset = ((insn >> 7) & 31) << 0 | ((insn >> 25) & 127) << 5;
}



static inline void extract_args_SW(uint32_t insn, uint32_t& rs2, uint32_t& offset, uint32_t& rs1) {
  rs1 = (insn >> 20) & 31;
  rs2 = (insn >> 15) & 31;
  offset = ((insn >> 7) & 31) << 0 | ((insn >> 25) & 127) << 5;
}



static inline void extract_args_JAL(uint32_t insn, uint32_t& rd, uint32_t& offset) {
  rd = (insn >> 7) & 31;
  offset = ((insn >> 21) & 1023) << 0 | ((insn >> 20) & 1) << 10 | ((insn >> 12) & 255) << 11 | ((insn >> 31) & 1) << 19;
}



static inline void extract_args_JALR(uint32_t insn, uint32_t& rd, uint32_t& rs1, uint32_t& offset) {
  rs1 = (insn >> 15) & 31;
  rd = (insn >> 7) & 31;
  offset = ((insn >> 20) & 4095) << 0;
}



static inline void extract_args_BEQ(uint32_t insn, uint32_t& rs1, uint32_t& rs2, uint32_t& offset) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  offset = ((insn >> 8) & 15) << 0 | ((insn >> 25) & 63) << 4 | ((insn >> 7) & 1) << 10 | ((insn >> 31) & 1) << 11;
}



static inline void extract_args_BNE(uint32_t insn, uint32_t& rs1, uint32_t& rs2, uint32_t& offset) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  offset = ((insn >> 8) & 15) << 0 | ((insn >> 25) & 63) << 4 | ((insn >> 7) & 1) << 10 | ((insn >> 31) & 1) << 11;
}



static inline void extract_args_BLT(uint32_t insn, uint32_t& rs1, uint32_t& rs2, uint32_t& offset) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  offset = ((insn >> 8) & 15) << 0 | ((insn >> 25) & 63) << 4 | ((insn >> 7) & 1) << 10 | ((insn >> 31) & 1) << 11;
}



static inline void extract_args_BGE(uint32_t insn, uint32_t& rs1, uint32_t& rs2, uint32_t& offset) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  offset = ((insn >> 8) & 15) << 0 | ((insn >> 25) & 63) << 4 | ((insn >> 7) & 1) << 10 | ((insn >> 31) & 1) << 11;
}



static inline void extract_args_BLTU(uint32_t insn, uint32_t& rs1, uint32_t& rs2, uint32_t& offset) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  offset = ((insn >> 8) & 15) << 0 | ((insn >> 25) & 63) << 4 | ((insn >> 7) & 1) << 10 | ((insn >> 31) & 1) << 11;
}



static inline void extract_args_BGEU(uint32_t insn, uint32_t& rs1, uint32_t& rs2, uint32_t& offset) {
  rs2 = (insn >> 20) & 31;
  rs1 = (insn >> 15) & 31;
  offset = ((insn >> 8) & 15) << 0 | ((insn >> 25) & 63) << 4 | ((insn >> 7) & 1) << 10 | ((insn >> 31) & 1) << 11;
}


void execute_ADD(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_SUB(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_LUI(uint32_t rd, int32_t imm);
void execute_AUIPC(uint32_t rd, int32_t imm);
void execute_ADDI(uint32_t rd, uint32_t rs1, int32_t imm);
void execute_SLTI(uint32_t rd, uint32_t rs1, int32_t imm);
void execute_SLTIU(uint32_t rd, uint32_t rs1, int32_t imm);
void execute_XORI(uint32_t rd, uint32_t rs1, int32_t imm);
void execute_ORI(uint32_t rd, uint32_t rs1, int32_t imm);
void execute_ANDI(uint32_t rd, uint32_t rs1, int32_t imm);
void execute_SLLI(uint32_t rd, uint32_t rs1, int32_t shamt);
void execute_SRLI(uint32_t rd, uint32_t rs1, int32_t shamt);
void execute_SLL(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_SLT(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_SLTU(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_XOR(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_SRL(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_SRA(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_OR(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_AND(uint32_t rd, uint32_t rs1, uint32_t rs2);
void execute_FENCE(int32_t pred, int32_t succ);
void execute_FENCEI();
void execute_CSRRW(uint32_t rd, uint32_t rs1, int32_t csr);
void execute_CSRRC(uint32_t rd, uint32_t rs1, int32_t csr);
void execute_CSRRS(uint32_t rd, int32_t csr, uint32_t rs1);
void execute_CSRRWI(uint32_t rd, int32_t csr, int32_t uimm);
void execute_CSRRCI(uint32_t rd, int32_t csr, int32_t uimm);
void execute_CSRRSI(uint32_t rd, int32_t csr, int32_t uimm);
void execute_ECALL();
void execute_EBREAK();
void execute_SRET();
void execute_MRET();
void execute_WFI();
void execute_SFENCE_VMA(uint32_t rs1, uint32_t rs2);
void execute_LB(uint32_t rd, int32_t offset, uint32_t rs1);
void execute_LH(uint32_t rd, int32_t offset, uint32_t rs1);
void execute_LBU(uint32_t rd, int32_t offset, uint32_t rs1);
void execute_LHU(uint32_t rd, int32_t offset, uint32_t rs1);
void execute_SB(uint32_t rs2, int32_t offset, uint32_t rs1);
void execute_SH(uint32_t rs2, int32_t offset, uint32_t rs1);
void execute_SW(uint32_t rs2, int32_t offset, uint32_t rs1);
void execute_JAL(uint32_t rd, int32_t offset);
void execute_JALR(uint32_t rd, uint32_t rs1, int32_t offset);
void execute_BEQ(uint32_t rs1, uint32_t rs2, int32_t offset);
void execute_BNE(uint32_t rs1, uint32_t rs2, int32_t offset);
void execute_BLT(uint32_t rs1, uint32_t rs2, int32_t offset);
void execute_BGE(uint32_t rs1, uint32_t rs2, int32_t offset);
void execute_BLTU(uint32_t rs1, uint32_t rs2, int32_t offset);
void execute_BGEU(uint32_t rs1, uint32_t rs2, int32_t offset);

void decode_and_execute(uint32_t insn) {
  switch ((insn & 0x0000007F) >> 0) {
  case 35:
    switch ((insn & 0x00002000) >> 13) {
    case 0:
      switch ((insn & 0x00001000) >> 12) {
      case 0:
        uint32_t rs2, offset, rs1;
        extract_args_SB(insn, rs2, offset, rs1);
        execute_SB(rs2, offset, rs1);
        return;
        break;
      case 1:
        uint32_t rs2, offset, rs1;
        extract_args_SH(insn, rs2, offset, rs1);
        execute_SH(rs2, offset, rs1);
        return;
        break;
      default:
        throw std::runtime_error("illegal instruction");
      }
      break;
    case 1:
      uint32_t rs2, offset, rs1;
      extract_args_SW(insn, rs2, offset, rs1);
      execute_SW(rs2, offset, rs1);
      return;
      break;
    default:
      throw std::runtime_error("illegal instruction");
    }
    break;
  case 55:
    uint32_t rd, imm;
    extract_args_LUI(insn, rd, imm);
    execute_LUI(rd, imm);
    return;
    break;
  case 96:
    switch ((insn & 0x00007000) >> 12) {
    case 0:
      uint32_t rd, offset, rs1;
      extract_args_LB(insn, rd, offset, rs1);
      execute_LB(rd, offset, rs1);
      return;
      break;
    case 1:
      uint32_t rd, offset, rs1;
      extract_args_LBU(insn, rd, offset, rs1);
      execute_LBU(rd, offset, rs1);
      return;
      break;
    case 4:
      uint32_t rd, offset, rs1;
      extract_args_LH(insn, rd, offset, rs1);
      execute_LH(rd, offset, rs1);
      return;
      break;
    case 5:
      uint32_t rd, offset, rs1;
      extract_args_LHU(insn, rd, offset, rs1);
      execute_LHU(rd, offset, rs1);
      return;
      break;
    default:
      throw std::runtime_error("illegal instruction");
    }
    break;
  case 99:
    switch ((insn & 0x00007000) >> 12) {
    case 0:
      uint32_t rs1, rs2, offset;
      extract_args_BEQ(insn, rs1, rs2, offset);
      execute_BEQ(rs1, rs2, offset);
      return;
      break;
    case 1:
      uint32_t rs1, rs2, offset;
      extract_args_BLT(insn, rs1, rs2, offset);
      execute_BLT(rs1, rs2, offset);
      return;
      break;
    case 3:
      uint32_t rs1, rs2, offset;
      extract_args_BLTU(insn, rs1, rs2, offset);
      execute_BLTU(rs1, rs2, offset);
      return;
      break;
    case 4:
      uint32_t rs1, rs2, offset;
      extract_args_BNE(insn, rs1, rs2, offset);
      execute_BNE(rs1, rs2, offset);
      return;
      break;
    case 5:
      uint32_t rs1, rs2, offset;
      extract_args_BGE(insn, rs1, rs2, offset);
      execute_BGE(rs1, rs2, offset);
      return;
      break;
    case 7:
      uint32_t rs1, rs2, offset;
      extract_args_BGEU(insn, rs1, rs2, offset);
      execute_BGEU(rs1, rs2, offset);
      return;
      break;
    default:
      throw std::runtime_error("illegal instruction");
    }
    break;
  case 100:
    switch ((insn & 0x00007000) >> 12) {
    case 0:
      uint32_t rd, rs1, imm;
      extract_args_ADDI(insn, rd, rs1, imm);
      execute_ADDI(rd, rs1, imm);
      return;
      break;
    case 1:
      uint32_t rd, rs1, imm;
      extract_args_XORI(insn, rd, rs1, imm);
      execute_XORI(rd, rs1, imm);
      return;
      break;
    case 2:
      uint32_t rd, rs1, imm;
      extract_args_SLTI(insn, rd, rs1, imm);
      execute_SLTI(rd, rs1, imm);
      return;
      break;
    case 3:
      uint32_t rd, rs1, imm;
      extract_args_ORI(insn, rd, rs1, imm);
      execute_ORI(rd, rs1, imm);
      return;
      break;
    case 4:
      uint32_t rd, rs1, shamt;
      extract_args_SLLI(insn, rd, rs1, shamt);
      execute_SLLI(rd, rs1, shamt);
      return;
      break;
    case 5:
      uint32_t rd, rs1, shamt;
      extract_args_SRLI(insn, rd, rs1, shamt);
      execute_SRLI(rd, rs1, shamt);
      return;
      break;
    case 6:
      uint32_t rd, rs1, imm;
      extract_args_SLTIU(insn, rd, rs1, imm);
      execute_SLTIU(rd, rs1, imm);
      return;
      break;
    case 7:
      uint32_t rd, rs1, imm;
      extract_args_ANDI(insn, rd, rs1, imm);
      execute_ANDI(rd, rs1, imm);
      return;
      break;
    default:
      throw std::runtime_error("illegal instruction");
    }
    break;
  case 102:
    switch ((insn & 0x0C000000) >> 26) {
    case 0:
      switch ((insn & 0x00007000) >> 12) {
      case 0:
        uint32_t rd, rs1, rs2;
        extract_args_ADD(insn, rd, rs1, rs2);
        execute_ADD(rd, rs1, rs2);
        return;
        break;
      case 1:
        uint32_t rd, rs1, rs2;
        extract_args_XOR(insn, rd, rs1, rs2);
        execute_XOR(rd, rs1, rs2);
        return;
        break;
      case 2:
        uint32_t rd, rs1, rs2;
        extract_args_SLT(insn, rd, rs1, rs2);
        execute_SLT(rd, rs1, rs2);
        return;
        break;
      case 3:
        uint32_t rd, rs1, rs2;
        extract_args_OR(insn, rd, rs1, rs2);
        execute_OR(rd, rs1, rs2);
        return;
        break;
      case 4:
        uint32_t rd, rs1, rs2;
        extract_args_SLL(insn, rd, rs1, rs2);
        execute_SLL(rd, rs1, rs2);
        return;
        break;
      case 5:
        uint32_t rd, rs1, rs2;
        extract_args_SRL(insn, rd, rs1, rs2);
        execute_SRL(rd, rs1, rs2);
        return;
        break;
      case 6:
        uint32_t rd, rs1, rs2;
        extract_args_SLTU(insn, rd, rs1, rs2);
        execute_SLTU(rd, rs1, rs2);
        return;
        break;
      case 7:
        uint32_t rd, rs1, rs2;
        extract_args_AND(insn, rd, rs1, rs2);
        execute_AND(rd, rs1, rs2);
        return;
        break;
      default:
        throw std::runtime_error("illegal instruction");
      }
      break;
    case 1:
      uint32_t rd, rs1, rs2;
      extract_args_SRA(insn, rd, rs1, rs2);
      execute_SRA(rd, rs1, rs2);
      return;
      break;
    case 3:
      uint32_t rd, rs1, rs2;
      extract_args_SUB(insn, rd, rs1, rs2);
      execute_SUB(rd, rs1, rs2);
      return;
      break;
    default:
      throw std::runtime_error("illegal instruction");
    }
    break;
  case 103:
    switch ((insn & 0x1F800000) >> 23) {
    case 0:
      switch ((insn & 0x00100000) >> 20) {
      case 0:
        switch ((insn & 0x00007000) >> 12) {
        case 0:
          execute_ECALL();
          return;
          break;
        case 2:
          uint32_t rd, csr, rs1;
          extract_args_CSRRS(insn, rd, csr, rs1);
          execute_CSRRS(rd, csr, rs1);
          return;
          break;
        case 3:
          uint32_t rd, csr, uimm;
          extract_args_CSRRSI(insn, rd, csr, uimm);
          execute_CSRRSI(rd, csr, uimm);
          return;
          break;
        case 4:
          uint32_t rd, rs1, csr;
          extract_args_CSRRW(insn, rd, rs1, csr);
          execute_CSRRW(rd, rs1, csr);
          return;
          break;
        case 5:
          uint32_t rd, csr, uimm;
          extract_args_CSRRWI(insn, rd, csr, uimm);
          execute_CSRRWI(rd, csr, uimm);
          return;
          break;
        case 6:
          uint32_t rd, rs1, csr;
          extract_args_CSRRC(insn, rd, rs1, csr);
          execute_CSRRC(rd, rs1, csr);
          return;
          break;
        case 7:
          uint32_t rd, csr, uimm;
          extract_args_CSRRCI(insn, rd, csr, uimm);
          execute_CSRRCI(rd, csr, uimm);
          return;
          break;
        default:
          throw std::runtime_error("illegal instruction");
        }
        break;
      case 1:
        execute_EBREAK();
        return;
        break;
      default:
        throw std::runtime_error("illegal instruction");
      }
      break;
    case 33:
      execute_SRET();
      return;
      break;
    case 34:
      execute_WFI();
      return;
      break;
    case 36:
      uint32_t rs1, rs2;
      extract_args_SFENCE_VMA(insn, rs1, rs2);
      execute_SFENCE_VMA(rs1, rs2);
      return;
      break;
    case 49:
      execute_MRET();
      return;
      break;
    default:
      throw std::runtime_error("illegal instruction");
    }
    break;
  case 115:
    uint32_t rd, rs1, offset;
    extract_args_JALR(insn, rd, rs1, offset);
    execute_JALR(rd, rs1, offset);
    return;
    break;
  case 116:
    uint32_t rd, imm;
    extract_args_AUIPC(insn, rd, imm);
    execute_AUIPC(rd, imm);
    return;
    break;
  case 120:
    switch ((insn & 0x00004000) >> 14) {
    case 0:
      uint32_t pred, succ;
      extract_args_FENCE(insn, pred, succ);
      execute_FENCE(pred, succ);
      return;
      break;
    case 1:
      execute_FENCEI();
      return;
      break;
    default:
      throw std::runtime_error("illegal instruction");
    }
    break;
  case 123:
    uint32_t rd, offset;
    extract_args_JAL(insn, rd, offset);
    execute_JAL(rd, offset);
    return;
    break;
  default:
    throw std::runtime_error("illegal instruction");
  }
  throw std::runtime_error("unreachable");
}
