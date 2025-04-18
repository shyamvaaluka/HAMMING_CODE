////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : latency_module.sv                                                                                     //
//  Version           : 0.2                                                                                                   //
//                                                                                                                            //
//  parameters used   : DATA_WIDTH  : Width of the data                                                                       //
//                      ADDR_WIDTH  : Width of the address                                                                    //
//                      MEM_DEPTH   : Depth of the DP RAM                                                                     //
//                      MEM_WIDTH   : Width of each location in DP RAM                                                        //
//                      WR_LATENCYA : Write latency of port-a                                                                 //
//                      RD_LATENCYA : Read latency of port-a                                                                  //
//                      WR_LATENCYB : Write latency of port-b                                                                 //
//                      RD_LATENCYB : Read latency of port-b                                                                  // 
//                                                                                                                            //
//  Signals Used      : i_wea,i_web                  : Write enable inputs for port-a and port-b.                             //
//                      clka,clkb                    : Clock inputs for port-a and port-b.                                    //
//                      i_ena_wr_in,i_enb_wr_in      : Write operation related enable signals for port-a and port-b.          //
//                      i_wr_dina,i_wr_dinb          : Write operation related data input signals for port-a and port-b.      //
//                      i_addra,i_addrb              : Input address for port-a and port-b.                                   //
//                      i_rd_dina,i_rd_dinb          : Read operation related data inputs for port-a and port-b.              //
//                      o_wr_dina_out,o_wr_dinb_out  : Write operation related data out signal for port-a and port-b.         //
//                      o_rd_dina_out,o_rd_dinb_out  : Read operation related data out signal for port-a and port-b.          //
//                      o_addra_out,o_addrb_out      : Address out signals for port-a and port-b.                             //
//                      o_wea_out,o_web_out          : Write enable outputs for port-a and port-b.                            //
//                      o_ena_wr_out,o_enb_wr_out    : Write operation related enables signal outputs of port-a and port-b.   //
//                                                                                                                            //
//                                                                                                                            //
//  File Description  : This module applies latency to the signals. All the write operation related                           //
//                      signals are delayed by write latency parameter and the read related signals                           //
//                      are delayed with read latency parameter. The write delayed signals are then                           //  
//                      given to the normal DP RAM. And the output of the DP RAM is inturn given to                           //                                                
//                      latency module which is then delayed by read latency parameter.                                       //                                                                           
//                                                                                                                            //  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module latency#(  parameter DATA_WIDTH    = 8,
                  parameter ADDR_WIDTH    = $clog2(MEM_DEPTH),
                  parameter MEM_DEPTH     = 16,
                  parameter MEM_WIDTH     = 2 * DATA_WIDTH,
                  parameter WR_LATENCYA   = 1,
                  parameter RD_LATENCYA   = 1,
                  parameter WR_LATENCYB   = 1,
                  parameter RD_LATENCYB   = 1,
                  localparam PARITY_BITS  = $clog2(DATA_WIDTH)+1,
                  localparam ENCODED_WORD = DATA_WIDTH + PARITY_BITS
               )( input                         i_wea,i_web,                 
                  input                         clka,clkb,                   
                  input                         i_ena_wr_in,i_enb_wr_in,     
                  input      [ENCODED_WORD+1:1] i_wr_dina,i_wr_dinb,         
                  input      [ADDR_WIDTH-1:0]   i_addra,i_addrb,             
                  input      [ENCODED_WORD+1:1] i_rd_dina,i_rd_dinb,         
                  output reg [ENCODED_WORD+1:1] o_wr_dina_out,o_wr_dinb_out, 
                  output reg [ENCODED_WORD+1:1] o_rd_dina_out,o_rd_dinb_out, 
                  output reg [ADDR_WIDTH-1:0]   o_addra_out,o_addrb_out,     
                  output reg                    o_wea_out,o_web_out,         
                  output reg                    o_ena_wr_out,o_enb_wr_out              

                );
  
  reg ena_wr     [WR_LATENCYA:0];                       // Internal variable to delay the enable signal by rite_latency period for port-a.
  reg enb_wr     [WR_LATENCYB:0];                       // Internal variable to delay the enable signal by write_latency period for port-b. 
  reg wea_wr_pos [WR_LATENCYA:0];                       // Internal variable to delay the write_enable signal by write_latency period for port-a.
  reg web_wr_pos [WR_LATENCYB:0];                       // Internal variable to delay the write_enable signal by write_latency period for port-b.

  reg [ENCODED_WORD+1:1] wr_dina_temp  [WR_LATENCYA:0]; // Internal variable to delay the data_in signal by write_latency period for port-a. 
  reg [ENCODED_WORD+1:1] wr_dinb_temp  [WR_LATENCYB:0]; // Internal variable to delay the data_in signal by write_latency period for port-b.
  reg [ADDR_WIDTH-1:0]   wr_addra_temp [WR_LATENCYA:0]; // Internal variable to delay the address input signal by write_latency period for port-a.
  reg [ADDR_WIDTH-1:0]   wr_addrb_temp [WR_LATENCYB:0]; // Internal variable to delay the address input signal by write_latency period for port-b.

  reg [ENCODED_WORD+1:1] rd_dina_temp  [RD_LATENCYA:0]; // Internal variable to delay the memory data output signal by read_latency period for port-a. 
  reg [ENCODED_WORD+1:1] rd_dinb_temp  [RD_LATENCYB:0]; // Internal variable to delay the memory data output signal by read_latency period for port-b.

  
