///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name        : Controlling_Memory.v                                                                      //
//  Version          : 0.2                                                                                       //
//                                                                                                               //
//  parameters used  : DATA_WIDTH  : Width of the data in port-a                                                 //
//                     ADDR_WIDTH  : Width of the address in port-a                                              //                  
//                     MEM_DEPTH   : Depth of the internal memory of the DP RAM                                  //                     
//                     MEM_WIDTH   : Width of each location in DP RAM                                            //                     
//                     WR_LATENCYA : Write latency for port-a                                                    //                     
//                     RD_LATENCYA : Read latency for port-a                                                     //                     
//                     WR_LATENCYB : Write latency for port-b                                                    //                     
//                     RD_LATENCYB : Read latency for port-b                                                     //
//                                                                                                               //
//   Signals used    : clka,clkb                           : Clock inputs for port-a and port-b.                 //
//                     i_wea,i_web                         : Write_enable signals for port-a and port-b.         //
//                     i_ena,i_enb                         : Enable signals for port-a and port-b.               //
//                     i_addra                             : Input address for port-a.                           //
//                     i_addrb                             : Input address for port-b.                           //
//                     i_data_in_a                         : Input data for port-a.                              //
//                     i_data_in_b                         : Input data for port-b.                              //
//                     bank_a_1,bank_a_2,bank_a_3,bank_a_4 : Port-a bank outputs of all the 4 banks.             //
//                     bank_b_1,bank_b_2,bank_b_3,bank_b_4 : Port-b bank outputs of all the 4 banks.             //
//                                                                                                               //
//                                                                                                               //
//  File Description : This top module connects the banking control interface module to all the four dual-port   //
//                     memory banks. And the bank selection is done by the address decoding logic present        //
//                     in the banking control interface module.                                                  //
//                                                                                                               //  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module memory_control_unit#(  parameter DATA_WIDTH    = 12,
	                            parameter ADDR_WIDTH    = $clog2(4*MEM_DEPTH),
	                            parameter MEM_DEPTH     = 64,
	                            parameter MEM_WIDTH     = 2*ADDR_WIDTH,
	                            parameter WR_LATENCYA   = 1,
	                            parameter RD_LATENCYA   = 1,
	                            parameter WR_LATENCYB   = 1,
	                            parameter RD_LATENCYB   = 1,
                              localparam PARITY_BITS  = $clog2(DATA_WIDTH)+1,
                              localparam ENCODED_WORD = DATA_WIDTH + PARITY_BITS
                              )(  input                     clka,clkb,                       
                                  input                     i_wea,i_web,                         
                                  input                     i_ena,i_enb,                     
	                                input  [ADDR_WIDTH-1:0]   i_addra,                         
	                                input  [ADDR_WIDTH-1:0]   i_addrb,                         
	                                input  [ENCODED_WORD+1:1] i_data_in_a,                     
	                                input  [ENCODED_WORD+1:1] i_data_in_b,                     
	                                output [ENCODED_WORD+1:1] bank_a_1,bank_a_2,bank_a_3,bank_a_4,   
	                                output [ENCODED_WORD+1:1] bank_b_1,bank_b_2,bank_b_3,bank_b_4    
                               );
	
	wire                    ena_w1,ena_w2,ena_w3,ena_w4,enb_w1,enb_w2,enb_w3,enb_w4; //enable wires.
	wire [ADDR_WIDTH-3:0]   w_a1,w_a2,w_a3,w_a4;                                     //address_a wires.
	wire [ADDR_WIDTH-3:0]   w_b1,w_b2,w_b3,w_b4;                                     //address_b wires.
	wire [ENCODED_WORD+1:1] d_a1,d_a2,d_a3,d_a4;                                     //data_a wires.
	wire [ENCODED_WORD+1:1] d_b1,d_b2,d_b3,d_b4;                                     //data_b wires.



	// This latency module for BANK-1 delays the write operation related signals by write_latency
  // period and given to the memory as input. The memory output is taken as input to 
  // this module which inturn is given as the output to the top module after 
  // read_latency period.
	latency_top#( .WR_LATENCYA(WR_LATENCYA),
                .WR_LATENCYB(WR_LATENCYB),
                .RD_LATENCYA(RD_LATENCYA),
	              .RD_LATENCYB(RD_LATENCYB),
                .MEM_DEPTH(MEM_DEPTH),
                .ADDR_WIDTH(ADDR_WIDTH-2),
                .DATA_WIDTH(DATA_WIDTH))BANK_1( .clka(clka),
                                                .clkb(clkb),
                                                .i_wea(i_wea),
                                                .i_web(i_web),
                                                .i_ena(ena_w1),
                                                .i_enb(enb_w1),
                                                .i_addra(w_a1),
                                                .i_addrb(w_b1),
	                                              .i_dina(d_a1),
                                                .i_dinb(d_b1),
                                                .o_douta(bank_a_1),
                                                .o_doutb(bank_b_1));

  // This latency module for BANK-2 delays the write operation related signals by write_latency
  // period and given to the memory as input. The memory output is taken as input to 
  // this module which inturn is given as the output to the top module after 
  // read_latency period.	
	latency_top#( .WR_LATENCYA(WR_LATENCYA),
                .WR_LATENCYB(WR_LATENCYB),
                .RD_LATENCYA(RD_LATENCYA),
	              .RD_LATENCYB(RD_LATENCYB),
                .MEM_DEPTH(MEM_DEPTH),
                .ADDR_WIDTH(ADDR_WIDTH-2),
                .DATA_WIDTH(DATA_WIDTH))BANK_2( .clka(clka),
                                                .clkb(clkb),
                                                .i_wea(i_wea),
                                                .i_web(i_web),
                                                .i_ena(ena_w2),
                                                .i_enb(enb_w2),
                                                .i_addra(w_a2),
                                                .i_addrb(w_b2),
	                                              .i_dina(d_a2),
                                                .i_dinb(d_b2),
                                                .o_douta(bank_a_2),
                                                .o_doutb(bank_b_2));
	  
	// This latency module for BANK-3 delays the write operation related signals by write_latency
  // period and given to the memory as input. The memory output is taken as input to 
  // this module which inturn is given as the output to the top module after 
  // read_latency period. 
	latency_top#( .WR_LATENCYA(WR_LATENCYA),
                .WR_LATENCYB(WR_LATENCYB),
                .RD_LATENCYA(RD_LATENCYA),
	              .RD_LATENCYB(RD_LATENCYB),
                .MEM_DEPTH(MEM_DEPTH),
                .ADDR_WIDTH(ADDR_WIDTH-2),
                .DATA_WIDTH(DATA_WIDTH))BANK_3( .clka(clka),
                                                .clkb(clkb),
                                                .i_wea(i_wea),
                                                .i_web(i_web),
                                                .i_ena(ena_w3),
                                                .i_enb(enb_w3),
                                                .i_addra(w_a3),
                                                .i_addrb(w_b3),
	                                              .i_dina(d_a3),
                                                .i_dinb(d_b3),
                                                .o_douta(bank_a_3),
                                                .o_doutb(bank_b_3));
	  
	// This latency module for BANK-4 delays the write operation related signals by write_latency
  // period and given to the memory as input. The memory output is taken as input to 
  // this module which inturn is given as the output to the top module after 
  // read_latency period.
  latency_top#( .WR_LATENCYA(WR_LATENCYA),
                .WR_LATENCYB(WR_LATENCYB),
                .RD_LATENCYA(RD_LATENCYA),
	              .RD_LATENCYB(RD_LATENCYB),
                .MEM_DEPTH(MEM_DEPTH),
                .ADDR_WIDTH(ADDR_WIDTH-2),
                .DATA_WIDTH(DATA_WIDTH))BANK_4( .clka(clka),
                                                .clkb(clkb),
                                                .i_wea(i_wea),
                                                .i_web(i_web),
                                                .i_ena(ena_w4),
                                                .i_enb(enb_w4),
                                                .i_addra(w_a4),
                                                .i_addrb(w_b4),
	                                              .i_dina(d_a4),
                                                .i_dinb(d_b4),
                                                .o_douta(bank_a_4),
                                                .o_doutb(bank_b_4));


	  
	//This is the banking control interface module which is the main module that
  //deals with address decoding, bank selection and data routing using
  //demultiplexers and decoders.
	controller_interface#(  .MEM_DEPTH(MEM_DEPTH),
                          .ADDR_WIDTH(ADDR_WIDTH),
                          .DATA_WIDTH(DATA_WIDTH))BANKING_CONTROL_INTERFACE(  .i_addra(i_addra),
                                                                              .i_addrb(i_addrb),
                                                                              .i_data_a(i_data_in_a),
                                                                              .i_data_b(i_data_in_b),
                                                                              .i_ena(i_ena),
                                                                              .i_enb(i_enb),
	                                                                            .o_a1(ena_w1),
                                                                              .o_a2(ena_w2),
                                                                              .o_a3(ena_w3),
                                                                              .o_a4(ena_w4),
                                                                              .o_b1(enb_w1),
                                                                              .o_b2(enb_w2),
                                                                              .o_b3(enb_w3),
                                                                              .o_b4(enb_w4),
                                                                              .o_addr_out_a1(w_a1),
                                                                              .o_addr_out_a2(w_a2),
	                                                                            .o_addr_out_a3(w_a3),
                                                                              .o_addr_out_a4(w_a4),
                                                                              .o_addr_out_b1(w_b1),
                                                                              .o_addr_out_b2(w_b2),
	                                                                            .o_addr_out_b3(w_b3),
                                                                              .o_addr_out_b4(w_b4),
                                                                              .o_data_out_a1(d_a1),
                                                                              .o_data_out_a2(d_a2),
                                                                              .o_data_out_a3(d_a3),
                                                                              .o_data_out_a4(d_a4),
	                                                                            .o_data_out_b1(d_b1),
                                                                              .o_data_out_b2(d_b2),
                                                                              .o_data_out_b3(d_b3),
                                                                              .o_data_out_b4(d_b4));
	
endmodule
