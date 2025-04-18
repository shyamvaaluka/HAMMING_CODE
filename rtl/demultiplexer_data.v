///////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : demultiplexer_data.v                                                             //
//  Version           : 0.2                                                                              //
//                                                                                                       //
//  parameters used   : DATA_WIDTH         : Width of the data                                           //
//                      SELECT_DATA_WIDTH1 : Nth bit of address from the top module                      //
//                      SELECT_DATA_WIDTH2 : N-1 bit of the address from the top module                  // 
//                                                                                                       //
//  Signals Used      : i_data              : Input data for routing.                                    //
//                      i_sel               : Select line to select one bank for the data to be routed.  //
//                      o_y0,o_y1,o_y2,o_y3 : Output channels that contains the data inputs.             //
//                                                                                                       // 
//                                                                                                       //
//  File Description  : This demultiplexer data module routes data to the corresponding bank based       //
//                      on the bank selected by the selection decoder module.                            //
//                                                                                                       //  
/////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module demultiplexer_data#( parameter DATA_WIDTH         = 8,
                            parameter SELECT_DATA_WIDTH1 = 2,
                            parameter SELECT_DATA_WIDTH2 = 1,
                            localparam PARITY_BITS       = $clog2(DATA_WIDTH)+1,
                            localparam ENCODED_WORD      = DATA_WIDTH + PARITY_BITS
                          )(  input      [ENCODED_WORD+1:1]                           i_data,             
                              input      [SELECT_DATA_WIDTH1-1:SELECT_DATA_WIDTH2-1]  i_sel,              
                              output reg [ENCODED_WORD+1:1]                           o_y0,o_y1,o_y2,o_y3 
                           );
  

  // This procedural block defines the logic of a demultiplexer that routes
  // the data to its corresponding output based on the given select input.
  // These output channels are connected to the data inputs of all the 4 banks
  // and is selected one at a time through which the data is routed to that
  // memory bank.
  always@(*)
  begin
    //This nested if statements will assign address to one of the outputs
    //based on the i_sel value.
    if(i_sel == 2'b00)
      //If i_sel is 2'b00 then input data is routed to 1st output.
      o_y0 = i_data;
    else if(i_sel == 2'b01)
      //If i_sel is 2'b01 then input data is routed to 2nd output.
      o_y1 = i_data;
    else if(i_sel == 2'b10)
      //If i_sel is 2'b10 then input data is routed to 3rd output.
      o_y2 = i_data;
    else
      //If i_sel is 2'b11 then input data is routed to 4th output.
      o_y3 = i_data; 
  end


endmodule

