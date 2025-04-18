////////////////////////////////////////////////////////////////////////////////////
//  File name        : package.sv                                                 //
//                                                                                //
//                                                                                //
//  File Description : This package file includes all the test bench component    //
//                     files in the order of compilation and this package is      // 
//                     later imported in top module.                              //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//This package file defines all the test bench component files along with
//parameter package and configuration package in the order of compilation.
package pkg;
  //Importing parameter package.
  import pkg_2::*;
  //Importing configuration package.
	import trans_pkg::*;

  //Including all the test bench component files in the order of compilation
  //using `include directive.
	`include "dual_xtn.sv"
	`include "dual_generator.sv"
	`include "dual_driver_a.sv"
	`include "dual_driver_b.sv"
	`include "dual_monitor_a.sv"
	`include "dual_monitor_b.sv"
  `include "dual_refmodel.sv"
	`include "dual_scoreboard.sv"
	`include "dual_env.sv"
  `include "dual_test.sv"
endpackage
