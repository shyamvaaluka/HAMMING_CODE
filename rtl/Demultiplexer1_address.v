/////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name        : Demultiplexer1_address.v                                                        //
//  Version          : 0.2                                                                             //
//                                                                                                     // 
//  parameters used  : ADDR_WIDTH    : N-2 bit of the address from the top module                      //
//                     SELECT_WIDTH1 : Nth bit of the address from the top module                      //
//                     SELECT_WIDTH2 : N-1 bit of the address from the top module                      // 
//                                                                                                     //
//  Signals Used     : i_address           : Input bank address.                                       //
//                     i_sel               : Input select line.                                        //
//                     o_y0,o_y1,o_y2,o_y3 : Outputs to route the address to its corresponding bank.   //
//                                                                                                     //
//                                                                                                     // 
//  File Description : This demultiplexer module converts the input address of the top module to       //
//                     its corresponding memory bank address which is in the range of that bank        //
//                     depth.                                                                          //  
//                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////// 

module demultiplexer1_address #(
    parameter ADDR_WIDTH    = 4,
    parameter SELECT_WIDTH1 = 2,
    parameter SELECT_WIDTH2 = 1
) (
    input      [                 ADDR_WIDTH-3:0] i_address,
    input      [SELECT_WIDTH1-1:SELECT_WIDTH2-1] i_sel,
    output reg [                 ADDR_WIDTH-3:0] o_y0,
    o_y1,
    o_y2,
    o_y3
);

  // This procedural block deals with address decoding logic where the top two
  // bits of the input address from the top module is used to select a bank and the 
  // remaining bits of the input address from the top module are given as input address 
  // to its corresponding bank. 
  always @(*) begin
    //This nested if statements will assign address to one of the outputs
    //based on the i_sel value.
    if (i_sel == 2'b00)
      //If i_sel is 2'b00 then input address is routed to 1st output.
      o_y0 = i_address;
    else if (i_sel == 2'b01)
      //If i_sel is 2'b01 then input address is routed to 2nd output.
      o_y1 = i_address;
    else if (i_sel == 2'b10)
      //If i_sel is 2'b10 then input address is routed to 3rd output.
      o_y2 = i_address;
    else
      //If i_sel is 2'b11 then input address is routed to 4th output.
      o_y3 = i_address;
  end


endmodule