`ifdef  LATENCYA_1
  //This procedural block delays the write enable and enable signals by
  //a latency of 1 which inturn acts as a normal dual port ram.
  always@(*)
  begin
    // Parameter is conditionally given as 1 for write latency.
    if(WR_LATENCYA == 1)
    begin
      //Assignments are done using blocking assignments since the memory
      //should get the write enable and enable signals in the immediate next
      //posedge of the clock for port-a.
      o_wea_out      =   i_wea;
      o_ena_wr_out   =   i_ena_wr_in;
    end
    else
    begin
      //If not the values of the enable and write enable are retained.
      o_wea_out      =   o_wea_out;
      o_ena_wr_out   =   o_ena_wr_out;
    end
  end

  //This procedural block delays the data and address signals by
  //a latency of 1 which inturn acts as a normal dual port ram. 
  always@(*)
  begin
    //Parameter is conditionally given as 1 for write latency.
    if(WR_LATENCYA == 1)
    begin
      //Assignments are done using blocking assignments since the memory
      //should get the data_in and address signals in the immediate next
      //posedge of the clock for port-a. 
      o_wr_dina_out  =   i_wr_dina;
      o_addra_out    =   i_addra;
    end
    else
    begin
      //If not the values of the enable and write enable are retained.
      o_wr_dina_out  =   o_wr_dina_out;
      o_addra_out    =   i_addra;
    end
  end

  `else
  //This procedural block delays all the write operation related signals by
  //write latency period i.e. >1 latency.
  always@(posedge clka)
  begin
    //Parameter is conditionally fixed to 2. 
    if(WR_LATENCYA == 2)
    begin
      //Here if write latency when equal to 2 the signals are latched to output
      //using non-blocking assignment. Hence the signals are available to the
      //memory after 1 clock cycle.
      o_wea_out    <=   i_wea;
      o_ena_wr_out <=   i_ena_wr_in;
    end
    //Else if the latency is greater than 2 then first the signal are latched
    //to 0th bit of a temp variable and then successively pipelined upto the
    //latency number.
    else
    begin
      //Latched enable and write_enable signals to the 0th bit of the ena_wr[0] and wea_wr_pos[0].
      ena_wr[0]       <=   i_ena_wr_in;
      wea_wr_pos[0]   <=   i_wea;
      //This for loop takes the latched signal and succesively pipelines it to
      //its next bits until the write latency is met. Here write latency-3 is
      //taken since 2 is the minimum value for pipeline logic.
      for(int i = 1 ; i <= WR_LATENCYA-3 ; i++)
      begin
        wea_wr_pos[i] <= wea_wr_pos[i-1];
        ena_wr[i]     <= ena_wr[i-1];
      end
      //The last bit of the temporary variable consisting of the signal values
      //are assigned to the output which inturn delayed the enable and write
      //enable signals by write latency cycles.
      o_ena_wr_out  <= ena_wr [WR_LATENCYA-3];
      o_wea_out     <= wea_wr_pos [WR_LATENCYA-3];
    end
       
  end

  //This procedural block delays the address and data for write latency>2
  //clock cycles. 
  always@(posedge clka)
  begin
    if(WR_LATENCYA == 2)
    begin
      //Here if write latency when equal to 2 the signals are latched to output
      //using non-blocking assignment. Hence the signals are available to the
      //memory after 1 clock cycle.
      o_wr_dina_out <= i_wr_dina;
      o_addra_out   <= i_addra;
    end
    //Else if the latency is greater than 2 then first the signal are latched
    //to 0th bit of a temp variable and then successively pipelined upto the
    //latency number. 
    else
    begin
      //Latched data and address signals to the 0th bit of the wr_dina_temp[0] and wr_addra_temp[0].
      wr_dina_temp[0]  <= i_wr_dina;
      wr_addra_temp[0] <= i_addra;
     //This for loop takes the latched signal and succesively pipelines it to
     //its next bits until the write latency is met. Here write latency-3 is
     //taken since 2 is the minimum value for pipeline logic.  
     for(int j = 1 ; j <= WR_LATENCYA-3 ; j++)
     begin
       wr_addra_temp[j] <= wr_addra_temp[j-1];
       wr_dina_temp[j]  <= wr_dina_temp[j-1];
     end
     //The last bit of the temporary variable consisting of the signal values
     //are assigned to the output which inturn delayed the data and address
     //signals by write latency cycles. 
     o_wr_dina_out <= wr_dina_temp [WR_LATENCYA-3];
     o_addra_out   <= wr_addra_temp [WR_LATENCYA-3];
    end
  end
