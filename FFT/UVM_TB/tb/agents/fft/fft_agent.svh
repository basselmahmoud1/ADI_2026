`ifndef FFT_AGENT_SVH
`define FFT_AGENT_SVH

    class fft_agent extends uvm_agent;
        `uvm_component_utils(fft_agent);

        fft_agent_config agent_config; 
        // agent virtual interface
        fft_virtual_interface fft_vif;
        // agent driver
        fft_driver fft_drv;
        fft_monitor fft_mon;
        
        fft_sequencer fft_seqr;

        uvm_analysis_port#(fft_seq_item) agent_ap;

        function new(string name = "fft_agent" , uvm_component parent = null);
            super.new(name,parent);
        endfunction 

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent_config = fft_agent_config::type_id::create("agent_config",this);
            agent_ap = new("agent_ap",this);
            fft_mon = fft_monitor::type_id::create("fft_mon",this);
            if(agent_config.get_active_passive() == UVM_ACTIVE)begin
                fft_drv = fft_driver::type_id::create("fft_drv",this);
                fft_seqr = fft_sequencer::type_id::create("fft_seqr",this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            // get the interface form the config_db which is put by the Top.sv
            if(!uvm_config_db#(fft_virtual_interface)::get(this,"","fft_vif",fft_vif))begin
                `uvm_fatal("FFT_NO_VIF","couldn't get from the data base the FFT virtual interface using key \"fft_vif\"");
            end
            else begin
                // put the intrface in the FFT_config for other component to use it !!
                agent_config.set_vif(fft_vif);
            end
            fft_mon.agent_config = agent_config;
                        
            fft_mon.mon_ap.connect(this.agent_ap);
            if(agent_config.get_active_passive() == UVM_ACTIVE)begin
                fft_drv.agent_config = agent_config;
                fft_drv.seq_item_port.connect(fft_seqr.seq_item_export);
            end
        endfunction
        

    endclass 
`endif