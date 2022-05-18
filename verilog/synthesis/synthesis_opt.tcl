#set DIR "top_ungroup_15"
set DESIGN "Top"
#sh mkdir $DIR

# Read Design
read_file -format verilog "../Top_ungroup.v"
#read_file -format verilog "../Top.v"
#read_file -format verilog "../pbkdf2.v"
#read_file -format verilog "../hmac.v"
read_file -format verilog "../ShiftBytes.v"
read_file -format verilog "../aes/AESFull.v"
#read_file -format verilog "../sha3/sha_top.v"
read_file -format verilog "../sha3/Ffunction.v"
read_file -format verilog "../sha3/Theta.v"
read_file -format verilog "../sha3/Chi.v"
read_file -format verilog "../sha3/Rho.v"
read_file -format verilog "../sha3/Pi.v"
read_file -format verilog "../sha3/Iota.v"
current_design $DESIGN
# uniquify
ungroup -all
link

source -echo -verbose ./synthesis.sdc

check_design
# remove_attribute [find -hierarchy design {"*"}] dont_touch

# Map and Optimize the Design
#compile -exact_map -map_effort high -area_effort high -power_effort none
compile_ultra -retime
# Analyze and debug the design
report_area > area_$DESIGN\.out
report_power > power_$DESIGN.out
report_timing -path full -delay max > timing_$DESIGN\.out

# Output Design
#remove_unconnected_ports -blast_buses [get_cells -hierarchical *]
#set bus_inference_style {%s[%d]}
#set bus_naming_style {%s[%d]}
#set hdlout_internalwri_busses true
#change_names -hierarchy -rule verilog
#define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
#define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
#define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
#define_name_rules name_rule -case_insensitive
#change_names -hierarchy -rules name_rule

#write -format db -hierarchy -output $active_design.db
write -format ddc -hierarchy -output $DESIGN\_syn.ddc
write -format verilog -hierarchy -output $DESIGN\_syn.v
write_sdf -version 2.1 -context verilog $DESIGN\_syn.sdf
report_area
report_timing
