`ifndef FFT_DRIVER_SVH
`define FFT_DRIVER_SVH

    class fft_driver extends uvm_driver #(.REQ(fft_seq_item));
        `uvm_component_utils(fft_driver);

        fft_agent_config agent_config;
        virtual fft_interface vif;

        function new (string name = "fft_driver" , uvm_component parent = null);
            super.new(name,parent);
        endfunction
        
        virtual task run_phase(uvm_phase phase);
            super.run_phase(phase);

            if (agent_config == null) begin
                `uvm_fatal("FFT_DRV_CFG", "agent_config is null in fft_driver")
            end
            agent_config.get_vif(vif);

            forever begin
                fft_seq_item seq_item ; // this seq_item is created in the sequence 
                seq_item_port.try_next_item(seq_item);
                if (seq_item != null) begin
                    driving_task(seq_item);
                    seq_item_port.item_done();
                end else begin
                    @(vif.fft_cb_drv);
                    vif.fft_cb_drv.valid_in <= 1'b0;
                end
            end            
        endtask

        task driving_task (fft_seq_item seq_item_drv);
            if (vif == null) begin
                `uvm_fatal("FFT_DRV_VIF", "virtual interface is not set in fft_driver");
            end
            @(vif.fft_cb_drv);

            vif.fft_cb_drv.valid_in <= seq_item_drv.valid_in;
            vif.fft_cb_drv.rstn <= seq_item_drv.rstn;
            vif.fft_cb_drv.DIN <= seq_item_drv.DIN;

        endtask

    endclass

`endif