`endif

`ifdef RD_LATENCYA_1
  //This procedural block assigns memory output directly to the top module
  //output in the immediate next posedge.
  always@(*)
  begin
    //Here we are assigning the output of the memory in the read operation to
    //the output in the immediate next posedge by using blocking assignment.
    if(RD_LATENCYA == 1)
      o_rd_dina_out = i_rd_dina;
    //Else the value is retained.
    else
      o_rd_dina_out = o_rd_dina_out;
  end

`else
  //This procedural block delays the memory output by read latency clock
  //cycles.
  always@(posedge clka)
  begin
    //Here if read latency is 2 then the data signal is latched to
    //a temporary variable using non-blocking assignment and the output 
    //is routed after 1 clock cycle.
    if(RD_LATENCYA == 2)
    begin
      o_rd_dina_out <= i_rd_dina;
    end
    //In the else block we delay the data by read latency clock cycles for >2
    //latency,by first latching it to a temporary variable and pipelining it
    //upto read latency clcok cycles.
    else
    begin
      //Here we first latched the memory output data to the 0th bit of
      //rd_dina_temp.
      rd_dina_temp[0] <= i_rd_dina;
      //This for loop traverses upto read latency cycles where the depth of
      //the rd_dina_temp keeps increasing which eventually shifts the
      //i_rd_dina value for read latency cycles in a pipeline fashion.
      for(int u = 1 ; u <= RD_LATENCYA-3 ; u++)
      begin
         rd_dina_temp[u] <= rd_dina_temp[u-1];
      end
      //The value present in the last bit of the rd_dina_temp is assigned to
      //the output o_rd_dina_out after read latency clock cycles.
      o_rd_dina_out <= rd_dina_temp[RD_LATENCYA-3];
    end
  end
`endif



 `ifdef LATENCYB_1
  //This procedural block delays the write enable and enable signals by
  //a latency of 1 which inturn acts as a normal dual port ram. 
  always@(*)
  begin
    // Parameter is conditionally given as 1 for write latency.
    if(WR_LATENCYB == 1)
    begin
      //Assignments are done using blocking assignments since the memory
      //should get the write enable and enable signals in the immediate next
      //posedge of the clock for port-b.
      o_web_out    = i_web;
      o_enb_wr_out = i_enb_wr_in;
    end
    else
    begin
      //If not the values of the enable and write enable are retained.
      o_web_out    = o_web_out;
      o_enb_wr_out = o_enb_wr_out;
    end
  end
  
  //This procedural block delays the data and address signals by
  //a latency of 1 which inturn acts as a normal dual port ram. 
  always@(*)
  begin
    //Parameter is conditionally given as 1 for write latency.
    if(WR_LATENCYB == 1)
    begin
      //Assignments are done using blocking assignments since the memory
      //should get the data_in and address signals in the immediate next
      //posedge of the clock for port-a.
      o_wr_dinb_out = i_wr_dinb;
      o_addrb_out   = i_addrb;
    end
    else
    begin
      //If not the values of the data and write address are retained.
      o_wr_dinb_out = o_wr_dinb_out;
      o_addrb_out   = o_addrb_out;
    end
  end
  
  
 `else
  //This procedural block delays all the write operation related signals by
  //write latency period i.e. >1 latency.
  always@(posedge clkb)
  begin
    //Parameter is conditionally fixed to 2.
    if(WR_LATENCYB == 2)
    begin
      //Here if write latency when equal to 2 the signals are latched to output
      //using non-blocking assignment. Hence the signals are available to the
      //memory after 1 clock cycle.
      o_web_out    <= i_web;
      o_enb_wr_out <= i_enb_wr_in;
    end
    //Else if the latency is greater than 2 then first the signal are latched
    //to 0th bit of a temp variable and then successively pipelined upto the
    //latency number. 
    else
    begin
      //Latched enable and write_enable signals to the 0th bit of the enb_wr[0] and web_wr_pos[0].
      enb_wr[0]     <= i_enb_wr_in;
      web_wr_pos[0] <= i_web;
      //This for loop takes the latched signal and succesively pipelines it to
      //its next bits until the write latency is met. Here write latency-3 is
      //taken since 2 is the minimum value for pipeline logic. 
      for(int k = 1 ; k <= WR_LATENCYB-3 ; k++)
      begin
          web_wr_pos[k] <= web_wr_pos[k-1];
          enb_wr[k]     <= enb_wr[k-1];
      end
      //The last bit of the temporary variable consisting of the signal values
      //are assigned to the output which inturn delayed the enable and write
      //enable signals by write latency cycles. 
      o_enb_wr_out <= enb_wr[WR_LATENCYB-3];
      o_web_out    <= web_wr_pos[WR_LATENCYB-3];
    end
  end

  //This procedural block delays the address and data for write latency>2
  //clock cycles.
  always@(posedge clkb)
  begin
    if(WR_LATENCYB == 2)
    begin
      //Here if write latency when equal to 2 the signals are latched to output
      //using non-blocking assignment. Hence the signals are available to the
      //memory after 1 clock cycle.
      o_wr_dinb_out <= i_wr_dinb;
      o_addrb_out   <= i_addrb;
    end
    //Else if the latency is greater than 2 then first the signal are latched
    //to 0th bit of a temp variable and then successively pipelined upto the
    //latency number. 
    else
    begin
      //Latched data and address signals to the 0th bit of the wr_dinb_temp[0] and wr_addrb_temp[0].
      wr_dinb_temp[0]  <= i_wr_dinb;
      wr_addrb_temp[0] <= i_addrb;
      //This for loop takes the latched signal and succesively pipelines it to
      //its next bits until the write latency is met. Here write latency-3 is
      //taken since 2 is the minimum value for pipeline logic. 
      for(int l = 1 ; l <= WR_LATENCYB-3 ; l++)
      begin
        wr_addrb_temp[l] <= wr_addrb_temp[l-1];
        wr_dinb_temp[l]  <= wr_dinb_temp[l-1];
      end
      //The last bit of the temporary variable consisting of the signal values
      //are assigned to the output which inturn delayed the data and address
      //signals by write latency cycles.
      o_wr_dinb_out <= wr_dinb_temp[WR_LATENCYB-3];
      o_addrb_out   <= wr_addrb_temp[WR_LATENCYB-3];
    end
  end

  `endif


`ifdef RD_LATENCYB_1
  //This procedural block assigns memory output directly to the top module
  //output in the immediate next posedge.
  always@(*)
  begin
    //Here we are assigning the output of the memory in the read operation to
    //the output in the immediate next posedge by using blocking assignment.
    if(RD_LATENCYB == 1)
      o_rd_dinb_out = i_rd_dinb;
    else
      //Else the value is retained.
      o_rd_dinb_out = o_rd_dinb_out;
  end
