///////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : error_injector.sv                                                            //
//  Version           : 0.2                                                                          //
//                                                                                                   //
//  parameters used   : DATA_WIDTH : Width of the hamming encoded data from port-a                       //
//                      DATA_B : Width of the hamming encoded data from port-b                       //
//                                                                                                   //
//  Signals Used      : i_data_a    : Input hamming_encoded word for port-a.                         //
//                      i_data_b    : Input hamming_encoded word for port-b.                         //
//                      i_temp_a    : Error input for port-a.                                        //
//                      i_temp_b    : Error input for port-b.                                        //
//                      o_err_out_a : Corrupted hamming_encoded output for port-a.                   //
//                      o_err_out_b : Corrupted hamming_encoded output for port-b.                   //                                                           
//                                                                                                   //                                                        
//  File Description  : This module injects one_bit error into the hamming_encoded word by doing     //
//                      bitwise XOR operation of the error bit mask with the hamming encoded data    //
//                      word that flips the data bits accordingly. Here we have used "o_dbit_err_x"  //
//                      (x = a or b which reperesents port-a or port-b) signal for ports A and B     //
//                      which is asserted when the error is a 2-bit error.                           //      
//                                                                                                   //  
/////////////////////////////////////////////////////////////////////////////////////////////////////// 

module err_inj#(parameter DATA_WIDTH = 16
               )(
                input      [DATA_WIDTH-1:0]  i_data_a,    
                input      [DATA_WIDTH-1:0]  i_data_b,    
                input      [DATA_WIDTH-1:0]  i_temp_a,    
                input      [DATA_WIDTH-1:0]  i_temp_b,    
                output reg [DATA_WIDTH-1:0]  o_err_out_a, 
                output reg [DATA_WIDTH-1:0]  o_err_out_b  
                );
  
  // This procedural block performs XOR opeartion of the hamming_encoded word,
  // with the bit mask error input that can be a one-bit, two-bit or no-bit
  // error.
  always@(*)
  begin
    o_err_out_a = i_data_a  ^  i_temp_a;
    o_err_out_b = i_data_b  ^  i_temp_b;	
  end
  
endmodule
