/////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : hamming_top.sv                                                             //
//  Version           : 0.2                                                                        //
//                                                                                                 //
//  parameters used   : DATA_WIDTH   : Width of the data                                           //
//                      DATA_BITS    : Number of data bits                                         //
//                      PARITY_BITS  : Number of parity bits injected in the encoded word          //
//                      ENCODED_WORD : Length of the encoded word                                  //  
//                                                                                                 //
//  Signals Used      : i_data_a           : Input data from port-a.                               //
//                      i_temp_a,i_temp_b  : Error inputs for port-a and port-b.                   //
//                      i_data_b           : Input data from port-b.                               //
//                      o_douta            : Output data for port-a.                               //
//                      o_doutb            : Output data for port-b.                               // 
//                                                                                                 //
//  File Description  : This is the top module of the error detection and correction logic that    //
//                      connects the error_injector, hamming_encoder and hamming_decoder modules.  //
//                      which inturn deals with the one-bit error detection and correction.        //  
//                                                                                                 //  
///////////////////////////////////////////////////////////////////////////////////////////////////// 

module hamming_encoder_top#(  parameter DATA_WIDTH    = 8,
	                            localparam DATA_BITS    = DATA_WIDTH,
                              localparam PARITY_BITS  = $clog2(DATA_BITS) + 1,
	                            localparam ENCODED_WORD = DATA_BITS + PARITY_BITS
                          )( input bit  [DATA_WIDTH-1:0]   i_data_a,                  
	                           input bit  [ENCODED_WORD+1:1] i_temp_a,i_temp_b,         
	                           input bit  [DATA_WIDTH-1:0]   i_data_b,                  
	                           output reg [ENCODED_WORD+1:1] o_douta,                   
	                           output reg [ENCODED_WORD+1:1] o_doutb                    
                           );

  wire [ENCODED_WORD+1:1] encoded_output_a,encoded_output_b; // Wires for port-a and port-b to transimit hamming encoded data to error injector.
	
  // The hamming encoder module performs the encoding of input data from
  // port-a and port-b and it is then sent to  the error injector.	
  ham_enc#( .DATA_WIDTH(DATA_WIDTH),
            .ENCODED_WORD(ENCODED_WORD))HAM_ENCODER( .i_data_in_a(i_data_a),
                                                     .i_data_in_b(i_data_b),
                                                     .o_hamming_a(encoded_output_a),
  	 				                                         .o_hamming_b(encoded_output_b));
  
  //The error injector recieves the hamming encoded word and injects error
  //into the data by doing bitwise XOR operation. This error input acts as
  //a bit mask.
  err_inj#( .DATA_WIDTH(ENCODED_WORD+1))ERROR_INJECTOR( .i_data_a(encoded_output_a),
                                                        .i_data_b(encoded_output_b),
                                                        .i_temp_a(i_temp_a),
                                                        .i_temp_b(i_temp_b),
  					                                            .o_err_out_a(o_douta),
                                                        .o_err_out_b(o_doutb));
  	
  endmodule
