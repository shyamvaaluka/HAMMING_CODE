////////////////////////////////////////////////////////////////////////////////////
//  File name        : interface.sv                                               //
//                                                                                //
//                                                                                //
//  File Description : This is the interface file which acts as a bridge between  //
//                     the design and testbench signals. All of these signals     //
//                     are encapsulated in clocking blocks which are driven at    // 
//                     output skew which is after clocking event and sample at    //
//                     input skew which is before the next clocking event.        //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//Importing parameter package which consists of the values of data width,
//address width, write and read latencies.
import pkg_2::*;
//This is the interface module that consists of all the signals which are
//encapsulated within the clocking blocks that are driven at input or output
//skews based on the test bench component.
interface dual_iff(input bit clka,clkb);

	logic                  i_wea,i_web;       // Write enable signals for port-a and port-b.
  logic                  i_ena,i_enb;       // Enable signals for port-a and port-b.
	logic [DATA_WIDTH-1:0] i_dina;            // Data input for port-a.
	logic [DATA_WIDTH-1:0] i_dinb;            // Data input for port-b.
	logic [ADDR_WIDTH-1:0] i_addra;           // Address input for port-a.
	logic [ADDR_WIDTH-1:0] i_addrb;           // Address input for port-b.
	logic [DATA_WIDTH-1:0] o_douta;           // Output data of port-a.
	logic [DATA_WIDTH-1:0] o_doutb;           // Output data of port-b.
  logic                  o_errora,o_errorb; // Double_bit error indication for port-a and port-b.
	
  //Clocking block for port-a driver at positive edge triggering of the clock
  //signal. Here all the input signals of port-a are driven as output with
  //respect to test bench. And these signals are driven 1ns after the clocking
  //event.
	clocking drv_porta @(posedge clka);
	default input#1 output#1;
		output i_wea;
		output i_ena;
		output i_dina;
		output i_addra;
	endclocking

	//Clocking block for port-a monitor at positive edge triggering of clock
  //signal. Here all the input signals along with the output signals are given
  //with input direction with respect to test bench. Here all the data that is
  //proccessed by the DUT is captured by this interface.
  clocking mon_porta @(posedge clka);
	default input#1 output#1;
		input i_wea;
		input i_ena;
		input i_dina;
		input i_addra;
		input o_douta;
    input o_errora;
	endclocking

	//Clocking block for port-b driver at positive edge triggering of the clock
  //signal. Here all the input signals of port-b are driven as output with
  //respect to test bench. And these signals are driven 1ns after the clocking
  //event. 
  clocking drv_portb @(posedge clkb);
	default input#1 output#1;
		output i_web;
		output i_enb;
		output i_dinb;
		output i_addrb;
	endclocking

  //Clocking block for port-b monitor at positive edge triggering of clock
  //signal. Here all the input signals along with the output signals are given
  //with input direction with respect to test bench. Here all the data that is
  //proccessed by the DUT is captured by this interface.
  clocking mon_portb @(posedge clkb);
	default input#1 output#1;
		input i_web;
		input i_enb;
		input i_dinb;
		input i_addrb;
		input o_doutb;
    input o_errorb;
	endclocking

  //Here we have declared modport for port-a driver that defines the direction
  //of the signals associated with the port-a driver.
	modport DRV_PA(clocking drv_porta);
  //Here we have declared modport for port-a monitor that defines the direction
  //of the signals associated with the port-a monitor. 
	modport MON_PA(clocking mon_porta);
  //Here we have declared modport for port-b driver that defines the direction
  //of the signals associated with the port-b driver.
	modport DRV_PB(clocking drv_portb);
  //Here we have declared modport for port-b monitor that defines the direction
  //of the signals associated with the port-b monitor.
	modport MON_PB(clocking mon_portb);

endinterface
