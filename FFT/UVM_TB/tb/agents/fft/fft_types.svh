`ifndef FFT_TYPES_SVH
`define FFT_TYPES_SVH

    // Macro widths are defined in tb/interfaces/fft_interface.sv and compiled first.
    
    //Virtual interface type
    typedef virtual fft_interface fft_virtual_interface;
    typedef enum { SHOW_BOTH, SHOW_INPUT_ONLY, SHOW_OUTPUT_ONLY } fft_display_mode_e;


`endif