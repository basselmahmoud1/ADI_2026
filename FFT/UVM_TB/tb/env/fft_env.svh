`ifndef FFT_ENV_SVH
`define FFT_ENV_SVH

class fft_env extends uvm_env;
    `uvm_component_utils(fft_env)

    fft_agent agent;
    fft_scoreboard sb;
    fft_subscriber cov;

    function new(string name = "fft_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = fft_agent::type_id::create("agent", this);
        sb = fft_scoreboard::type_id::create("sb", this);
        cov = fft_subscriber::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.agent_ap.connect(sb.agent_imp);
        agent.agent_ap.connect(cov.analysis_export);
    endfunction

endclass

`endif