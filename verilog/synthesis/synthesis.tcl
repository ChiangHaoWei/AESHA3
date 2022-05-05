set DIR "top_ungroup_15"
set DESIGN "Top"
sh mkdir $DIR

# Read Design
read_file -format verilog "../Top.v"
read_file -format verilog "../pbkdf2.v"
read_file -format verilog "../hmac.v"
read_file -format verilog "../ShiftBytes.v"
read_file -format verilog "../aes/AESOneRound_noloop.v"
read_file -format verilog "../aes/AddRoundKey.v"
read_file -format verilog "../aes/KeySchedule.v"
read_file -format verilog "../aes/AESTOP.v"
read_file -format verilog "../aes/MixColumn.v"
read_file -format verilog "../aes/ShiftRow.v"
read_file -format verilog "../aes/SubByte.v"
read_file -format verilog "../sha3/sha_top.v"
read_file -format verilog "../sha3/Ffunction.v"
read_file -format verilog "../sha3/Theta.v"
read_file -format verilog "../sha3/Chi.v"
read_file -format verilog "../sha3/Rho.v"
read_file -format verilog "../sha3/Pi.v"
read_file -format verilog "../sha3/Iota.v"
current_design $DESIGN
# uniquify
ungroup
link

source -echo -verbose ./synthesis.sdc

check_design
# remove_attribute [find -hierarchy design {"*"}] dont_touch

# Map and Optimize the Design
compile -exact_map -map_effort medium -area_effort high -power_effort none

# Analyze and debug the design
report_area > "$DIR"\area_$DESIGN\.out
report_power > "$DIR"\power_$DESIGN.out
report_timing -path full -delay max > "$DIR"\timing_$DESIGN\.out

# Output Design
remove_unconnected_ports -blast_buses [get_cells -hierarchical *]
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

#write -format db -hierarchy -output $active_design.db
write -format verilog -hierarchy -output "$DIR"\$DESIGN\_syn.v
write_sdf -version 2.1 -context verilog "$DIR"\$DESIGN\_syn.sdf
report_area
report_timing
