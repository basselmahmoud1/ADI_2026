package spi_types;

    typedef enum logic[1:0] {IDLE , RW_STATE ,BURST } states_e;

    typedef enum logic {WRITE , READ} rw_e;

    typedef struct packed {
        rw_e rw;
        logic [14:0] addr;
    } spi_header_str;
endpackage