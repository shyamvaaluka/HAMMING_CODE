/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : MEMORY_CONTROL_TOP.sv                                                                          // 
//  Version           : 0.2                                                                                            //
//                                                                                                                     //
//  parameters used   : DATA_WIDTH   : Width of the data form port-a                                                   //
//                      ADDR_WIDTH   : Width of the address from port-a                                                //
//                      MEM_DEPTH    : Depth of the internal memory in the DP RAM                                      //
//                      MEM_WIDTH    : Width of each location in DP RAM                                                //
//                      ADDR_WIDTH1  : Nth bit of the top module address                                               //
//                      ADDR_WIDTH2  : N-1 bit of the top module address                                               //
//                      DATA_BITS    : Number of data bits                                                             //
//                      PARITY_BITS  : Number of parity bits being injected into the data                              //
//                      ENCODED_WORD : Length of the hamming encoded word                                              //
//                      WR_LATENCYA  : Write latency of port-a                                                         //
//                      RD_LATENCYA  : Read latency of port-a                                                          //
//                      WR_LATENCYB  : Write latency of port-b                                                         //
//                      RD_LATENCYB  : Read latency of port-b                                                          //
//                                                                                                                     //
//  Signals Used      : clka,clkb                  : Clock inputs for port-a and port-b.                               //
//                      i_wea,i_web                : Write_enable signals for port-a and port-b.                       //
//                      i_ena,i_enb                : Enable signals for port-a and port-b.                             //
//                      i_addra                    : port-a input address.                                             //
//                      i_addrb                    : port-b input address.                                             //
//                      i_data_in_a                : port-a data input.                                                //
//                      i_data_in_b                : port-b data input.                                                //
//                      o_dbit_err_a,o_dbit_err_b  : double_bit error indication flags for port-a and port-b.          //
//                      o_dout_a                   : Data output port for port-a.                                      //
//                      o_dout_b                   : Data output port for port-b.                                      //
//                                                                                                                     //
//  File Description  : This is the top module that combines all the features that include latency,banking,            //
//                      error detection and correction.                                                                //         
//                                                                                                                     //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module memory_top#( parameter DATA_WIDTH   = 12,
	                  parameter ADDR_WIDTH   = 10,
	                  parameter MEM_DEPTH    = 64,
	                  parameter WR_LATENCYA  = 1,
	                  parameter RD_LATENCYA  = 1,
	                  parameter WR_LATENCYB  = 1,
	                  parameter RD_LATENCYB  = 1
                  )(  input                    clka,clkb,                 
                      input                    i_wea,i_web,               
                      input                    i_ena,i_enb,               
	                    input  [ADDR_WIDTH-1:0]  i_addra,                   
	                    input  [ADDR_WIDTH-1:0]  i_addrb,                   
	                    input  [DATA_WIDTH-1:0]  i_data_in_a,               
	                    input  [DATA_WIDTH-1:0]  i_data_in_b,               
                      output                   o_dbit_err_a,o_dbit_err_b, 
	                    output [DATA_WIDTH-1:0]  o_dout_a,                  
	                    output [DATA_WIDTH-1:0]  o_dout_b                   
                   );

  localparam MEM_WIDTH    = 2*ADDR_WIDTH;
  localparam ADDR_WIDTH1  = ADDR_WIDTH;
  localparam ADDR_WIDTH2  = ADDR_WIDTH - 1;
  localparam DATA_BITS    = DATA_WIDTH;
  localparam PARITY_BITS  = $clog2(DATA_BITS) + 1;
  localparam ENCODED_WORD = DATA_BITS+PARITY_BITS;
	
	wire [ENCODED_WORD+1:1]            bank_a1,bank_a2,bank_a3,bank_a4;   // Wires to transmit bank outputs of port-a.
  wire [ENCODED_WORD+1:1]            w_a_ham,w_b_ham;                   // Wires to transmit hamming code word for port-a and port-b.
	wire [ENCODED_WORD+1:1]            bank_b1,bank_b2,bank_b3,bank_b4;   // Wires to trasmit bank outputs of port-b.
  wire [ENCODED_WORD+1:1]            wa_decoder,w_b_decoder;            // Wires to transmit corrupted encoded data to hamming decoder for port-a and port-b.
	reg  [ADDR_WIDTH1-1:ADDR_WIDTH2-1] sel_in_a,sel_in_b;                 // Wires to transmit the top two bits of input address from top module to select latency module.
  reg  [ADDR_WIDTH1-1:ADDR_WIDTH2-1] sel_out_a,sel_out_b;               // Outputs of select latency module that goes to data selector to route data onto single channel.
  bit  [ENCODED_WORD+1:1]            i_err_a,i_err_b;                   // Error inputs for port-a and port-b.
  bit  [ENCODED_WORD+1:1]            temp_a,temp_b;                     // Internal variables to randomize with one_bit,two_bit and zero_bit errors.
  bit  [1:0]                         i,j;                               // Internal variables whcih are used to generate random values from 0 to 2.
  typedef enum logic                 {PORTA,PORTB}port_sel;             // Enumrated data type to randomize between port-a and port-b.
  logic                              rand_status_a,rand_status_b;       // An Internal vriables to store seed values while randomizing temp_a and temp_b.

  //Data router for port-a which routes all the 4 data outputs from the dual
  //port memories of port-a type onto single channel.
	MUX_4x1#( .DATA_WIDTH(DATA_WIDTH),
            .ADDR_1(ADDR_WIDTH1),
            .ADDR_2(ADDR_WIDTH2))BANK_ROUTER_A( .i_i0(bank_a1),
                                                .i_i1(bank_a2),
                                                .i_i2(bank_a3),
                                                .i_i3(bank_a4),
                                                .o_Y(wa_decoder),
                                                .i_sel(sel_out_a)
                                              );

  //Data router for port-b which routes all the 4 data outputs from the dual
  //port memories of port-b type onto single channel.
	MUX_4x1#( .DATA_WIDTH(DATA_WIDTH),
            .ADDR_1(ADDR_WIDTH),
            .ADDR_2(ADDR_WIDTH-1))BANK_ROUTER_B(  .i_i0(bank_b1),
                                                  .i_i1(bank_b2),
                                                  .i_i2(bank_b3),
                                                  .i_i3(bank_b4),
                                                  .o_Y(w_b_decoder),
                                                  .i_sel(sel_out_b)
                                               );

  //Memory controller which deals with overall banking, address decoding and
  //routing of data to their corresponding bank.
	memory_control_unit#( .DATA_WIDTH(DATA_WIDTH),
                        .ADDR_WIDTH(ADDR_WIDTH),
                        .MEM_DEPTH(MEM_DEPTH),
                        .MEM_WIDTH(MEM_WIDTH),
                        .WR_LATENCYA(WR_LATENCYA),
                        .RD_LATENCYA(RD_LATENCYA),
                        .WR_LATENCYB(WR_LATENCYB),
                        .RD_LATENCYB(RD_LATENCYB))MEMORY_BANKS_UNIT( .clka(clka),
                                                                     .clkb(clkb),
                                                                     .i_wea(i_wea),
                                                                     .i_web(i_web),
                                                                     .i_ena(i_ena),
                                                                     .i_enb(i_enb),
                                                                     .i_addra(i_addra),
                                                                     .i_addrb(i_addrb),
                                                                     .i_data_in_a(w_a_ham),
                                                                     .i_data_in_b(w_b_ham),
                                                                     .bank_a_1(bank_a1),
                                                                     .bank_a_2(bank_a2),
                                                                     .bank_a_3(bank_a3),
                                                                     .bank_a_4(bank_a4),
	                                                                   .bank_b_1(bank_b1),
                                                                     .bank_b_2(bank_b2),
                                                                     .bank_b_3(bank_b3),
                                                                     .bank_b_4(bank_b4)
                                                                  );
  //This module selects the data from the memory outputs after read latency
  //period. Based on this select input, the mux routes one of its 4 inputs onto
  //the single channel.
	sel_latency#( .READ_LATENCYA(RD_LATENCYA),
                .READ_LATENCYB(RD_LATENCYB),
                .ADDR_WIDTH1(ADDR_WIDTH1),
                .ADDR_WIDTH2(ADDR_WIDTH2))ROUTER_SELECT_LINES( .clka(clka),
                                                               .clkb(clkb),
                                                               .i_sel_in_a(sel_in_a),
                                                               .i_sel_in_b(sel_in_b),
                                                               .o_sel_out_a(sel_out_a),
                                                               .o_sel_out_b(sel_out_b)
                                                             );

  // This is the top module of hamming encoder and error injector which
  // encodes the data and then it is corrupted by error injector.
  hamming_encoder_top#( .DATA_WIDTH(DATA_WIDTH))ERROR_CORRECTION( .i_data_a(i_data_in_a),
                                                                  .i_data_b(i_data_in_b),
                                                                  .i_temp_a(i_err_a),
                                                                  .i_temp_b(i_err_b),
                                                                  .o_douta(w_a_ham),
                                                                  .o_doutb(w_b_ham)
                                                                );

   //This hamming decoder module gets the encoded word as input and performs
   //single bit error correction and double bit error detection.
   ham_dec#( .DATA_WIDTH(ENCODED_WORD+1))HAM_DECODER( .i_data_a(wa_decoder),
                                                      .i_data_b(w_b_decoder),
                                                      .o_dout_a(o_dout_a),
                                                      .o_dout_b(o_dout_b),
                                                      .o_dbit_err_a(o_dbit_err_a),
                                                      .o_dbit_err_b(o_dbit_err_b)
                                               ); 
	
  //This always block routes the data onto the single channel during read
  //operation configuration.
  always@(*)
  begin
    if(i_ena == 1'b1 && i_wea == 1'b0)
       sel_in_a = i_addra[ADDR_WIDTH - 1 : ADDR_WIDTH - 2];
    if(i_enb == 1'b1 && i_web == 1'b0)
       sel_in_b = i_addrb[ADDR_WIDTH - 1 : ADDR_WIDTH - 2];
  end

  //This task is called from the peer's test bench top module where it defines
  //the logic for error injection and corruption of hamming encoded word.
  task automatic error_inject(input logic port);
    if(port == PORTA)
    begin
      //Here we are first generating random values between 0-2.
      i             = $urandom_range(0,2);
      //Then we are randomizing the temp_a variable with $countones function
      //that is assigned with i which generates 0-bit,1-bit and 2-bit errors.
      rand_status_a = (std::randomize(temp_a) with {$countones(temp_a) == i;});
      //Finally we are assigning this value to the error input of port-a.
      i_err_a       = temp_a;
    end       
    else
    begin
      //Here we are first generating random values between 0-2.
      j             = $urandom_range(0,2);
      //Then we are randomizing the temp_b variable with $countones function
      //that is assigned with i which generates 0-bit,1-bit and 2-bit errors. 
      rand_status_b = (std::randomize(temp_b) with {$countones(temp_b) == j;});
      //Finally we are assigning this value to the error input of port-b. 
      i_err_b       = temp_b;
    end
  endtask 

endmodule
