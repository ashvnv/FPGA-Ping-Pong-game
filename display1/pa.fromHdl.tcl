
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name display1 -dir "C:/Users/Ashwin/Downloads/TEMP/display1/planAhead_run_1" -part xc3s500efg320-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "pins.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {display1.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top display1 $srcset
add_files [list {pins.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s500efg320-4
