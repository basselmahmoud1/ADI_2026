typedef enum { NORMAL, CORNER, OVERFLOW, ZERO_RESULT } constraint_mode_t;

class class_based_transaction;
    rand constraint_mode_t c_mode;
    rand logic signed [3:0] a;
    rand logic signed [3:0] b;
    rand alu_opcode_t op_code;
    rand bit rst;

    logic signed [3:0] result;
    logic z;
    logic n;
    logic c;
    logic v;

    constraint c_c_mode {
        c_mode dist {
            NORMAL := 70,
            CORNER := 10,
            OVERFLOW := 10,
            ZERO_RESULT := 10
        };
    }

    constraint c_rst {
        rst dist {0 := 90, 1 := 10};
    }

    constraint c_opcode_weighted {
        op_code dist {
            ALU_ADD := 40,
            ALU_SUB := 40,
            ALU_AND := 30,
            ALU_OR  := 30
        };
    }

    constraint c_corner {
        (c_mode == CORNER) -> {
            a inside {0, 1, -1, 7, -8, 6, -7};
            b inside {0, 1, -1, 7, -8, 6, -7};
        }
    }

    constraint c_overflow {
        (c_mode == OVERFLOW) -> {
            if (op_code == ALU_ADD) {
                (a > 0 && b > 0 && (a + b > 7)) || (a < 0 && b < 0 && (a + b < -8));
            } else if (op_code == ALU_SUB) {
                (a > 0 && b < 0 && (a - b > 7)) || (a < 0 && b > 0 && (a - b < -8));
            }
        }
    }

    constraint c_zero_result {
        (c_mode == ZERO_RESULT) -> {
            if (op_code == ALU_ADD) {
                a == -b;
            } else if (op_code == ALU_SUB) {
                a == b;
            } else if (op_code == ALU_AND) {
                (a & b) == 0;
            } else if (op_code == ALU_OR) {
                (a | b) == 0;
            }
        }
    }

    function class_based_transaction clone();
        class_based_transaction t;
        t = new();
        t.c_mode = this.c_mode;
        t.a = this.a;
        t.b = this.b;
        t.op_code = this.op_code;
        t.rst = this.rst;
        t.result = this.result;
        t.z = this.z;
        t.n = this.n;
        t.c = this.c;
        t.v = this.v;
        return t;
    endfunction

    function void display(string prefix = "");
        $display("%s t=%0t | rst=%0b | a=%0d b=%0d op=%0d | result=%0d z=%0b n=%0b c=%0b v=%0b",
                 prefix, $time, rst, a, b, op_code, result, z, n, c, v);
    endfunction
endclass