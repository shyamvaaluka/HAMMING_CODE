////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : hamming.sv                                                                    //
//  Version           : 0.2                                                                           //
//                                                                                                    //
//  parameters used   : DATA_WIDTH       : Width of the data from port-a                              //
//                      DATA_B       : Width of the data from port-b                                  //
//                      DATA_BITS    : Number of data bits                                            //
//                      PARITY_BITS  : Number of parity bits to be injected                           //
//                      ENCODED_WORD : Length of the hamming encoded word                             // 
//                                                                                                    //
//  Signals Used      : i_data_in_a             : Input data from port-a that is to be encoded.       //
//                      i_data_in_b             : Input data from port-b that is to be encoded.       //
//                      o_hamming_a,o_hamming_b : Output hamming_encoded word for port-a and port-b.  //
//                                                                                                    // 
//                                                                                                    //
//  File Description  : This is a hamming encoder module that injects parity bits into the data       //
//                      which is later used for error detection and correction. Here even parity      //
//                      calculation is being used by the sender.                                      //  
//                                                                                                    //  
//////////////////////////////////////////////////////////////////////////////////////////////////////// 

module ham_enc#(parameter DATA_WIDTH        =  32,
                parameter ENCODED_WORD      =  10
               )(input      [DATA_WIDTH-1:0]    i_data_in_a,            
                 input      [DATA_WIDTH-1:0]    i_data_in_b,            
                 output reg [ENCODED_WORD+1:1]  o_hamming_a,o_hamming_b 
                );

  int j;                      // Internal variable for traversing through the data bits.
  int temp;                   // Internal variable to store the parity calculation for port-a.
  int temp1;                  // Internal variable to store the parity calculation for port-b.
  reg x_parity_a,x_parity_b;  // Extra parity bit to calculate the overall parity of the data in port-a and port-b.
  

  //This combinational procedural block performs the hamming encoding of the
  //given input data for port-a by first traversing through all the data bits
  //and then performs the parity calculation by doing bitwise XOR operation of the
  //data bits that are covered by each parity bit. These parity bits are
  //located at powers of 2 index.
  always@(*)
  begin
    //This for loop traverses through all the non powers of 2 indexes and
    //places the data bits in those positions.
    for(int i = 1 ; i <= ENCODED_WORD ; i = i + 1)
    begin
      if((i & (i-1)) != 0)
      begin
        o_hamming_a[i] = i_data_in_a[j++];	
      end
      else
        o_hamming_a[i] = o_hamming_a[i];
    end
    //This external for loop traverses through all the powers of 2 positions and
    //then the internal for loop will calculate the parity of the data bits
    //that are covered by that parity bit present at that power of 2 position.
    for(int l = 1 ; l <= ENCODED_WORD ; l = l + 1)
    begin 
      if((l & (l-1)) == 0)
      begin
        for(int k = l + 1 ; k <= ENCODED_WORD; k = k+1)
        begin
        	if((l & k) != 0)
        		temp = temp ^ o_hamming_a[k];
        	else
        		o_hamming_a[k] = o_hamming_a[k];                                               
        end
        o_hamming_a[l] = temp;
      end
      else
      begin
      	l = l;
      end
      //Resetting temp to 0 so that it does not continue its next transaction
      //parity calculation from its previous transaction parity value. Due to this
      //the toogle coverage will not be hit hence we excluded toggle coverage
      //for temp.
      temp = 0;
    end
    //Resetting j to 0 so that it does not continue its next transaction
    //data bit insertion from its previous transaction index value value. Due to this
    //the toogle coverage will not be hit hence we excluded toggle coverage
    //for j. 
    j = 0;
    //This x_parity calculates overall parity for port-a and assigns it to the
    //MSB bit of the encoded word for port-a.
    x_parity_a  = ^(o_hamming_a[ENCODED_WORD : 1]);
    o_hamming_a = {x_parity_a , o_hamming_a[ENCODED_WORD : 1]};
  end
  
  
  //This combinational procedural block performs the hamming encoding of the
  //given input data for port-b by first traversing through all the data bits
  //and then performs the parity calculation by doing bitwise XOR operation of the
  //data bits that are covered by each parity bit. These parity bits are
  //located at powers of 2 index.
  always@(*)
  begin
    //This for loop traverses through all the non powers of 2 indexes and
    //places the data bits in those positions.
    for(int i = 1 ; i <= ENCODED_WORD ; i = i + 1)
    begin
      if((i & (i-1)) != 0)
      begin
        o_hamming_b[i] = i_data_in_b[j++];	
      end
      else
        o_hamming_b[i] = o_hamming_b[i];
    end
    //This external for loop traverses through all the powers of 2 positions and
    //then the internal for loop will calculate the parity of the data bits
    //that are covered by that parity bit present at that power of 2 position. 
    for(int l = 1 ; l<= ENCODED_WORD ; l = l + 1)
    begin
      if((l & (l-1)) == 0)
      begin
        for(int k = l + 1 ; k <= ENCODED_WORD ; k = k + 1)
        begin
          if((l & k) != 0)
            temp1 = temp1 ^ o_hamming_b[k];
          else
            o_hamming_b[k] = o_hamming_b[k];                                               
        end
        o_hamming_b[l] = temp1;
      end
      else
      begin
      	l = l;
      end
      //Resetting temp1 to 0 so that it does not continue its next transaction
      //parity calculation from its previous transaction parity value. Due to this
      //the toogle coverage will not be hit hence we excluded toggle coverage
      //for temp1. 
      temp1 = 0;
    	
    end
    //Resetting j to 0 so that it does not continue its next transaction
    //data bit insertion from its previous transaction index value value. Due to this
    //the toogle coverage will not be hit hence we excluded toggle coverage
    //for j. 
    j = 0;
    //This x_parity calculates overall parity for port-b and assigns it to the
    //MSB bit of the encoded word for port-b. 
    x_parity_b  = ^(o_hamming_b[ENCODED_WORD : 1]);
    o_hamming_b = {x_parity_b , o_hamming_b[ENCODED_WORD : 1]};
  end

endmodule






