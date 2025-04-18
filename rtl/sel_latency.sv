////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : sel_latency.sv                                                                //
//  Version           : 0.2                                                                           //
//                                                                                                    //
//  parameters used   : READ_LATENCYA : Read latency of port-a                                        //
//                      READ_LATENCYB : Read latency of port-b                                        //
//                      ADDR_WIDTH1   : Nth bit of address from the top module                        //
//                      ADDR_WIDTH2   : N-1 bit of address from the top module                        //  
//                                                                                                    //
//  Signals Used      : i_sel_in_a,i_sel_in_b   : Select inputs for port-a and port-b.                //
//                      o_sel_out_a,o_sel_out_b : Delayed select outputs for port-a and port-b.       //
//                                                                                                    //
//  File Description  : This is the select latency module that delays the select lines of the         //
//                      data_routing 4x1 output mulitplexer by read_latency. Based on                 //
//                      this latency the mux routes data from each bank onto single channel by read   //  
//                      latency parameter.                                                            //                                                                          
//                                                                                                    //  
//////////////////////////////////////////////////////////////////////////////////////////////////////// 

module sel_latency#(  parameter READ_LATENCYA = 2,
	                    parameter READ_LATENCYB = 2,
	                    parameter ADDR_WIDTH1   = 2,
	                    parameter ADDR_WIDTH2   = 1
                   )( input                                    clka,clkb,
	                    input      [ADDR_WIDTH1-1:ADDR_WIDTH2-1] i_sel_in_a,i_sel_in_b,  
	                    output reg [ADDR_WIDTH1-1:ADDR_WIDTH2-1] o_sel_out_a,o_sel_out_b 
                    );

	reg [ADDR_WIDTH1-1:ADDR_WIDTH2-1] latched1; //Internal variable to latch and delay the input signal of port-a by 1 clock cycle.
  reg [ADDR_WIDTH1-1:ADDR_WIDTH2-1] latched2; //Internal variable to latch and delay the input signal of port-b by 1 clock cycle.
	reg [1:0] temp  [READ_LATENCYA-2:0];        //Internal variable to pipeline the latch signal for read latency clock cycles of port-a.
	reg [1:0] temp1 [READ_LATENCYB-2:0];        //Internal variable to pipeline the latch signal for read latency clock cycles of port-b.

  
  //This procedural block takes the top two bits of the input address as
  //select line inputs for data multiplexer at the output and delays these
  //select inputs by read latency clock cycles for port-a.
  always@(posedge clka)
	begin
    //Latching the input signal to the internal variable latched1 to initially
    //delay it by 1 clock cycle.
		latched1 <= i_sel_in_a;
		if(READ_LATENCYA == 1)
      //Here if read latency is 1 then we are directly assigning the input to
      //output so that the signal is visible after 1 clcok cycle.
			o_sel_out_a <= i_sel_in_a;
		else if(READ_LATENCYA == 2)
      //If read latency is 2 then we are assigning the delayed version of
      //input signal i.e. latched1 and then assigning to output where the
      //signal is visible after 2 clock cycles.
			o_sel_out_a <= latched1;
		else
		begin
      //Here if read latency of port-a when greater than 2 then first we are
      //assigning the delayed version of the signal to nth bit of the internal
      //variable temp.
			temp [READ_LATENCYA - 2] <= latched1;
      //This for loop shifts the value of the signal to its successive bits
      //within the internal variable for read_latency-3 clock cycles. Here we
      //have taken read_latency-3 since 2 is the minimum value.
			for(int i = READ_LATENCYA-3 ; i >= 1 ; i = i - 1)
				temp[i] <= temp[i + 1];
      //At the read_latency(th) clock cycle the value from the 1st bit of the
      //internal variable is assigned to the output. So the signal is visible
      //after read latency clcok cycles for port-a.
			o_sel_out_a <= temp[1];
		end
	end


	//This procedural block takes the top two bits of the input address as
  //select line inputs for data multiplexer at the output and delays these
  //select inputs by read latency clock cycles for port-b.
  always@(posedge clkb)
	begin
    //Latching the input signal to the internal variable latched1 to initially
    //delay it by 1 clock cycle.
		latched2 <= i_sel_in_b;
		if(READ_LATENCYB == 1)
      //Here if read latency is 1 then we are directly assigning the input to
      //output so that the signal is visible after 1 clcok cycle.
			o_sel_out_b <= i_sel_in_b;
		else if(READ_LATENCYB == 2)
      //If read latency is 2 then we are assigning the delayed version of
      //input signal i.e. latched1 and then assigning to output where the
      //signal is visible after 2 clock cycles.
			o_sel_out_b <= latched2;
		else
		begin
      //Here if read latency of port-a when greater than 2 then first we are
      //assigning the delayed version of the signal to nth bit of the internal
      //variable temp.
			temp1 [READ_LATENCYB-2] <= latched2;
      //This for loop shifts the value of the signal to its successive bits
      //within the internal variable for read_latency-3 clock cycles. Here we
      //have taken read_latency-3 since 2 is the minimum value. 
			for(int i = READ_LATENCYB-3 ; i >= 1 ; i = i - 1)
				temp1[i] <= temp1[i + 1];
      //At the read_latency(th) clock cycle the value from the 1st bit of the
      //internal variable is assigned to the output. So the signal is visible
      //after read latency clcok cycles for port-b.  
			o_sel_out_b  <= temp1[1];
		end
	end
endmodule
