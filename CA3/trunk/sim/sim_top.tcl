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
# Please add other module files here
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Adder.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/And.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Controller.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/counter.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Cout.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/datapath.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/FA.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Inverter.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/modules.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/multiplier.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/multiplier_8x8.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/mux.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Nand.v	
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Nor.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Not.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/OneBitRegister.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/Register.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/ShiftRegister.v
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/TopModule.v	
	vlog 	+acc -incr -source +define+SIM 	$hdl_path/XOR.v	

	vlog 	+acc -incr -source +incdir+$inc_path +define+SIM 	./tb/$TB.v
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
