global env
# OPTIMIZE
 optimize .tiner_vlog.TIMER_tb.INTERFACE -target apa -effort quick -chip  -hierarchy auto
 optimize_timing .tiner_vlog.TIMER_tb.INTERFACE

 # WRITE DESIGN NETLIST
 auto_write -format edif "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/netlists/TIMER_tb.edf"

 # WRITE XDB FILE
 auto_write -format xdb "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/xdb/TIMER_tb.xdb"

 # WRITE REPORTS
 report_area -cell_usage > "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/reports/TIMER_tb_INTERFACE_sum.txt"
 report_delay -num_paths 1 -clock_frequency >> "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/reports/TIMER_tb_INTERFACE_sum.txt"
 file copy -force "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/reports/TIMER_tb_INTERFACE_sum.txt" "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/netlists/TIMER_tb_INTERFACE_sum"

 # Specify output file location (LS2000.1a2 and later)
 set output_file "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/netlists/TIMER_tb.edf"
