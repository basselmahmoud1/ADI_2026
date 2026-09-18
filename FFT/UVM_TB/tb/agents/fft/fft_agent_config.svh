`ifndef FFT_AGENT_CONFIG_SVH
`define FFT_AGENT_CONFIG_SVH

    class fft_agent_config extends uvm_component; // it can be be uvm_object 
        `uvm_component_utils(fft_agent_config);

        // making virutal interface as local variable which would be accessed only using getter and setters 
        local fft_virtual_interface fft_vif;

        local uvm_active_passive_enum active_passive;

        function new(string name = "fft_agent_config" , uvm_component parent = null);
            super.new(name,parent);
            active_passive = UVM_ACTIVE;
        endfunction

        virtual function void set_active_passive(uvm_active_passive_enum value);
            this.active_passive = value;
        endfunction

        virtual function uvm_active_passive_enum get_active_passive();
            return active_passive;
        endfunction



        virtual function void set_vif (fft_virtual_interface value);
            // making algorithim that make only one set of the interface
            if (fft_vif == null) begin
                fft_vif = value ;
            end
            else begin
                `uvm_fatal("ALGO_ISSUE","trying to set the FFT virtual interface more than once");
            end
        endfunction
        virtual function void get_vif (ref fft_virtual_interface value);
            // making algorithim that make only one set of the interface
            if (fft_vif == null) begin
                `uvm_fatal("ALGO_ISSUE","trying to get the FFT virtual interface which is not set");
            end
            else begin
                value = fft_vif ; 
            end
        endfunction
        
        // checking that the virtual interface is the set before the start of the run phase

        virtual function void start_of_simulation_phase(uvm_phase phase);   
            fft_virtual_interface value ; 

            super.start_of_simulation_phase(phase);
            
            get_vif(value);
            if(value != null)
                `uvm_info("FFT_VIF_CONFIG","Virtual interface is configured at \"start of the simulation\"", UVM_LOW);
        endfunction
                       
        

    endclass 
`endif