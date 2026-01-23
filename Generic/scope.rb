require_relative "base"
require_relative "var"

module SimInfra
    class Scope

        include GlobalCounter # used for temp variables IDs
        attr_reader :tree, :vars, :parent
        def initialize(parent); @tree = []; @vars = {}; end
        # resolve allows to convert Ruby Integer constants to Constant instance

        def var(name, type)
            @vars[name] = SimInfra::Var.new(self, name, type) # return var
            instance_eval "def #{name.to_s}(); return @vars[:#{name.to_s}]; end"
            stmt :new_var, [@vars[name]] # returns @vars[name]
        end

        def sext(value, width)
          value = resolve_const(value)
          tmp = tmpvar(:i32)
          stmt(:sext, [tmp, value, width])
        end

        def add_var(name, type); var(name, type); self; end

        def resolve_const(what)
            return what if (what.class== Var) or (what.class== Constant) # or other known classes
            return Constant.new(self, "const_#{next_counter}", what) if (what.class== Integer)
        end

        def binOp(a, b, op);
            a = resolve_const(a); b = resolve_const(b)
            # TODO: check constant size <= bitsize(var)
            # assert(a.type== b.type|| a.type == :iconst || b.type== :iconst)

            stmt op, [tmpvar(a.type), a, b]
        end

        def unOp(a, op)
            a = resolve_const(a)
            dst = tmpvar(:i32)
            stmt(op, [dst, a])
        end

        def set_pc(addr)
            stmt(:set_pc, [resolve_const(addr)])
        end
        
        def get_pc
            dst = tmpvar(:i32)
            stmt(:get_pc, [dst])
            dst
        end
        
        # redefine! add & sub will never be the same
        def add(a, b); binOp(a, b, :add); end
        def sub(a, b); binOp(a, b, :sub); end
        def shl(a, b); binOp(a, b, :shl); end
        def lt_s(a, b); binOp(a, b, :lt_s); end
        def lt_u(a, b); binOp(a, b, :lt_u); end
        def xor(a, b); binOp(a, b, :xor); end
        def or(a, b); binOp(a, b, :or); end
        def and(a, b); binOp(a, b, :and); end
        def shr_u(a, b); binOp(a, b, :shr_u); end
        def shr_s(a, b); binOp(a, b, :shr_s); end
        def read_csr(a, b); binOp(a, b, :read_csr); end
        def write_csr(a, b); binOp(a, b, :write_csr); end

        def load_byte(addr); unOp(addr, :load_byte); end
        def load_halfword(addr); unOp(addr, :load_halfword); end
        def load_word(addr); unOp(addr, :load_word); end
        def not(src); unOp(src, :not); end

        def store_byte(addr, data); binOp(addr, data, :store_byte); end
        def store_halfword(addr, data); binOp(addr, data, :store_halfword); end
        def store_word(addr, data); binOp(addr, data, :store_word); end

        def branch_eq(rs1, rs2, offset); stmt(:branch_eq, [rs1, rs2, offset]); end
        def branch_ne(rs1, rs2, offset); stmt(:branch_ne, [rs1, rs2, offset]); end
        def branch_lt(rs1, rs2, offset); stmt(:branch_lt, [rs1, rs2, offset]); end
        def branch_ge(rs1, rs2, offset); stmt(:branch_ge, [rs1, rs2, offset]); end
        def branch_ltu(rs1, rs2, offset); stmt(:branch_ltu, [rs1, rs2, offset]); end
        def branch_geu(rs1, rs2, offset); stmt(:branch_geu, [rs1, rs2, offset]); end

        private def tmpvar(type); var("_tmp#{next_counter}".to_sym, type); end
        # stmtadds statement into tree and retursoperand[0]
        # which result in near all cases
        def stmt(name, operands, attrs= nil);
            @tree << IrStmt.new(name, operands, attrs); operands[0]
        end
    end
end
