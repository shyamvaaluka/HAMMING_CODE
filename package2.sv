////////////////////////////////////////////////////////////////////////////////////
//  File name        : package2.sv                                                //
//                                                                                //
//                                                                                //
//  File Description : This package file consists of all the parameters that are  //
//                     required for varying widths of data, address and depth of  //
//                     the memory and also to adjust write and read latency       // 
//                     values for port-a and port-b.                              //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//This package consists of all the parameters like data_width, address_width,
//write and rea latencies for port-a and port-b along with memory depth and
//width.
package pkg_2;
  //Defines width of the data.
  parameter DATA_WIDTH  = 4;
  //Defines depth of the memory.
  parameter	MEM_DEPTH   = 32;
  //Defines width of the input address.
  parameter	ADDR_WIDTH  = $clog2(MEM_DEPTH);
  //Defines width of the memory location.
  parameter	MEM_WIDTH   = 2*ADDR_WIDTH;
  //Defines write latency for port-a.
  parameter WR_LATENCYA = 10;
  //Defines read latency for port-a.
  parameter RD_LATENCYA = 5;
  //Defines write latency for port-b.
  parameter WR_LATENCYB = 7;
  //Defines read latency for port-b.
  parameter RD_LATENCYB = 8;

endpackage
