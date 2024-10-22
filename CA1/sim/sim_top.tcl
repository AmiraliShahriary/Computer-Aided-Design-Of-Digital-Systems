alias clc ".main clear"
	
clc
exec vlib work
vmap work work
	
set TB					"TB"
set hdl_path			"../src/hdl"
set inc_path			"../src/inc"
	
set run_time			"1 us"
#	set run_time			"-all"

#============================ Add verilog files  ===============================
# Adding the relevant modules based on the components seen in the image
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/adder.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Commprator.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Controller.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Counter.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Datapath.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Multiplier.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Ram.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Ram_output.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Real_TopModule.sv
vlog 	+acc -incr -source  +define+SIM 	$hdl_path/ShiftRegister.sv

	
	
		
vlog 	+acc -incr -source  +incdir+$inc_path +define+SIM 	./tb/$TB.sv
onerror {break}

#================================ simulation ====================================

vsim	-voptargs=+acc -debugDB $TB


#======================= adding signals to wave window ==========================

add wave -hex -group 	 	{TB}				sim:/$TB/*
add wave -hex -group 	 	{top}				sim:/$TB/uut/*	
add wave -hex -group -r		{all}				sim:/$TB/*

#=========================== Configure wave signals =============================

configure wave -signalnamewidth 2
    

#====================================== run =====================================

run $run_time
