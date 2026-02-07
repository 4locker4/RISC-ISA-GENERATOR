module SimGen
  class MachineGen
    def initialize
      require 'yaml'

      # TD add cpu

      regs = YAML.load_file("../Registers.yaml")

      regfile_header = <<~CPP
      #include <cstdint>    // for uint32_t, uint8_t
      #include <cstring>    // for size_t, memcpy
      #include <fstream>    // for basic_ostream, operator<<, basic_ifstream, endl
      #include <iomanip>    // for operator<<, setfill, setw
      #include <iostream>   // for cout, cerr
      #include <stdexcept>  // for out_of_range, runtime_error
      #include <string>     // for char_traits, basic_string, string
      #include <vector>     // for vector
      #include <list>       // for list
          
      using namespace std;

      namespace Interpretator{

        typedef uint32_t reg_t; //TODO use registers type
        static const unsigned int N_REGISTERS = #{regs.size};

        class CPU_State {
          reg_t registers[N_REGISTERS];
          reg_t PC = 0;

          static constexpr bool const_register[N_REGISTERS] = {
      CPP
      
      const_registers = regs.map{ |r| !r[:const_val].nil? }

      const_registers.each { |is| regfile_header += "    #{is}, \n" }

      regfile_header += <<~CPP
          };

          static constexpr reg_t const_values[N_REGISTERS] = {
      CPP 
      
      const_values = regs.map{ |r| r[:const_val] || 0}

      const_values.each { |v| regfile_header += "    #{v}, \n" }

      regfile_header += <<~CPP
          };

          public:

          reg_t GetReg(uint32_t regNum) { return registers[regNum]; }
          void SetReg(uint32_t regNum, reg_t value) { registers[regNum] = value; }
    
          reg_t GetPC() { return PC; }
          void IncrPC(uint32_t value) { PC += value; }
          void SetPC(reg_t value) { PC = value; }
        };
      };
      CPP

      File.write("Simulation/includes/RegState.hpp")

      memory_header = <<~CPP
      
      #include <cstdint>    // for uint32_t, uint8_t
      #include <cstring>    // for size_t, memcpy
      #include <fstream>    // for basic_ostream, operator<<, basic_ifstream, endl
      #include <iomanip>    // for operator<<, setfill, setw
      #include <iostream>   // for cout, cerr
      #include <stdexcept>  // for out_of_range, runtime_error
      #include <string>     // for char_traits, basic_string, string
      #include <vector>     // for vector
      #include <list>       // for list
          
      using namespace std;

      namespace Interpretator{

        class Memory{
          vector<mem_t> memory;
      
          public:
      
          uint8_t read8(reg_t index) const {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }
            
              if (index + sizeof(mem_t) > memory.size()) {
                  throw std::out_of_range("ReadWord: address out of range");
              }
            
              uint32_t value;
              memcpy(&value, memory.data() + index, sizeof(uint8_t));
              return value;
          }

          uint16_t read16(reg_t index) const {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }
            
              if (index + sizeof(mem_t) > memory.size()) {
                  throw std::out_of_range("ReadWord: address out of range");
              }
            
              uint32_t value;
              memcpy(&value, memory.data() + index, sizeof(uint16_t));
              return value;
          }

          uint32_t read32(reg_t index) const {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }
            
              if (index + sizeof(mem_t) > memory.size()) {
                  throw std::out_of_range("ReadWord: address out of range");
              }
            
              uint32_t value;
              memcpy(&value, memory.data() + index, sizeof(uint32_t));
              return value;
          }

          uint64_t read64(reg_t index) const {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }
            
              if (index + sizeof(mem_t) > memory.size()) {
                  throw std::out_of_range("ReadWord: address out of range");
              }
            
              uint32_t value;
              memcpy(&value, memory.data() + index, sizeof(uint32_t));
              return value;
          }

          void write8(reg_t index, uint8_t value) {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }

              if (index + sizeof(mem_t) > memory.size()) {
                  memory.resize(index + sizeof(mem_t));
              }
            
              mem_t* ptr = memory.data() + index * sizeof(mem_t);
              memcpy(ptr, &value, sizeof(uint8_t));
          }

          void write16(reg_t index, uint16_t value) {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }

              if (index + sizeof(mem_t) > memory.size()) {
                  memory.resize(index + sizeof(uint16_t));
              }
            
              mem_t* ptr = memory.data() + index * sizeof(mem_t);
              memcpy(ptr, &value, sizeof(reg_t));
          }

          void write32(reg_t index, uint32_t value) {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }

              if (index + sizeof(mem_t) > memory.size()) {
                  memory.resize(index + sizeof(mem_t));
              }
            
              mem_t* ptr = memory.data() + index * sizeof(mem_t);
              memcpy(ptr, &value, sizeof(uint32_t));
          }

          void write64(reg_t index, reg_t value) {
              if (index % sizeof(command_t) != 0) {
                  throw std::runtime_error("ReadWord: misaligned access");
              }

              if (index + sizeof(mem_t) > memory.size()) {
                  memory.resize(index + sizeof(mem_t));
              }
            
              mem_t* ptr = memory.data() + index * sizeof(mem_t);
              memcpy(ptr, &value, sizeof(uint64_t));
          }
        };
      };

      CPP

      File.write("Simulation/includes/Memory.hpp")
    end
  end
end
