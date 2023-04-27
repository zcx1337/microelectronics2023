global env
# OPEN SOURCE FILES
read [list "$env(HDS_PROJECT_DIR)/TINER_Vlog/hdl/control_fsm.v" \
           "$env(HDS_PROJECT_DIR)/TINER_Vlog/hdl/DCDCounter.v" \
           "$env(HDS_PROJECT_DIR)/TINER_Vlog/hdl/counter_struct.v" \
           "$env(HDS_PROJECT_DIR)/TINER_Vlog/hdl/timer_struct.v"] -format verilog -work tiner_vlog -tech apa
present_design .tiner_vlog.TIMER.INTERFACE
