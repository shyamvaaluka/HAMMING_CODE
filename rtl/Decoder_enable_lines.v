///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name        : Decoder_enable_lines.v                                                                    //
//  Version          : 0.2                                                                                       //
//                                                                                                               //
//  parameters used  : SELECT_ADDR1 : Value of the Nth bit of the address from the top module                    //
//                     SELECT_ADDR2 : Value of N-1 bit of the address from the top module                        // 
//                                                                                                               //
//  Signals Used     : i_I : Top two bits of the input address for bank selection.                               //
//                     o_y : One hot encoded output which asserts the enable signals of the bank one at a time.  //
//                                                                                                               //
//  File Description : This is a 2x4 selection decoder module that selects a certain bank at a time              //
//                     based on the first two bits of the input address given from the top module.               //
//                                                                                                               //  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module decoder_enable_lines#( parameter SELECT_ADDR1 = 6,
                              parameter SELECT_ADDR2 = 5
                            )(  input      [SELECT_ADDR1-1:SELECT_ADDR2-1] i_I, 
                                output reg [3:0]                           o_y  
                             );
  
  //This procedural block defines the logic of a 2x4 decoder where the one-hot
  //encoded output selects one bank at a time by asserting the enable signals
  //of the corresponding bank based on the select input given by top two bits
  //of the input address from the top module.
  always@(*)
  begin
    //Nested if statements assigns the output with a one-hot encoded input based on
    //the i_I value.
    if(i_I == 2'b00)
      //If i_I is 2'b00 then the first bank is enabled.
      o_y = 4'b1000;
    else if(i_I == 2'b01)
      //If i_I is 2'b01 then the second bank is enabled.
      o_y = 4'b0100;
    else if(i_I == 2'b10)
      //If i_I is 2'b10 then the third bank is enabled.
      o_y = 4'b0010;
    else
      //If i_I is 2'b11 then the fourth bank is enabled.
      o_y = 4'b0001;
  end


endmodule
