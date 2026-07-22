package AHB_pkg;
    // FSM STATES & HTRANS
    typedef enum logic [1:0] {IDLE = 2'b00 , BUSY = 2'b01 , NONSEQ = 2'b10 , SEQ = 2'b11 } trans_types_e;
    // BURST STATES & HRBUST
    typedef enum logic [2:0] {  
        SINGLE  = 3'b000 , 
        INCR    = 3'b001 , 
        WRAP4   = 3'b010 , 
        INCR4   = 3'b011 , 
        WRAP8   = 3'b100 , 
        INCR8   = 3'b101 , 
        WRAP16 = 3'b110 , 
        INCR16  = 3'b111 
    } burst_e;
    // HSIZE 
    typedef enum logic [2:0] {  
        BYTE        = 3'b000 , 
        HALFWORD    = 3'b001 , 
        WORD        = 3'b010 , 
        DOUBLEWORD  = 3'b011 , 
        WORD_4      = 3'b100 , 
        WORD_8      = 3'b101 , 
        BITS_512    = 3'b110 , 
        BITS_1024   = 3'b111 
    } size_e;
    //grey encoded
    typedef enum logic [1:0] {NO_BURST = 2'b00 , CONT_BURST = 2'b01 , LAST_BURST = 2'b11 , START_BURST = 2'b10} counter_states_e;
endpackage