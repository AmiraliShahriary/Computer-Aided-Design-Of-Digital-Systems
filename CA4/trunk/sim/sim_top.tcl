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
# Pleas add other module here	
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/DataPath.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/FIFO_Bufffer.sv
    vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Linear_Buffer.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/FilterScratchPad.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/IFMapSratchPad.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/len_check.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/main_controller.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/MinThreshold.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/PipeLines.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/ReadAddressGeneratorFilter.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/ReadAddressGeneratorIF.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/ReadControllerFilter.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/ReadControllerIFMap.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/T_unit.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Top.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Utils.sv
	# vlog 	+acc -incr -source  +define+SIM 	$inc_path/implementation_option.vh
		
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
	