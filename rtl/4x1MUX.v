////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name        : 4x1MUX.v                                                                                   //
//  Version          : 0.2                                                                                        //
//                                                                                                                //
//  parameters used  : DATA_WIDTH : Width of the data being routed.                                               //
//                     ADDR_1     : Value of the Nth bit of the top module address.                               //
//                     ADDR_2     : Value of N-1 bit of the top module address.                                   //        
//                                                                                                                //
//  Signals used     : i_i0,i_i1,i_i2,i_i3 : Data inputs to be routed onto single channel output.                 //
//                     i_sel               : Select line that selects one of 4 inputs to be routed.               //                                                                                               
//                     o_Y                 : Output channel where the data is transmitted to the single channel.  //   
//                                                                                                                //
//  File Description : This multiplexer module routes all the output data from each bank(4 banks in               //
//                     total) onto one single output channel. This is a latched mux where the                     //
//                     select lines control the data routing based on read latency parameter.                     //  
//                                                                                                                //  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module MUX_4x1#(  parameter DATA_WIDTH    = 8,
                	parameter ADDR_1        = 5,
	                parameter ADDR_2        = 4,
                  localparam PARITY_BITS  = $clog2(DATA_WIDTH)+1,
                  localparam ENCODED_WORD = DATA_WIDTH + PARITY_BITS
               )( input      [ENCODED_WORD+1:1]  i_i0,i_i1,i_i2,i_i3, 
                	input      [ADDR_1-1:ADDR_2-1] i_sel,               
	                output reg [ENCODED_WORD+1:1]  o_Y                  
                );
  
  // This procedural block routes one of the 4 data inputs to the single
  // channel output based on the value of the 2-bit select line input.
	always@(*)
	begin
    //Here if i_sel is 2'b00 then o_Y is assigned with 1st input.
    if(i_sel == 2'b00)
      o_Y = i_i0;
    //Here if i_sel is 2'b01 then o_Y is assigned with 2nd input.  
    else if(i_sel == 2'b01)
      o_Y = i_i1;
    //Here if i_sel is 2'b10 then o_Y is assigned with 3rd input.  
    else if(i_sel == 2'b10)
      o_Y = i_i2;
    //Here if i_sel is 2'b11 then o_Y is assigned with 4th input.  
    else
      o_Y = i_i3;
	end

endmodule
