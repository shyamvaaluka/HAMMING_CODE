/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : modified_dual_mem.sv                                                                   //
//  Version           : 0.2                                                                                    //
//                                                                                                             //
//  parmeters used    : DATA_WIDTH  : Width of the data                                                        //
//                      ADDR_WIDTH  : Width of the address                                                     //
//                      MEM_DEPTH   : Depth of the DP RAM                                                      //
//                      MEM_WIDTH   : Width of each location in DP RAM                                         //
//                      WR_LATENCYA : Write latency of port-a                                                  //
//                      RD_LATENCYA : Read latency of port-a                                                   //
//                      WR_LATENCYB : Write latency of port-b                                                  //
//                      RD_LATENCYB : Read latency of port-b                                                   // 
//                                                                                                             //
//  Signals Used      : clka,clkb              : Clock inputs for port-a and port-b.                           //
//                      i_ena_wr,i_enb_wr      : Latency enable write for port-a and  port-b.                  //
//                      i_ena_rd,i_enb_rd      : Normal enable read for port-a and port-b.                     //
//                      i_we_a,i_rd_a          : Latency enable write and normal enable read for port-a.       //
//                      i_we_b,i_rd_b          : Latency enable write and normal enable read for port-b.       //
//                      i_din_a,i_din_b        : Data inputs for port-a and port-b.                            //
//                      i_addra_wr,i_addrb_wr  : Latency write address signals for port-a and port-b.          //
//                      i_addra_rd,i_addrb_rd  : Normal read address signals for port-a and port-b.            //
//                      o_douta,o_doutb        : Data outputs of the memory for port-a and port-b.             //   
//                                                                                                             //                                                                                        
//  File Description  : This module is a normal Dual-Port RAM that takes the delayed signals from the latency  //
//                      module and performs read and write operations in its internal memory                   //
//                      register.                                                                              //  
//                                                                                                             //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module modified_dual_mem#( parameter DATA_WIDTH    = 8,
                           parameter ADDR_WIDTH    = $clog2(MEM_DEPTH),
                           parameter MEM_DEPTH     = 16,
                           parameter MEM_WIDTH     = 2 * DATA_WIDTH,
                           parameter WR_LATENCYA   = 1,
                           parameter RD_LATENCYA   = 1,
                           parameter WR_LATENCYB   = 1,
                           parameter RD_LATENCYB   = 1,
                           localparam PARITY_BITS  = $clog2(DATA_WIDTH)+1,
                           localparam ENCODED_WORD = DATA_WIDTH + PARITY_BITS)( input                         clka,clkb,             
                                                                                input                         i_ena_wr,i_enb_wr,     
                                                                                input                         i_ena_rd,i_enb_rd,     
                                                                                input                         i_we_a,i_rd_a,         
                                                                                input                         i_we_b,i_rd_b,         
                                                                                input      [ENCODED_WORD+1:1] i_din_a,i_din_b,       
                                                                                input      [ADDR_WIDTH-1:0]   i_addra_wr,i_addrb_wr, 
                                                                                input      [ADDR_WIDTH-1:0]   i_addra_rd,i_addrb_rd, 
                                                                                output reg [ENCODED_WORD+1:1] o_douta,o_doutb        
                                                     );
  

  reg [MEM_WIDTH-1:0] mem [MEM_DEPTH-1:0]; // Internal memory declaration for read and write operations.

  //This procedural block performs write operation by taking delayed write
  //enable signal(i_we_a) from latency module and delayed enable
  //signal(i_ena_wr) from latency module. This write operation is done after
  //write latency period for port-a.
  always@(posedge clka)
  begin
    if(i_ena_wr && i_we_a)
       mem[i_addra_wr] <= i_din_a;
  end

  //This procedural block performs read operation where the enable
  //signal(i_ena_rd) and write enable signal is directly taken from
  //the inputs bypassing latency module. This read operation is only done
  //when i_rd_a is low i.e. write enable signal from top module when
  //deasserted, only then this operation is valid. This read operation is done
  //immediately in the next posedge for port-a.
  always@(posedge clka)
  begin
    if(i_ena_rd && (~i_rd_a))
      o_douta <= mem[i_addra_rd];
  end

  //This procedural block performs write operation by taking delayed write
  //enable signal(i_we_a) from latency module and delayed enable
  //signal(i_ena_wr) from latency module. This write operation is done after
  //write latency period for port-b.
  always@(posedge clkb)
  begin
    if(i_enb_wr && i_we_b)
       mem[i_addrb_wr] <= i_din_b;
  end

  //This procedural block performs read operation where the enable
  //signal(i_ena_rd) and write enable signal is directly taken from
  //the inputs bypassing latency module. This read operation is only done
  //when i_rd_a is low i.e. write enable signal from top module when
  //deasserted, only then this operation is valid. This read operation is done
  //immediately in the next posedge for port-b.
  always@(posedge clkb)
  begin
    if(i_enb_rd && (~i_rd_b))
      o_doutb <= mem[i_addrb_rd];
  end

endmodule
