///////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : hamming_dec.sv                                                               //
//  Version           : 0.2                                                                          //
//                                                                                                   //
//  parameters used   : DATA_WIDTH        : Width of the corrupted hamming encoded word              //
//                      NO_OF_PARITY_BITS : Number of parity bits injected in the encoded word       //  
//                                                                                                   //
//  Signals Used      : i_data_a      : Input corrupted hamming encoded word port-a.                 //
//                      i_data_b      : Input corrupted hamming encoded word port-b.                 //
//                      o_dbit_err_a  : double_bit error flag for port-a.                            //
//                      o_dbit_err_b  : double_bit error flag for port-b.                            //
//                      o_dout_a      : Corrected data output for port-a.                            //
//                      o_dout_b      : Corrected data output for port-b.                            // 
//                                                                                                   //
//  File Description  : This is a hamming decoder module that takes the corrupted hamming encoded    //
//                      word as input and does error correction using syndrome bit calculation       //
//                      algorithm. Here the reciever also uses even parity calculation.              //
//                                                                                                   //
//                      Note: hamming_decoder can correct only one-bit errors.                       //
//                                                                                                   //  
/////////////////////////////////////////////////////////////////////////////////////////////////////// 

module ham_dec#(parameter DATA_WIDTH         = 7,
                localparam NO_OF_PARITY_BITS = $clog2(DATA_WIDTH)

               )( input       [DATA_WIDTH:1]                           i_data_a,     
                  input       [DATA_WIDTH:1]                           i_data_b,     
                  output reg                                           o_dbit_err_a, 
                  output reg                                           o_dbit_err_b, 
                  output reg  [DATA_WIDTH - 1 - NO_OF_PARITY_BITS : 1] o_dout_a,     
                  output reg  [DATA_WIDTH - 1 - NO_OF_PARITY_BITS : 1] o_dout_b      
                );

  reg [DATA_WIDTH:1] temp_a , temp_b;           // Internal variables to store the updated parity values for port-a and port-b.
  reg [DATA_WIDTH:1] temp_a_final,temp_b_final; // Internal variables to store the corrected output after syndrome calculation
  int temp  = 0;                                // Internal variable to perform parity calculation for port-a.
  int temp1 = 0;                                // Internal variable to perform parity calculation for port-b.
  int o = 1;                                    // Internal variable to traverse through the non-powers of 2 indexes of the corrected word in port-a.
  int u = 1;                                    // Internal variable to traverse through the non-powers of 2 indexes of the corrected word in port-b.
  int syndrome_a = 0;                           // Internal variable to store syndrome value for port-a.
  int syndrome_b = 0;                           // Internal variable to store syndrome value for port-b.
  reg c_parity_a,c_parity_b;                    // Internal variable to calculate overall parity for double error detection. 
  
  //This procedural block performs the error correction and detection part of
  //the given hamming encoded word. This block identifies which data has 2-bit
  //errors.
  always@(*)
  begin
    //Initializing the internal variable temp_a with input data for parity
    //calculation.
  	temp_a       = i_data_a;
    //Initializing the internal variable temp_a_final with input data for
    //error correction using syndrome value.
  	temp_a_final = i_data_a;
    //Calculating overall parity of the recieved hamming encoded word from
    //port-a.
    c_parity_a   = ^i_data_a;

    //The external for loop traverses through the powers of 2 indexes and the
    //internal for loop calculates the parity of the data bits that are
    //covered by that parity bit at that power of 2 position.
  	for(int i = DATA_WIDTH-1 ; i >= 1 ; i = i - 1)
  	begin
      if((i & (i - 1)) == 0)
  		begin
  			for(int k = i + 1 ; k <= DATA_WIDTH-1 ; k = k + 1)
  			begin
  				if((i & k) != 0)
  				begin
  					temp = temp ^ i_data_a[k];
  				end
  				else
  					temp_a[k] = temp_a[k];
  			end
  			if(temp == i_data_a[i])
  				temp_a[i] = 0;
  			else
  				temp_a[i] = 1;
  						
  		end
  		else
  		begin
        i = i;
  		end
      //Resetting temp to 0 so that it does not continue its next transaction
      //parity calculation from its previous transaction parity value. Due to this
      //the toogle coverage will not be hit hence we excluded toggle coverage
      //for temp. 
  		temp = 0;
  	end
    //This for loop calcuates the syndrome value for port-a by traversing
    //thorugh the powers of 2 indexes and multiplying with their binary
    //weights, which converts the combined parity into decimal numnber that
    //determines the position of the error bit.
  	for(int k = 1 ; k <= DATA_WIDTH-1 ; k = k + 1)
  	begin
      if((k & (k - 1)) == 0)
  		begin
  			syndrome_a = syndrome_a + ((k) * (temp_a[k]));
  		end
  
  		else
  			temp_a[k] = temp_a[k];			
  	end
    //This if-else block determines the position of the error bit and toggles
    //the bit which inturn corrects the bit at that position.
  	if(syndrome_a != 0)
  		temp_a_final[syndrome_a] = ~temp_a_final[syndrome_a];
  	else
  		temp_a_final[syndrome_a] = temp_a_final[syndrome_a];

    //This if-else block determines the double-bit error by looking at the
    //overall parity bit and syndrome value which has to be non-zero. 
    if(syndrome_a != 0 && c_parity_a == 0)
      o_dbit_err_a = 1;
    else
      o_dbit_err_a = 0;
    
    //Resetting syndrome_a to zero as for next transaction the calculation of
    //syndrome might not be correct because the previous trannsaction syndrome
    //value is still retained. Hence we reset to 0 for every transaction. This
    //causes the toggle coverage to not hit, hence we excluded toggle coverage
    //for syndrome_a.
  	syndrome_a = 0;
    
    //This for loop extracts all the data bits from the corrected hamming
    //decoded word and assigns them to the output of the module.
  	for(int y = 1 ; y <= DATA_WIDTH-1 ; y = y + 1)
  	begin
      if((y & (y - 1)) != 0)
  		begin
  			o_dout_a[o] = temp_a_final[y];
  			o = o + 1;
  		end
  		else
  			o_dout_a[o] = o_dout_a[o];
    end
    //Resetting o to 1 so that it does not continue its next transaction
    //data bit extraction from its previous transaction index value. Due to this
    //the toogle coverage will not be hit hence we excluded toggle coverage
    //for o. 
  	o=1;
  	
  end
  
  //This procedural block performs the error correction and detection part of
  //the given hamming encoded word. This block identifies which data has 2-bit
  //errors. 
  always@(*)
  begin
    //Initializing the internal variable temp_b with input data for parity
    //calculation.
  	temp_b       = i_data_b;
    //Initializing the internal variable temp_b_final with input data for
    //error correction using syndrome value. 
  	temp_b_final = i_data_b;
    //Calculating overall parity of the recieved hamming encoded word from
    //port-b.
    c_parity_b   = ^i_data_b;

    //The external for loop traverses through the powers of 2 indexes and the
    //internal for loop calculates the parity of the data bits that are
    //covered by that parity bit at that power of 2 position.
  	for(int i = DATA_WIDTH-1 ; i >= 1 ; i = i - 1)
  	begin
      if((i & (i - 1)) == 0)
  		begin
  			for(int k = i + 1 ; k <= DATA_WIDTH-1 ; k = k + 1)
  			begin
  				if((i & k) != 0)
  				begin
  					temp1 = temp1 ^ i_data_b[k];
  				end
  				else
  					temp_b[k] = temp_b[k];
  			end
  			if(temp1 == i_data_b[i])
  				temp_b[i] = 0;
  			else
  				temp_b[i] = 1;
  						
  		end
  		else
  		begin
        i = i;
  		end
      //Resetting temp1 to 0 so that it does not continue its next transaction
      //parity calculation from its previous transaction parity value. Due to this
      //the toogle coverage will not be hit hence we excluded toggle coverage
      //for temp1. 
  		temp1 = 0;
  	end
    //This for loop calcuates the syndrome value for port-b by traversing
    //thorugh the powers of 2 indexes and multiplying with their binary
    //weights, which converts the combined parity into decimal numnber that
    //determines the position of the error bit. 
  	for(int k = 1 ; k <= DATA_WIDTH-1 ; k = k + 1)
  	begin
      if((k & (k - 1)) == 0)
  		begin
  			syndrome_b = syndrome_b + ((k) * (temp_b[k]));
  		end
  
  		else
  			temp_b[k] = temp_b[k];			
  	end
    //This if-else block determines the position of the error bit and toggles
    //the bit which inturn corrects the bit at that position. 
  	if(syndrome_b != 0)
  		temp_b_final[syndrome_b] = ~temp_b_final[syndrome_b];
  	else
  		temp_b_final[syndrome_b] = temp_b_final[syndrome_b];

    //This if-else block determines the double-bit error by looking at the
    //overall parity bit and syndrome value which has to be non-zero.
    if(syndrome_b != 0 && c_parity_b == 0)
      o_dbit_err_b = 1;
    else
      o_dbit_err_b = 0;
    
    //Resetting syndrome_b to zero as for next transaction the calculation of
    //syndrome might not be correct because the previous trannsaction syndrome
    //value is still retained. Hence we reset to 0 for every transaction. This
    //causes the toggle coverage to not hit, hence we excluded toggle coverage
    //for syndrome_b.
  	syndrome_b = 0;
  
    //This for loop extracts all the data bits from the corrected hamming
    //decoded word and assigns them to the output of the module.
  	for(int y = 1 ; y <= DATA_WIDTH-1 ; y = y + 1)
  	begin
      if((y & (y - 1)) != 0)
  		begin
  			o_dout_b[u] = temp_b_final[y];
  			u = u + 1;
  		end
  		else
  			o_dout_b[u] = o_dout_b[u];
      end
    //Resetting u to 1 so that it does not continue its next transaction
    //data bit extraction from its previous transaction index value. Due to this
    //the toogle coverage will not be hit hence we excluded toggle coverage
    //for u.  
  	u = 1;
  	
  end

endmodule
