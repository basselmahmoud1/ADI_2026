`ifndef FFT_MONITOR_SVH
`define FFT_MONITOR_SVH

class fft_monitor extends uvm_monitor;
    `uvm_component_utils(fft_monitor);

    fft_agent_config agent_config;
    virtual fft_interface vif;

    fft_seq_item seq_item ;

    uvm_analysis_port #(fft_seq_item) mon_ap;

    function new(string name = "fft_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon_ap = new ("mon_ap",this);

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        if (agent_config == null) begin
            `uvm_fatal("FFT_MON_CFG", "agent_config is null in fft_monitor");
        end
        agent_config.get_vif(vif);

        if (vif == null) begin
            `uvm_fatal("FFT_MON_VIF", "virtual interface is not set in fft_monitor");
        end

        forever begin
            seq_item = fft_seq_item::type_id::create("seq_item");
            monitor_task(seq_item);
            if (seq_item.valid_in || seq_item.valid_out || !seq_item.rstn) begin
                seq_item.display_mode = SHOW_BOTH;
                `uvm_info("Monitor transaction",seq_item.convert2string(),UVM_MEDIUM);

                mon_ap.write(seq_item);
            end
        end
    endtask

    task monitor_task (ref fft_seq_item seq_item_mon);
        @(vif.fft_cb_mon);
        
        seq_item_mon.rstn =  vif.fft_cb_mon.rstn;
        seq_item_mon.valid_in =  vif.fft_cb_mon.valid_in;
        seq_item_mon.DIN =  vif.fft_cb_mon.DIN;
        // outputs 
        seq_item_mon.DOUT =  vif.fft_cb_mon.DOUT;
        seq_item_mon.valid_out =  vif.fft_cb_mon.valid_out;
    endtask
endclass

`endif