`else
  //This procedural block delays the memory output by read latency clock
  //cycles. 
  always@(posedge clkb)
  begin
    //Here if read latency is 2 then the data signal is latched to
    //a temporary variable using non-blocking assignment and the output 
    //is routed after 1 clock cycle.
    if(RD_LATENCYB == 2)
      o_rd_dinb_out <= i_rd_dinb;
    //In the else block we delay the data by read latency clock cycles for >2
    //latency,by first latching it to a temporary variable and pipelining it
    //upto read latency clcok cycles.  
    else
    begin
      //Here we first latched the memory output data to the 0th bit of
      //rd_dina_temp.
      rd_dinb_temp[0] <= i_rd_dinb;
      //This for loop traverses upto read latency cycles where the depth of
      //the rd_dina_temp keeps increasing which eventually shifts the
      //i_rd_dina value for read latency cycles in a pipeline fashion. 
      for(int p = 1 ; p <= RD_LATENCYB-3 ; p++)
      begin
         rd_dinb_temp[p] <= rd_dinb_temp[p-1];
      end
      //The value present in the last bit of the rd_dina_temp is assigned to
      //the output o_rd_dina_out after read latency clock cycles. 
      o_rd_dinb_out <= rd_dinb_temp[RD_LATENCYB-3];
    end
  end
`endif
endmodule
