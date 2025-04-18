////////////////////////////////////////////////////////////////////////////////////
//  File name        : trans_pkg.sv                                               //
//                                                                                //
//                                                                                //
//  File Description : This file defines all the operations and ports for         //
//                     configuring the test bench to verify a certain port        // 
//                     with certain operation using enum integer constants.       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//This package class defines all the ports and operations that are randomized
//to configure the testbench for verifying write, read or none operation for
//a specific port.
package trans_pkg;
  //Userdefined enum datatype for randomizing between port-a and port-b.
	typedef enum{PORTA,PORTB}port;
  //Userdefined enum datatype for randomizing amongst write,read and none
  //operations.
	typedef enum{WRITE,READ,NONE}operation;
endpackage


