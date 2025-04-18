////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : controller_interface.v                                                                            //
//  Version           : 0.2                                                                                               //
//                                                                                                                        //
//  parameters used   : MEM_DEPTH   : Depth of the DP RAM                                                                 //
//                      ADDR_WIDTH : Width of address                                                                     //
//                      DATA_WIDTH : Width of data                                                                        //
//                                                                                                                        //
//  Signals Used      : i_addra                                                 : input address for port-a.               //
//                      i_addrb                                                 : input address for port-b.               //
//                      i_data_a                                                : input data for port-a.                  //
//                      i_data_b                                                : input data for port-b.                  //
//                      i_ena,i_enb                                             : enable signals for port-a and port-b.   //
//                      o_addr_out_a1,o_addr_out_a2,o_addr_out_a3,o_addr_out_a4 : Decoded bank addresses for port-a.      //
//                      o_addr_out_b1,o_addr_out_b2,o_addr_out_b3,o_addr_out_b4 : Decoded bank addresses for port-b.      //
//                      o_data_out_a1,o_data_out_a2,o_data_out_a3,o_data_out_a4 : Bank associated data for port-a.        //
//                      o_data_out_b1,o_data_out_b2,o_data_out_b3,o_data_out_b4 : Bank associated data for port-b.        //
//                      o_a1,o_a2,o_a3,o_a4                                     : Bank enable signals for port-a.         //
//                      o_b1,o_b2,o_b3,o_b4                                     : Bank enable signals for port-b.         //
//                                                                                                                        // 
//                                                                                                                        //
//  File Description  : This is the top module of the banking control interface that connects all the address             // 
//                      decoding and data decoding muxes to the bank selection decoders that forms                        //
//                      the overall banking control and selection logic.                                                  //
//                                                                                                                        //  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module controller_interface#( parameter MEM_DEPTH     = 64,
	                            parameter ADDR_WIDTH    = $clog2(4 * MEM_DEPTH),
	                            parameter DATA_WIDTH    = 8,
                              localparam PARITY_BITS  = $clog2(DATA_WIDTH)+1,
                              localparam ENCODED_WORD = DATA_WIDTH + PARITY_BITS
                            )(  input  [ADDR_WIDTH-1:0]   i_addra,                                                 
	                              input  [ADDR_WIDTH-1:0]   i_addrb,                                                 
	                              input  [ENCODED_WORD+1:1] i_data_a,                                                
	                              input  [ENCODED_WORD+1:1] i_data_b,                                                
	                              input                     i_ena,i_enb,                                             
	                              output [ADDR_WIDTH-3:0]   o_addr_out_a1,o_addr_out_a2,o_addr_out_a3,o_addr_out_a4, 
	                              output [ADDR_WIDTH-3:0]   o_addr_out_b1,o_addr_out_b2,o_addr_out_b3,o_addr_out_b4, 
	                              output [ENCODED_WORD+1:1] o_data_out_a1,o_data_out_a2,o_data_out_a3,o_data_out_a4, 
	                              output [ENCODED_WORD+1:1] o_data_out_b1,o_data_out_b2,o_data_out_b3,o_data_out_b4, 
	                              output                    o_a1,o_a2,o_a3,o_a4,                                     
	                              output                    o_b1,o_b2,o_b3,o_b4                                      
                             );

	wire [ADDR_WIDTH-1:ADDR_WIDTH-2] address_select_a,address_select_b;         // These wires select the banks to which the address has to be routed for port-a and port-b.
  wire [ADDR_WIDTH-1:ADDR_WIDTH-2] data_select_a,data_select_b;               // These wires select the banks to whcih the data has to be routed for port-a and port-b.
  wire [ADDR_WIDTH-1:ADDR_WIDTH-2] bank_select_a,bank_select_b;               // These wires enable the bank based on the top two bits of the input address.
  wire [ADDR_WIDTH-3:0]            bank_address_a;                            // This wire transmits the bank address for port-a.
	wire [ADDR_WIDTH-3:0]            bank_address_b;                            // This wire transmits the bank address for port-b.
	wire [3:0]                       bank_select_output_a,bank_select_output_b; // These wires are one-hot encoded outputs of the decoders with which the banks are enabled one at a time.
	
	
  // This demultiplexer selects the bank and routes the corresponding bank
  // address for port-a.
  demultiplexer1_address#(  .ADDR_WIDTH(ADDR_WIDTH),
                            .SELECT_WIDTH1(ADDR_WIDTH),
                            .SELECT_WIDTH2(ADDR_WIDTH-1))ADDRESS_DECODER_1( .i_address(bank_address_a),
                                                                            .i_sel(address_select_a),
                                                                            .o_y0(o_addr_out_a1),
                                                                            .o_y1(o_addr_out_a2),
                                                                            .o_y2(o_addr_out_a3),
                                                                            .o_y3(o_addr_out_a4)
                                                                           );

	// This demultiplexer selects the bank and routes the corresponding bank
  // address for port-b.
	demultiplexer1_address#(  .ADDR_WIDTH(ADDR_WIDTH),
                            .SELECT_WIDTH1(ADDR_WIDTH),
                            .SELECT_WIDTH2(ADDR_WIDTH-1))ADDRESS_DECODER_2( .i_address(bank_address_b),
                                                                            .i_sel(address_select_b),
                                                                            .o_y0(o_addr_out_b1),
                                                                            .o_y1(o_addr_out_b2),
                                                                            .o_y2(o_addr_out_b3),
                                                                            .o_y3(o_addr_out_b4)
                                                                           );

	//This demultiplexer takes the input data and routes it to the selected bank
  //for port-a operations.
	demultiplexer_data#(  .DATA_WIDTH(DATA_WIDTH),
                        .SELECT_DATA_WIDTH1(ADDR_WIDTH),
                        .SELECT_DATA_WIDTH2(ADDR_WIDTH-1))DATA_ROUTING_A(  .i_data(i_data_a),
                                                                           .i_sel(data_select_a),
                                                                           .o_y0(o_data_out_a1),
                                                                           .o_y1(o_data_out_a2),
                                                                           .o_y2(o_data_out_a3),
                                                                           .o_y3(o_data_out_a4)
                                                                         );

	//This demultiplexer takes the input data and routes it to the selected bank
  //for port-b operations.
	demultiplexer_data#(  .DATA_WIDTH(DATA_WIDTH),
                        .SELECT_DATA_WIDTH1(ADDR_WIDTH),
                        .SELECT_DATA_WIDTH2(ADDR_WIDTH-1))DATA_ROUTING_B(  .i_data(i_data_b),
                                                                           .i_sel(data_select_b),
                                                                           .o_y0(o_data_out_b1),
                                                                           .o_y1(o_data_out_b2),
                                                                           .o_y2(o_data_out_b3),
                                                                           .o_y3(o_data_out_b4)
                                                                         );

  // This decoder module enables one bank at a time to which the write and
  // read operations are transmitted for port-a only.	
	decoder_enable_lines#(  .SELECT_ADDR1(ADDR_WIDTH),
                          .SELECT_ADDR2(ADDR_WIDTH-1))BANK_SELECTOR_A(  .i_I(bank_select_a),
                                                                        .o_y(bank_select_output_a)
                                                                      );

  // This decoder module enables one bank at a time to which the write and
  // read operations are transmitted for port-b only.
	decoder_enable_lines#(  .SELECT_ADDR1(ADDR_WIDTH),
                          .SELECT_ADDR2(ADDR_WIDTH-1))BANK_SELECTOR_B(  .i_I(bank_select_b),
                                                                        .o_y(bank_select_output_b)
                                                                      );

	// This assignment excludes the first two bits of the input address and
  // assigns the remaining bits to the wire bank_address_a. Which inturn
  // defines the bank address for port-a.
	assign bank_address_a   = i_addra [ADDR_WIDTH-3:0];

  // This assignment excludes the first two bits of the input address and
  // assigns the remaining bits to the wire bank_address_b. Which inturn
  // defines the bank address for port-a.
	assign bank_address_b   = i_addrb [ADDR_WIDTH-3:0];

  // This assignment takes the first two bits of the input address and assigns
  // it to the address_select_a wire. Which selects the bank for address
  // routing of port-a.
	assign address_select_a = i_addra [ADDR_WIDTH-1:ADDR_WIDTH-2];

  // This assignment takes the first two bits of the input address and assigns
  // it to the address_select_b wire. Which selects the bank for address
  // routing of port-b.
	assign address_select_b = i_addrb [ADDR_WIDTH-1:ADDR_WIDTH-2];

  // This assignment takes the first two bits of the input address and assigns
  // it to the data_select_a wire. Which selects the bank for data
  // routing of port-a. 
	assign data_select_a    = i_addra [ADDR_WIDTH-1:ADDR_WIDTH-2];

  // This assignment takes the first two bits of the input address and assigns
  // it to the data_select_b wire. Which selects the bank for data
  // routing of port-b.
	assign data_select_b    = i_addrb [ADDR_WIDTH-1:ADDR_WIDTH-2];

  //This assignment assigns the first two bits of input address for decoder
  //select lines to enable one bank at a time for write and read operations of
  //port-a.
	assign bank_select_a    = data_select_a;

  //This assignment assigns the first two bits of input address for decoder
  //select lines to enable one bank at a time for write and read operations of
  //port-b. 
	assign bank_select_b    = data_select_b;

  //All these assignments for port-a bank enable signals are conditionally done through the output enable lines
  //that gets asserted when only the input enable from the top module gets asserted.
	assign o_a1 = bank_select_output_a[3] ? (i_ena == 1) : 1'b0;
	assign o_a2 = bank_select_output_a[2] ? (i_ena == 1) : 1'b0;
	assign o_a3 = bank_select_output_a[1] ? (i_ena == 1) : 1'b0;
	assign o_a4 = bank_select_output_a[0] ? (i_ena == 1) : 1'b0;

  //All these assignments for port-a bank enable signals are conditionally done through the output enable lines
  //that gets asserted when only the input enable from the top module gets asserted.
	assign o_b1 = bank_select_output_b[3] ? (i_enb == 1) : 1'b0;
	assign o_b2 = bank_select_output_b[2] ? (i_enb == 1) : 1'b0;
	assign o_b3 = bank_select_output_b[1] ? (i_enb == 1) : 1'b0;
	assign o_b4 = bank_select_output_b[0] ? (i_enb == 1) : 1'b0;

endmodule
