package ALU_pkg;
typedef enum logic [1:0] {
    ALU_ADD = 2'b00,
    ALU_SUB = 2'b01,
    ALU_AND = 2'b10,
    ALU_OR  = 2'b11
} alu_opcode_t;

endpackage