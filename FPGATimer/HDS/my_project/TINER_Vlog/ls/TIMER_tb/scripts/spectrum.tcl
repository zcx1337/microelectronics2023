global env
# SET WORKING DIR
set_working_dir "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/netlists"

# SETUP
source "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/scripts/setup.tcl"

# READ IN SOURCE FILES
source "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/scripts/open_files.tcl"

# OPTIMIZE
source "$env(HDS_PROJECT_DIR)/TINER_Vlog/ls/TIMER_tb/scripts/optimize.tcl"

puts "Info: HDS Synthesis run finished"
