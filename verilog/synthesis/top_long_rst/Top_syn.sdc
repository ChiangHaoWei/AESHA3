###################################################################

# Created by write_sdc on Fri May 20 02:15:15 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_wire_load_model -name G200K -library fsa0m_a_generic_core_tt1p8v25c
set_max_fanout 6 [current_design]
set_max_area 0
set_load -pin_load 1 [get_ports {o_data[7]}]
set_load -pin_load 1 [get_ports {o_data[6]}]
set_load -pin_load 1 [get_ports {o_data[5]}]
set_load -pin_load 1 [get_ports {o_data[4]}]
set_load -pin_load 1 [get_ports {o_data[3]}]
set_load -pin_load 1 [get_ports {o_data[2]}]
set_load -pin_load 1 [get_ports {o_data[1]}]
set_load -pin_load 1 [get_ports {o_data[0]}]
set_load -pin_load 1 [get_ports o_valid]
set_load -pin_load 1 [get_ports o_ien]
create_clock [get_ports clk]  -period 400  -waveform {0 200}
set_clock_latency 0.5  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  -max 1  [get_ports clk]
set_input_delay -clock clk  -max 1  [get_ports rst_n]
set_input_delay -clock clk  -max 1  [get_ports {i_data[7]}]
set_input_delay -clock clk  -max 1  [get_ports {i_data[6]}]
set_input_delay -clock clk  -max 1  [get_ports {i_data[5]}]
set_input_delay -clock clk  -max 1  [get_ports {i_data[4]}]
set_input_delay -clock clk  -max 1  [get_ports {i_data[3]}]
set_input_delay -clock clk  -max 1  [get_ports {i_data[2]}]
set_input_delay -clock clk  -max 1  [get_ports {i_data[1]}]
set_input_delay -clock clk  -max 1  [get_ports {i_data[0]}]
set_input_delay -clock clk  -max 1  [get_ports i_mode]
set_input_delay -clock clk  -max 1  [get_ports i_start]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[7]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[6]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[5]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[4]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[3]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[2]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[1]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_data[0]}]
set_output_delay -clock clk  -min 0.5  [get_ports o_valid]
set_output_delay -clock clk  -min 0.5  [get_ports o_ien]
set_drive 1  [get_ports clk]
set_drive 1  [get_ports rst_n]
set_drive 1  [get_ports {i_data[7]}]
set_drive 1  [get_ports {i_data[6]}]
set_drive 1  [get_ports {i_data[5]}]
set_drive 1  [get_ports {i_data[4]}]
set_drive 1  [get_ports {i_data[3]}]
set_drive 1  [get_ports {i_data[2]}]
set_drive 1  [get_ports {i_data[1]}]
set_drive 1  [get_ports {i_data[0]}]
set_drive 1  [get_ports i_mode]
set_drive 1  [get_ports i_start]
