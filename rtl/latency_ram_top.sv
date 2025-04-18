//////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : latency_ram_top.sv                                                          //
//  Version           : 0.2                                                                         //    
//                                                                                                  //
//  parameters used   : WR_LATENCYA : Write latency of port-a                                       //
//                      WR_LATENCYB : Write latency of port-b                                       //
//                      RD_LATENCYA : Read latency of port-a                                        //
//                      RD_LATENCYB : Read latency of port-b                                        //
//                      DATA_WIDTH  : Width of the data                                             //
//                      ADDR_WIDTH  : Width of the address                                          //
//                      MEM_DEPTH   : Depth of the DP RAM                                           // 
//                                                                                                  //
//  Signals Used      : i_wea,i_web     : Write enable signals for port-a and port-b.               //
//                      i_ena,i_enb     : Enable signals for port-a and port-b.                     //
//                      clka,clkb       : Clock inputs for port-a and port-b.                       //
//                      i_dina,i_dinb   : Data inputs for port-a and port-b.                        //
//                      i_addra,i_addrb : Address inputs for port-a and port-b.                     //
//                      o_douta,o_doutb : Output data for port-a and port-b.                        //                                                             
//                                                                                                  //
//  File Description  : This is the top module of the latency feature of the DP-RAM, that connects  //
//                      the latency module to the normal Dual-Port RAM module.                      //
//                                                                                                  //  
////////////////////////////////////////////////////////////////////////////////////////////////////// 

module latency_top#(  parameter WR_LATENCYA   = 1,
                      parameter WR_LATENCYB   = 1,
                      parameter RD_LATENCYA   = 1,
                      parameter RD_LATENCYB   = 1,
                      parameter DATA_WIDTH    = 8,
                      parameter ADDR_WIDTH    = $clog2(MEM_DEPTH),
                      parameter MEM_DEPTH     = 16,
                      localparam PARITY_BITS  = $clog2(DATA_WIDTH)+1,
                      localparam ENCODED_WORD = DATA_WIDTH + PARITY_BITS)( input                     i_wea,i_web,     
                                                                           input                     i_ena,i_enb,     
                                                                           input                     clka,clkb,       
                                                                           input  [ENCODED_WORD+1:1] i_dina,i_dinb,   
                                                                           input  [ADDR_WIDTH-1:0]   i_addra,i_addrb, 
                                                                           output [ENCODED_WORD+1:1] o_douta,o_doutb   
                                                                        );

  wire [ENCODED_WORD+1:1] mem_douta,mem_doutb;               //outputs of memory comes to these wires.
  wire [ENCODED_WORD+1:1] latency_dina,latency_dinb;         //these wires are connected to i_dina and i_dinb of dp ram.
  wire [ADDR_WIDTH-1:0]   latency_wr_addra,latency_wr_addrb; //these wires are connected to i_addra_wr and i_addrb_wr of dp ram.
  wire                    latency_wea,latency_web;           //these wires are connected to i_we_a and i_we_b of dp ram.
  wire                    latency_wr_ena,latency_wr_enb;     //these wires are connected to i_ena_wr and i_enb_wr of dp ram.


  //The latency module delays all the write operation related signals by write
  //latency period and the output of the dual port ram is taken as read
  //operation input which is delayed by read latency period.
  latency#( .DATA_WIDTH(DATA_WIDTH),
            .ADDR_WIDTH(ADDR_WIDTH),
            .MEM_DEPTH(MEM_DEPTH),
            .WR_LATENCYA(WR_LATENCYA),
            .RD_LATENCYA(RD_LATENCYA),
            .WR_LATENCYB(WR_LATENCYB),
            .RD_LATENCYB(RD_LATENCYB)) LATENCY_MODULE(  .clka(clka),
                                                        .clkb(clkb),
                                                        .i_wea(i_wea),
                                                        .i_web(i_web),
                                                        .i_wr_dina(i_dina),
                                                        .i_wr_dinb(i_dinb),
                                                        .i_addra(i_addra),
                                                        .i_addrb(i_addrb),
                                                        .i_ena_wr_in(i_ena),
                                                        .i_enb_wr_in(i_enb),
                                                        .i_rd_dina(mem_douta),
                                                        .i_rd_dinb(mem_doutb),
                                                        .o_wr_dina_out(latency_dina),
                                                        .o_wr_dinb_out(latency_dinb),
                                                        .o_rd_dina_out(o_douta),
                                                        .o_rd_dinb_out(o_doutb),
                                                        .o_addra_out(latency_wr_addra),
                                                        .o_addrb_out(latency_wr_addrb),
                                                        .o_wea_out(latency_wea),
                                                        .o_web_out(latency_web),
                                                        .o_ena_wr_out(latency_wr_ena),
                                                        .o_enb_wr_out(latency_wr_enb));
   

   //This is the dual port ram module which consists of an internal memory and
   //all the read and write opearations are done within this memory.
   modified_dual_mem#( .DATA_WIDTH(DATA_WIDTH),
                       .ADDR_WIDTH(ADDR_WIDTH),
                       .MEM_DEPTH(MEM_DEPTH),
                       .WR_LATENCYA(WR_LATENCYA),
                       .RD_LATENCYA(RD_LATENCYA),
                       .WR_LATENCYB(WR_LATENCYB),
                       .RD_LATENCYB(RD_LATENCYB)) DP_RAM( .clka(clka),
                                                          .clkb(clkb),
                                                          .i_ena_wr(latency_wr_ena),
                                                          .i_enb_wr(latency_wr_enb),
                                                          .i_din_a(latency_dina),
                                                          .i_din_b(latency_dinb),
                                                          .i_ena_rd(i_ena),
                                                          .i_enb_rd(i_enb),
                                                          .i_we_a(latency_wea),
                                                          .i_we_b(latency_web),
                                                          .i_rd_a(i_wea),
                                                          .i_rd_b(i_web),
                                                          .i_addra_wr(latency_wr_addra),
                                                          .i_addrb_wr(latency_wr_addrb),
                                                          .i_addra_rd(i_addra),
                                                          .i_addrb_rd(i_addrb),
                                                          .o_douta(mem_douta),
                                                          .o_doutb(mem_doutb));

endmodule
